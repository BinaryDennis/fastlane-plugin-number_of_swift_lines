module Fastlane
  module Actions
    class NumberOfSwiftLinesAction < Action
      def self.run(params)
        require 'artii'

        current_dir = Dir.pwd
        swift_files = Action.sh("find #{current_dir} -name \"*.swift\" | egrep -v \"(/Tests|/Pods|/Frameworks|/Carthage)\" || true")
        if swift_files.empty?
          UI.error("No swift files found :(")
          exit 1
        end

        number_of_files = Action.sh("echo '#{swift_files}' | wc -l | awk '{print $1}'")
        number_of_lines = Action.sh("echo '#{swift_files}' | xargs wc -l | tail -1 | awk '{print $1}' ")
        largest_files = Action.sh("echo '#{swift_files}' | xargs wc -l | sort -n | tail -20 | head -19")

        a = Artii::Base.new :font => 'univers'
        UI.message("\n\nTotal number of swift files: " + number_of_files + "\n\n" + "The 20 largest files in ascending order:\n\n"+largest_files+"\n" + a.asciify(number_of_lines + " swift lines"))
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
