require 'sakura/client'

module Sakura
  class MailAddress
    MAIL_URL = BASE_URL + 'users/list/'

    attr_reader :address, :usage, :quota, :link

    class << self
      def create(local_part, password)
        Client.current_session.process(MAIL_URL, /メールアドレス一覧/) do |page|
          page.first(:xpath, '//a[text() = "新規追加"]').click

          page.find(:xpath, '//label[contains(text(), "ユーザ名")]/..//input')
              .fill_in with: local_part
          page.find_all(:xpath, '//label[contains(text(), "パスワード")]/..//input').each do |e|
            e.fill_in with: password
          end
          page.find(:xpath, '//button[text() = "作成する"]').click
        end

        true
      end

      def all
        page = Client.current_session.get(MAIL_URL, /メールアドレス一覧/)
        page.first('.input-text').select '300件'

        page.all(:css, '.entity-lists .entity-lists-row').map { |element|
          MailAddress.new_from_element(element)
        }
      end

      def find(local_part)
        page = Client.current_session.get(MAIL_URL, /メールアドレス一覧/)
        page.first('.input-text').select '300件'

        element = page.find(:xpath, "//div[contains(@class, \"entity-lists-row\")]//div[@class=\"username\" and contains(text(), \"#{local_part}\")]/../../..")
        MailAddress.new_from_element(element)
      end

      def new_from_element(element)
        MailAddress.new(
          element.find('.username').text.split('@').first,
          element.find('.capacity').text
        )
      end

      def header
        str = tabularize('address', 'usage', 'quota', '%')
        "#{str}\n#{'-' * (str.size + 1)}"
      end

      def tabularize(*args)
        args[0].ljust(20) <<
          "#{args[1]} /".to_s.rjust(15) <<
          args[2].to_s.rjust(10) <<
          "  (#{args[3].to_s.rjust(3)})"
      end
    end

    def initialize(address, usage)
      @address = address
      @usage, @quota = usage.split(/\s*\/\s*/)
    end

    def delete
      # FIXME: The URL won't work when mail addresses are more than 300
      Client.current_session.process(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/) do |page|
        page.accept_confirm do
          page.find('button.is-dangerous').click
        end
      end

      true
    end

    def quota=(value)
      # FIXME: The URL won't work when mail addresses are more than 300
      Client.current_session.process(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/) do |page|
        case value
        when /(\d+)\s*GB$/
          page.find(:xpath, '//label[contains(text(), "メール容量制限")]/..//input').fill_in with: $1
          page.find(:xpath, '//label[contains(text(), "メール容量制限")]/..//select').select 'GB'
        when /(\d+)\s*MB$/
          page.find(:xpath, '//label[contains(text(), "メール容量制限")]/..//input').fill_in with: $1
          page.find(:xpath, '//label[contains(text(), "メール容量制限")]/..//select').select 'MB'
        when /(\d+)\s*KB$/
          page.find(:xpath, '//label[contains(text(), "メール容量制限")]/..//input').fill_in with: $1
          page.find(:xpath, '//label[contains(text(), "メール容量制限")]/..//select').select 'KB'
        when /(\d+)\s*B$/
          page.find(:xpath, '//label[contains(text(), "メール容量制限")]/..//input').fill_in with: $1
          page.find(:xpath, '//label[contains(text(), "メール容量制限")]/..//select').select 'B'
        else
          raise %(Unsupported quota value "#{value}")
        end

        page.find(:xpath, '//button[text() = "保存する"]').click
      end

      @quota = value
    end

    def password=(value)
      # FIXME: The URL won't work when mail addresses are more than 300
      Client.current_session.process(MAIL_URL + "1/password/#{@address}", /#{@address}のパスワード設定/) do |page|
        page.find_all(:xpath, '//label[contains(text(), "パスワード")]/..//input').each do |e|
          e.fill_in with: value
        end
        page.find(:xpath, '//button[text() = "変更する"]').click
      end
    end

    def virus_scan(page = nil)
      if @virus_scan.nil?
        # FIXME: The URL won't work when mail addresses are more than 300
        page ||= Client.current_session.get(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/)
        @virus_scan = page.find('[name="usesVirusCheck"]:checked').value == '1'
      end

      @virus_scan
    end

    def virus_scan=(value)
      # FIXME: The URL won't work when mail addresses are more than 300
      Client.current_session.process(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/) do |page|
        page.find("[name='usesVirusCheck'][value='#{value ? 1 : 0}']").choose
        page.find(:xpath, '//button[text() = "保存する"]').click
      end

      @virus_scan = value
    end

    def enable_virus_scan
      virus_scan = true
    end

    def disable_virus_scan
      virus_scan = false
    end

    def keep(page = nil)
      if @keep.nil?
        # FIXME: The URL won't work when mail addresses are more than 300
        page ||= Client.current_session.get(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/)
        @keep = page.find('[name="receiveType"]:checked').value == '1'
      end

      @keep
    end

    def keep=(value)
      # FIXME: The URL won't work when mail addresses are more than 300
      Client.current_session.process(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/) do |page|
        page.find("[name='receiveType'][value='#{value ? 1 : 2}']").choose
        page.find(:xpath, '//button[text() = "保存する"]').click
      end

      @keep = value
    end

    def enable_keep
      keep = true
    end

    def disable_keep
      keep = false
    end

    def spam_filter(page = nil)
      if @spam_filter.nil?
        # FIXME: The URL won't work when mail addresses are more than 300
        page ||= Client.current_session.get(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/)

        case page.find(:xpath, '//label[contains(text(), "迷惑メールフィルタ")]/..//select').value
        when "0"
          @spam_filter = :disable
        when "1"
          @spam_filter = :quarantine
        when "2"
          @spam_filter = :discard
        when "3"
          @spam_filter = :mark
        end
      end

      @spam_filter
    end

    def spam_filter=(value)
      # FIXME: The URL won't work when mail addresses are more than 300
      Client.current_session.process(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/) do |page|
        select = page.find(:xpath, '//label[contains(text(), "迷惑メールフィルタ")]/..//select')

        value = value.to_sym
        case value
        when :disable
          select.select '利用しない'
        when :quarantine
          select.select '「迷惑メール」フォルダに保存'
        when :discard
          select.select 'メールを破棄'
        when :mark
          select.select 'フィルタの利用'
        end

        page.find(:xpath, '//button[text() = "保存する"]').click
      end

      @spam_filter = value
    end

    def forward_list(page = nil)
      if @forward_list.nil?
        # FIXME: The URL won't work when mail addresses are more than 300
        page ||= Client.current_session.get(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/)
        @forward_list = page.find(:xpath, '//label[contains(text(), "転送先アドレス")]/..//textarea').value.split(/[\n,]+/)
      end

      @forward_list
    end

    def forward_to(mail)
      # FIXME: The URL won't work when mail addresses are more than 300
      Client.current_session.process(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/) do |page|
        @forward_list = page.find(:xpath, '//label[contains(text(), "転送先アドレス")]/..//textarea').value.split(/[\n,]+/)
        page.find(:xpath, '//label[contains(text(), "転送先アドレス")]/..//textarea')
            .fill_in with: (@forward_list + [mail]).uniq.join("\n")
        page.find(:xpath, '//button[text() = "保存する"]').click
      end

      @forward_list << mail
    end

    def delete_forward_to(mail)
      # FIXME: The URL won't work when mail addresses are more than 300
      Client.current_session.process(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/) do |page|
        @forward_list = page.find(:xpath, '//label[contains(text(), "転送先アドレス")]/..//textarea').value.split(/[\n,]+/)
        page.find(:xpath, '//label[contains(text(), "転送先アドレス")]/..//textarea')
            .fill_in with: (@forward_list - [mail]).uniq.join("\n")
        page.find(:xpath, '//button[text() = "保存する"]').click
      end

      @forward_list.delete mail
    end

    def to_s
      self.class.tabularize(@address, @usage, @quota, percentage(@usage, @quota))
    end

    def detail
      # FIXME: The URL won't work when mail addresses are more than 300
      page = Client.current_session.get(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/)

      <<-EOS
usage / quota: #{usage} / #{quota}  (#{percentage(@usage, @quota)})
forward_to:    #{forward_list(page).join(' ')}
keep mail:     #{keep(page)}
virus scan:    #{virus_scan(page)}
spam filter:   #{spam_filter(page)}
      EOS
    end

    private

    def percentage(usage, quota)
      usage, quota = [usage, quota].map { |i|
        case i
        when /([\d.]+)TB$/
          $1.to_f * 1000000000000
        when /([\d.]+)GB$/
          $1.to_f * 1000000000
        when /([\d.]+)MB$/
          $1.to_f * 1000000
        when /([\d.]+)KB$/
          $1.to_f * 1000
        when /([\d.]+)B$/
          $1.to_i
        end
      }

      "#{(usage * 100 / quota).to_i}%"
    end
  end
end
