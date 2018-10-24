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
      !@last_login.nil?
    end

    def login
      visit BASE_URL
      fill_in 'domain',   with: @domain
      fill_in 'password', with: @passwd
      find('form input[type=image]').click

      @last_login = Time.now if page.text =~ /ログインドメイン: #{@domain}/

      raise_when_error
      login?
    end

    def get(url)
      login unless login?
      visit url
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
      error = page.all('.error-message')
      raise error.first.text unless error.empty?
    end
  end
end
