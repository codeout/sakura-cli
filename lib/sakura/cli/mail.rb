require 'thor'
require 'sakura'
require 'sakura/client'
require 'sakura/mail_address'

module Sakura
  module Cli
    class Mail < Thor
      desc 'list', 'List all mail addresses of the domain'
      def list
        addrs = MailAddress.all

        puts "# domain: #{Client.current_session.domain}"
        puts MailAddress.header
        addrs.each {|addr| puts addr.to_s }
      end
    end
  end
end
