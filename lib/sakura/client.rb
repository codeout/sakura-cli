# frozen_string_literal: true

require 'capybara/dsl'
require 'selenium-webdriver'

require 'sakura'
require 'sakura/cli/version'

Capybara.default_driver = :selenium_chrome_headless

module Sakura
  class Client
    include Capybara::DSL

    attr_reader :domain

    @verbose = false

    class << self
      attr_accessor :verbose

      def current_session
        @current_session ||= new
      end
    end

    def initialize
      @domain, @passwd = credentials
    end

    def login?
      @logged_in
    end

    def login
      warn 'login' if self.class.verbose

      visit BASE_URL
      fill_in 'username', with: @domain
      fill_in 'password', with: @passwd
      find('form button[type=submit]').click

      if has_text?('認証コード')
        puts '認証コード:'
        otp = $stdin.gets

        fill_in 'login-otp', with: otp
        find('form button[type=submit]').click
      end

      wait_for_loading

      @logged_in = true if page.text =~ /サーバーコントロールパネル ホーム/

      raise_when_error
      login?
    end

    def get(url, expected)
      login unless login?

      warn "visit #{url}" if self.class.verbose
      visit url
      wait_for_loading
      raise Timeout::Error, 'Timed out' unless page.text =~ expected

      page
    end

    def process(url, expected)
      login unless login?

      get url, expected
      yield page

      raise_when_error
      wait_for_loading
      page
    end

    private

    def credentials
      warn 'SAKURA_DOMAIN is not set' unless ENV['SAKURA_DOMAIN']
      warn 'SAKURA_PASSWD is not set' unless ENV['SAKURA_PASSWD']

      if ENV['SAKURA_DOMAIN'] && ENV['SAKURA_PASSWD']
        [ENV['SAKURA_DOMAIN'], ENV['SAKURA_PASSWD']]
      else
        exit 1
      end
    end

    def raise_when_error
      %w[.error .input-error].each do |cls|
        error = page.all(cls)
        raise error.first.text unless error.empty?
      end
    end

    def wait_for_loading
      5.times do
        break if all('読み込み中').empty?

        warn 'still loading ...' if self.class.verbose
      end
    end
  end
end
