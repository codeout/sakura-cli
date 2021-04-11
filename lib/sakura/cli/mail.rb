require 'thor'
require 'sakura'
require 'sakura/client'
require 'sakura/mail_address'

module Sakura
  module Cli
    class Mail < Thor
      desc 'list', 'List all mail addresses of the domain'

      def list
        preprocess

        addrs = MailAddress.all

        puts "# domain: #{Client.current_session.domain}"
        puts MailAddress.header
        addrs.each { |addr| puts addr.to_s }
      end

      desc 'create LOCAL_PART [PASSWORD]', 'Create a mail address'

      def create(local_part, password = nil)
        preprocess

        password ||= ask_password

        begin
          MailAddress.create local_part, password
        rescue
          raise if options[:verbose]
          abort $!
        end
      end

      desc 'delete LOCAL_PART', 'Delete a mail address'

      def delete(local_part)
        preprocess

        begin
          find(local_part).delete
        rescue
          raise if options[:verbose]
          abort $!
        end
      end

      desc 'quota LOCAL_PART [VALUE]', 'Update or show quota of a mail address'

      def quota(local_part, value = nil)
        preprocess

        mail = find(local_part)

        begin
          if value
            mail.quota = value
          else
            puts mail.quota
          end
        rescue
          raise if options[:verbose]
          abort $!
        end
      end

      desc 'password LOCAL_PART [PASSWORD]', 'Update password of a mail address'

      def password(local_part, password = nil)
        preprocess

        password ||= ask_password
        mail = MailAddress.find(local_part)
        abort %(No mail address: "#{local_part}") unless mail

        begin
          mail.password = password
        rescue
          raise if options[:verbose]
          abort $!
        end
      end

      desc 'scan LOCAL_PART [enable|disable]', 'Switch virus scan configuration of a mail address'

      def scan(local_part, value = nil)
        preprocess

        self.class.handle_argument_error if value && value !~ /enable|disable/

        mail = MailAddress.find(local_part)
        abort %(No mail address: "#{local_part}") unless mail

        begin
          case value
          when 'enable'
            mail.virus_scan = true
          when 'disable'
            mail.virus_scan = false
          when nil
            puts mail.virus_scan
          end
        rescue
          raise if options[:verbose]
          abort $!
        end
      end

      desc 'forward LOCAL_PART [{add|remove} EMAIL]', 'Add, remove or show mail address(es) to forward'

      def forward(local_part, operation = nil, mail_to_forward = nil)
        preprocess

        if (operation && operation !~ /add|remove/) || (!mail_to_forward && operation)
          self.class.handle_argument_error
        end

        mail = MailAddress.find(local_part)
        abort %(No mail address: "#{local_part}") unless mail

        begin
          case operation
          when 'add'
            mail.forward_to mail_to_forward
          when 'remove'
            mail.delete_forward_to mail_to_forward
          when nil
            mail.forward_list.each { |m| puts m }
          end
        rescue
          raise if options[:verbose]
          abort $!
        end
      end

      desc 'keep LOCAL_PART [enable|disable]', 'Switch keep or flush configuration of a mail address'

      def keep(local_part, value = nil)
        preprocess

        self.class.handle_argument_error if value && value !~ /enable|disable/

        mail = MailAddress.find(local_part)
        abort %(No mail address: "#{local_part}") unless mail

        begin
          case value
          when 'enable'
            mail.keep = true
          when 'disable'
            mail.keep = false
          when nil
            puts mail.keep
          end
        rescue
          raise if options[:verbose]
          abort $!
        end
      end

      desc 'show LOCAL_PART', 'Display information about a mail address'

      def show(local_part)
        preprocess

        puts find(local_part).detail
      end

      private

      def preprocess
        Client.verbose = true if options[:verbose]
      end

      def find(local_part)
        begin
          mail = MailAddress.find(local_part)
        rescue Capybara::ElementNotFound
          raise if options[:verbose]
          abort %(No mail address: "#{local_part}")
        end

        mail
      end

      def ask_password
        password = ask('password?', echo: false)
        puts
        confirm = ask('password(confirm)?', echo: false)
        puts
        abort "password doesn't match" unless password == confirm

        password
      end

      def abort(message)
        super "\nERROR: #{message}"
      end
    end
  end
end
