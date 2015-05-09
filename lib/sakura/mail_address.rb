require 'sakura/client'

module Sakura
  class MailAddress
    MAIL_URL = BASE_URL + 'rs/mail'

    class << self
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

    def to_s
      self.class.tabularize(@address, @virus_check, @usage, @quota)
    end
  end
end
