require 'test-unit'
require 'sakura/mail_address'
require 'pry'

class MailAddressTest < Test::Unit::TestCase
  self.test_order = :defined
  new_mail = 'dummy'

  test 'Create a new mail address' do
    assert_false Sakura::MailAddress.all.any? {|m| m.address == new_mail }
    assert_true  Sakura::MailAddress.create(new_mail, 'dummy000')
    assert_true  Sakura::MailAddress.all.any? {|m| m.address == new_mail }
  end

  test 'Increase the quota' do
    mail = Sakura::MailAddress.all.find {|m| m.address == new_mail }
    old_value = mail.quota
    mail.quota = old_value.to_i + 1

    mail = Sakura::MailAddress.all.find {|m| m.address == new_mail }
    assert_not_equal mail.quota, old_value
  end

  test 'Delete a mail address' do
    mail = Sakura::MailAddress.all.find {|m| m.address == new_mail }

    assert_not_nil mail
    assert_true mail.delete
    assert_false Sakura::MailAddress.all.any? {|m| m.address == new_mail }
  end
end
