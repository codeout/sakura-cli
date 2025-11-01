# frozen_string_literal: true

require 'sakura/client'

module Sakura
  class MailAddress
    MAIL_URL = "#{BASE_URL}users/list/".freeze

    attr_reader :address, :usage, :quota, :link

    class << self
      def create(local_part, password)
        Client.current_session.process(MAIL_URL, /メールアドレス/) do |page|
          page.first(:xpath, '//a[text() = "新規追加"]').click

          page.find(:xpath, '//label[contains(text(), "ユーザー名")]/..//input')
              .fill_in with: local_part
          page.all(:xpath, '//label[contains(text(), "パスワード")]/..//input').each do |e|
            e.fill_in with: password
          end
          page.find(:xpath, '//label[contains(text(), "メールの受信")]/..//*[contains(text(), "受信する")]/../input').choose
          page.find(:xpath, '//label[contains(text(), "迷惑メールフィルター")]/..//*[contains(text(), "利用しない")]/../input').choose
          page.find(:xpath, '//button[text() = "作成する"]').click
        end

        true
      end

      def all
        page = Client.current_session.get(MAIL_URL, /メールアドレス/)
        page.find('.input-text.page-limit-selector').select '300件'
        wait_for_loading page

        page.all('.entities-item').map do |element|
          MailAddress.new_from_element(element)
        end
      end

      def find(local_part)
        page = Client.current_session.get(MAIL_URL, /メールアドレス/)
        page.find('.input-text.page-limit-selector').select '300件'
        wait_for_loading page

        element = page.find(
          :xpath,
          # rubocop:disable Layout/LineLength
          "//div[contains(@class, \"entities-item\")]//div[@class=\"username\" and contains(text(), \"#{local_part}\")]/../../.."
          # rubocop:enable Layout/LineLength
        )
        MailAddress.new_from_element(element)
      end

      def new_from_element(element)
        MailAddress.new(
          element.find('.username').text.split('@').first,
          element.find('.col-usage').text
        )
      end

      def header
        str = tabularize('address', 'usage', 'quota', '%')
        "#{str}\n#{'-' * (str.size + 1)}"
      end

      def tabularize(*args)
        args[0].ljust(20) <<
          "#{args[1]} /".rjust(15) <<
          args[2].to_s.rjust(10) <<
          "  (#{args[3].to_s.rjust(3)})"
      end

      private

      def wait_for_loading(page)
        5.times do
          break if page.all('読み込み中').empty?

          warn 'still loading ...' if self.class.verbose
        end
      end
    end

    def initialize(address, usage)
      @address = address
      @usage, @quota = usage.split(%r{\s*/\s*|\s+})
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
          page.find(:xpath, '//label[contains(text(), "メール容量制限")]/..//input').fill_in with: ::Regexp.last_match(1)
          page.find(:xpath, '//label[contains(text(), "メール容量制限")]/..//select').select 'GB'
        when /(\d+)\s*MB$/
          page.find(:xpath, '//label[contains(text(), "メール容量制限")]/..//input').fill_in with: ::Regexp.last_match(1)
          page.find(:xpath, '//label[contains(text(), "メール容量制限")]/..//select').select 'MB'
        when /(\d+)\s*KB$/
          page.find(:xpath, '//label[contains(text(), "メール容量制限")]/..//input').fill_in with: ::Regexp.last_match(1)
          page.find(:xpath, '//label[contains(text(), "メール容量制限")]/..//select').select 'KB'
        when /(\d+)\s*B$/
          page.find(:xpath, '//label[contains(text(), "メール容量制限")]/..//input').fill_in with: ::Regexp.last_match(1)
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
        page.all(:xpath, '//label[contains(text(), "パスワード")]/..//input').each do |e|
          e.fill_in with: value
        end
        page.find(:xpath, '//button[text() = "変更する"]').click
      end
    end

    def virus_scan(page = nil)
      if @virus_scan.nil?
        # FIXME: The URL won't work when mail addresses are more than 300
        page ||= Client.current_session.get(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/)
        @virus_scan = page.find('[name="usesMailVirusCheck"]:checked').value == '1'
      end

      @virus_scan
    end

    def virus_scan=(value)
      # FIXME: The URL won't work when mail addresses are more than 300
      Client.current_session.process(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/) do |page|
        page.find("[name='usesMailVirusCheck'][value='#{value ? 1 : 0}']").choose
        page.find(:xpath, '//button[text() = "保存する"]').click
      end

      @virus_scan = value
    end

    def enable_virus_scan
      true
    end

    def disable_virus_scan
      false
    end

    def keep(page = nil)
      if @keep.nil?
        # FIXME: The URL won't work when mail addresses are more than 300
        page ||= Client.current_session.get(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/)
        @keep = page.find('[name="mailReceiveType"]:checked').value == '1'
      end

      @keep
    end

    def keep=(value)
      # FIXME: The URL won't work when mail addresses are more than 300
      Client.current_session.process(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/) do |page|
        text = value ? '受信する' : '転送専用'
        page.find(:xpath, "//label[contains(text(), \"メールの受信\")]/..//*[contains(text(), \"#{text}\")]/../input").choose
        page.find(:xpath, '//button[text() = "保存する"]').click
      end

      @keep = value
    end

    def enable_keep
      true
    end

    def disable_keep
      false
    end

    def spam_filter(page = nil)
      if @spam_filter.nil?
        # FIXME: The URL won't work when mail addresses are more than 300
        page ||= Client.current_session.get(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/)

        case page.find("[name='spamFilterType']:checked").value
        when '1'
          @spam_filter = :disable
        when '2'
          case page.find("[name='spamFilterAction']").value
          when '1'
            @spam_filter = :quarantine
          when '2'
            @spam_filter = :discard
          when '3'
            @spam_filter = :mark
          end
        when '3'
          @spam_filter = :precise
        end
      end

      @spam_filter
    end

    def spam_filter=(value)
      # FIXME: The URL won't work when mail addresses are more than 300
      Client.current_session.process(MAIL_URL + "1/edit/#{@address}", /#{@address}の設定/) do |page|
        text = nil
        action = nil
        case value.to_sym
        when :disable
          text = '利用しない'
        when :quarantine
          text = '簡易' # "迷惑メールフィルタ" doesn't work
          action = '「迷惑メール」フォルダに保存 [推奨]'
        when :discard
          text = '簡易' # "迷惑メールフィルタ" doesn't work
          action = 'メールを破棄'
        when :mark
          text = '簡易' # "迷惑メールフィルタ" doesn't work
          action = 'フィルターのみ利用'
        when :precise
          '高精度迷惑メールフィルタ'
        end

        page.find(:xpath,
                  "//label[contains(text(), \"迷惑メールフィルタ\")]/..//*[contains(text(), \"#{text}\")]/../input").choose
        page.find("[name='spamFilterAction']").select action if action
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

      <<~END_OF_STRING
        usage / quota: #{usage} / #{quota}  (#{percentage(@usage, @quota)})
        forward_to:    #{forward_list(page).join(' ')}
        keep mail:     #{keep(page)}
        virus scan:    #{virus_scan(page)}
        spam filter:   #{spam_filter(page)}
      END_OF_STRING
    end

    private

    def percentage(usage, quota)
      usage, quota = [usage, quota].map do |i|
        case i
        when /([\d.]+)TB$/
          ::Regexp.last_match(1).to_f * 1_000_000_000_000
        when /([\d.]+)GB$/
          ::Regexp.last_match(1).to_f * 1_000_000_000
        when /([\d.]+)MB$/
          ::Regexp.last_match(1).to_f * 1_000_000
        when /([\d.]+)KB$/
          ::Regexp.last_match(1).to_f * 1000
        when /([\d.]+)B$/
          ::Regexp.last_match(1).to_i
        end
      end

      "#{(usage * 100 / quota).to_i}%"
    end
  end
end
