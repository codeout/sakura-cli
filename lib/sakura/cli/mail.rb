require 'thor'
require 'sakura'
require 'sakura/client'
require 'sakura/mail_address'

module Sakura
  module Cli
    class Mail < Thor
      MAIL_URL = BASE_URL + 'rs/mail'

      desc 'list', 'list all mail addresses of the domain'
      def list
        client = Client.new
        page = client.get(MAIL_URL)

        puts "# domain: #{client.domain}"
        puts Sakura::MailAddress.header
        page.all(:xpath, '//a[contains(@href, "mail?Username=")]/../..').each do |element|
          arguments = element.all('td').map(&:text)[0..-2] + element.all('a').map{|i| i[:href] }
          address = Sakura::MailAddress.new(*arguments)
          puts address.to_s
        end
      end
    end
  end
end
