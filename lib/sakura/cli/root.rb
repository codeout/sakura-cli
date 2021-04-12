require 'thor'
require 'sakura/cli/mail'

module Sakura
  module Cli
    class Root < Thor
      class_option :verbose, type: :boolean

      # Allow failed exit codes (see https://github.com/erikhuda/thor/issues/244)
      def self.exit_on_failure?
        true
      end

      desc 'mail', 'Manage mail addresses'
      subcommand 'mail', Mail
    end
  end
end
