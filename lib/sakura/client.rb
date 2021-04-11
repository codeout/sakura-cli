require 'capybara/dsl'
require 'selenium-webdriver'

require 'sakura'
require 'sakura/cli/version'

Capybara.default_driver = :selenium_chrome_headless

module Sakura
  class Client
    include Capybara::DSL

    attr_reader :domain

    def self.current_session
      @current_session ||= new
    end

    def initialize
      @domain, @passwd = credentials
    end

    def login?
      @logged_in
    end

    def login
      visit BASE_URL
      fill_in 'login-username', with: @domain
      fill_in 'login-password', with: @passwd
      find('form button[type=submit]').click

      wait_for_loading

      if page.text =~ /サーバコントロールパネル ホーム/
        @logged_in = true
      end

      raise_when_error
      login?
    end

    def get(url, expected)
      login unless login?
      visit url

      wait_for_loading
      unless page.text =~ expected
        raise Timeout::Error.new('Timed out')
      end

      page
    end

    def process(url, &block)
      login unless login?
      visit url
      instance_eval &block

      raise_when_error
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
      error = page.all('.error')
      raise error.first.text unless error.empty?
    end

    def wait_for_loading
      5.times do
        break if find_all('読み込み中').empty?
      end
    end
  end
end
