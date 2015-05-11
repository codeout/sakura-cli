require 'test-unit'
require 'sakura/mail_address'
require 'pry'

class MailAddressTest < Test::Unit::TestCase
  new_mail = 'dummy'

  test 'Create a new mail address' do
    assert_false Sakura::MailAddress.all.any? {|m| m.address == new_mail }
    assert_true  Sakura::MailAddress.create(new_mail, 'dummy000')
    assert_true  Sakura::MailAddress.all.any? {|m| m.address == new_mail }
  end

  test 'Delete a mail address' do
    mail = Sakura::MailAddress.all.find {|m| m.address == new_mail }

    assert_not_nil mail
    assert_true mail.delete
    assert_false Sakura::MailAddress.all.any? {|m| m.address == new_mail }
  end
end
