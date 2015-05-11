require 'thor'
require 'sakura/cli/mail'

module Sakura
  module Cli
    class Root < Thor
      desc 'mail', 'Manage mail addresses'
      subcommand 'mail', Mail
    end
  end
end
