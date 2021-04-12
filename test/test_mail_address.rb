require 'test-unit'
require 'sakura/mail_address'

class TestMailAddress < Test::Unit::TestCase
  self.test_order = :defined
  new_mail = 'dummy'
  password = 'dummy000'
  mail_to_forward = 'dummy@example.com'

  test 'Create a new mail address' do
    assert_false Sakura::MailAddress.all.any? {|m| m.address == new_mail }
    assert_true  Sakura::MailAddress.create(new_mail, password)
    assert_true  Sakura::MailAddress.all.any? {|m| m.address == new_mail }
  end

  test 'Increase the quota' do
    mail = Sakura::MailAddress.find(new_mail)
    old_value = mail.quota

    mail.quota = '2GB'
    mail = Sakura::MailAddress.find(new_mail)
    assert_not_equal mail.quota, old_value
  end

  test 'Change the password' do
    mail = Sakura::MailAddress.find(new_mail)
    assert_nothing_raised { mail.password = password }
  end

  test 'Switch virus scan' do
    mail = Sakura::MailAddress.find(new_mail)

    mail.virus_scan = true
    mail = Sakura::MailAddress.find(new_mail)
    assert_true mail.virus_scan

    mail.virus_scan = false
    mail = Sakura::MailAddress.find(new_mail)
    assert_false mail.virus_scan
  end

  test 'Manipulate forwarding list' do
    mail = Sakura::MailAddress.find(new_mail)
    assert_empty mail.forward_list

    mail.forward_to mail_to_forward
    mail = Sakura::MailAddress.find(new_mail)
    assert_equal mail.forward_list, [mail_to_forward]

    mail.delete_forward_to mail_to_forward
    mail = Sakura::MailAddress.find(new_mail)
    assert_empty mail.forward_list
  end

  test 'Switch keeping mode' do
    mail = Sakura::MailAddress.find(new_mail)

    mail.keep = true
    mail = Sakura::MailAddress.find(new_mail)
    assert_true mail.keep

    mail.forward_to mail_to_forward
    mail.keep = false
    mail = Sakura::MailAddress.find(new_mail)
    assert_false mail.keep
  end

  test 'Delete a mail address' do
    mail = Sakura::MailAddress.find(new_mail)

    assert_not_nil mail
    assert_true mail.delete
    assert_false Sakura::MailAddress.all.any? {|m| m.address == new_mail }
  end
end
