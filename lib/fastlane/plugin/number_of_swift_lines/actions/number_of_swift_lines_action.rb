module Fastlane
  module Actions
    class NumberOfSwiftLinesAction < Action
      def self.run(params)
        require 'artii'
        if not File.exists?('/usr/local/bin/cloc')
          UI.error("\nWarning! cloc is not installed in /usr/local/bin/cloc\nrun: brew install cloc")
          exit 1
        end

        result = Action.sh("/usr/local/bin/cloc . --include-lang=\"Swift\" --not-match-d='.*Tests' --ignore-whitespace  --quiet | grep \"Swift\" | awk '{print $5\"-\"$2}'")
        array = result.split("-")
        a = Artii::Base.new :font => 'univers'
        UI.message("\n" + a.asciify(array[0] + " loc"))
        UI.message("\n" + a.asciify(array[1] + " swift files"))
        return result
      end

      def self.description
        "Outputs the total number of swift lines"
      end

      def self.authors
        ["Dennis Charmington"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Using ASCII art to output the total number of code lines written in Swift, excluding all the lines used in unit & UI tests"
      end

      def self.available_options
        [
          # FastlaneCore::ConfigItem.new(key: :your_option,
          #                         env_name: "NUMBER_OF_SWIFT_LINES_YOUR_OPTION",
          #                      description: "A description of your option",
          #                         optional: false,
          #                             type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        [:ios, :mac].include?(platform)
        true
      end
    end
  end
end
