module Pact
  module Support
    module CLI

      def execute_command command, options = {}
        result = nil
        Open3.popen3(command) {|stdin, stdout, stderr, wait_thr|
          result = wait_thr.value
          ensure_patterns_present(command, options, stdout, stderr) if options[:with]
          ensure_patterns_not_present(command, options, stdout, stderr) if options[:without]
        }
        result.success?
      end

      def ensure_patterns_present command, options, stdout, stderr
        require 'term/ansicolor'
        output = stdout.read + stderr.read
        options[:with].each do | pattern |
          raise ("Could not find #{pattern.inspect} in output of #{command}" + "\n\n#{output}") unless output =~ pattern
        end
      end

      def ensure_patterns_not_present command, options, stdout, stderr
        require 'term/ansicolor'
        output = stdout.read + stderr.read
        options[:without].each do | pattern |
          raise ("Expected not to find #{pattern.inspect} in output of #{command}" + "\n\n#{output}") if output =~ pattern
        end
      end

    end
  end
end
