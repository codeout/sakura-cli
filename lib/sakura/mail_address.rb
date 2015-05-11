require 'sakura/client'

module Sakura
  class MailAddress
    MAIL_URL = BASE_URL + 'rs/mail'

    attr_reader :address, :virus_check, :usage, :quota, :link, :link_to_delete

    class << self
      def create(local_part, password)
        Client.current_session.process(MAIL_URL) do
          fill_in 'NewUsername', with: local_part
          fill_in 'Password1',   with: password
          fill_in 'Password2',   with: password
          find('input[name="Submit_useradd"]').click
        end

        true
      end

      def all
        page = Client.current_session.get(MAIL_URL)

        page.all(:xpath, '//a[contains(@href, "mail?Username=")]/../..').map{|element|
          arguments = element.all('td').map(&:text)[0..-2] + element.all('a').map{|i| i[:href] }
          Sakura::MailAddress.new(*arguments)
        }
      end

      def header
        str = tabularize('address', 'virus_check', 'usage', 'quota')
        "#{str}\n#{'-' * (str.size+1)}"
      end

      def tabularize(*args)
        args[0].ljust(20) <<
          args[1].to_s.rjust(11) <<
          "#{args[2]} /".to_s.rjust(15) <<
          args[3].to_s.rjust(10)
      end
    end


    def initialize(address, virus_check, usage, quota, link, link_to_delete=nil)
      @address        = address
      @virus_check    = virus_check == '○'
      @usage          = usage
      @quota          = quota
      @link           = link
      @link_to_delete = link_to_delete
    end

    def delete
      link = @link_to_delete
      Client.current_session.process(MAIL_URL) do
        find("a[href=\"#{link}\"]").click
      end

      true
    end

    def quota=(value)
      Client.current_session.process(MAIL_URL + @link) do
        fill_in 'MailQuota', with: value
        find('input[name="Submit_quotaedit"]').click
      end
    end

    def password=(value)
      Client.current_session.process(MAIL_URL + @link) do
        fill_in 'Password1', with: value
        fill_in 'Password2', with: value
        find('input[name="Submit_password"]').click
      end
    end

    def to_s
      self.class.tabularize(@address, @virus_check, @usage, @quota)
    end
  end
end
