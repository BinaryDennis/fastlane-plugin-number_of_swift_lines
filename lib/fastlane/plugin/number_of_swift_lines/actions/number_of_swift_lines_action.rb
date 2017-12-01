module Fastlane
  module Actions
    module SharedValues
      NUMBER_OF_SWIFT_LINES_IN_LARGEST_FILES = :NUMBER_OF_SWIFT_LINES_IN_LARGEST_FILES
      NUMBER_OF_SWIFT_FILES = :NUMBER_OF_SWIFT_FILES
      NUMBER_OF_SWIFT_LINES = :NUMBER_OF_SWIFT_LINES
      NUMBER_OF_SWIFT_TEST_FILES_LINES = :NUMBER_OF_SWIFT_TEST_FILES_LINES
      TEST_PROD_CODE_RATIO = :TEST_PROD_CODE_RATIO
    end

    class NumberOfSwiftLinesAction < Action
      def self.run(params)
        require 'artii'

        number_of_largest_files = params[:largest_files_cap]
        show_ascii = params[:enable_ascii_art]
        exclude_regex = params[:files_exclude_regex]
        include_regex = params[:test_files_include_regex]
        #skip_empty = params[:skip_empty_lines]

        find_command = "find . -name \"*.swift\" | egrep -v \"#{exclude_regex}\""
        find_command_tests = "find . -name \"*.swift\" | egrep \"#{include_regex}\""
        #find_command = "find . -name '*.swift' -not -path '*/Tests/*' -not -path '*/Pods/*' -not -path '*/Carthage/*' -print0"
        UI.message(find_command)
        UI.message(find_command_tests)

        swift_files = `#{find_command}`
        if swift_files.empty?
          UI.error("No swift files found :(")
          exit 1
        end

        test_files = `#{find_command_tests}`
        number_of_lines_test_files   = "0\n"
        if test_files.empty?
          UI.message("WARNING: No test files found :(")
        else
          number_of_lines_test_files = `echo '#{test_files}' | tr '\\n' '\\0' | xargs -0 wc -l | tail -1 | awk '{print $1}'`
        end

        # | xargs -0 awk 'NF > 0'  | wc -l
        number_of_files              = `echo '#{swift_files}' | wc -l | awk '{print $1}'`
        number_of_lines              = `echo '#{swift_files}' | tr '\\n' '\\0' | xargs -0 wc -l | tail -1 | awk '{print $1}'`
        largest_files                = `echo '#{swift_files}' | tr '\\n' '\\0' | xargs -0 wc -l | sort -n | tail -'#{number_of_largest_files.to_s}' | head -'#{(number_of_largest_files-1).to_s}'`
        number_of_lines_largest_file = `echo '#{swift_files}' | tr '\\n' '\\0' | xargs -0 wc -l | sort -n | tail -2 | head -1 | awk '{print $1}'`

        test_production_code_ratio   = number_of_lines_test_files.to_f / number_of_lines.to_f
        test_production_code_ratio_str = test_production_code_ratio.round(2).to_s

        ascii_message = ""
        if  show_ascii == true then
          a = Artii::Base.new :font => 'univers'
          ascii_message = ""
          ascii_message += a.asciify(number_of_lines_largest_file)
          ascii_message += a.asciify(number_of_files)
          ascii_message += a.asciify(number_of_lines)
          ascii_message += a.asciify(number_of_lines_test_files)
          ascii_message += a.asciify(test_production_code_ratio_str.to_s)
        end

        UI.message("\n\n" + "The " + number_of_largest_files.to_s + " largest files in ascending order:\n\n" + largest_files \
          + "\n\nNumber of lines in the largest swift file:\t" + number_of_lines_largest_file \
          + "Total number of swift files:\t\t\t" + number_of_files \
          + "Total number of swift lines of code:\t\t" + number_of_lines \
          + "Total number of swift lines in test files:\t" + number_of_lines_test_files \
          + "Testing / Production code ratio:\t\t" + test_production_code_ratio_str.to_s + "\n\n\n"\
          + ascii_message + "\n")

        Actions.lane_context[SharedValues::NUMBER_OF_SWIFT_LINES_IN_LARGEST_FILES] = number_of_lines_largest_file
        Actions.lane_context[SharedValues::NUMBER_OF_SWIFT_FILES] = number_of_files
        Actions.lane_context[SharedValues::NUMBER_OF_SWIFT_LINES] = number_of_lines
        Actions.lane_context[SharedValues::NUMBER_OF_SWIFT_TEST_FILES_LINES] = number_of_lines_test_files
        Actions.lane_context[SharedValues::TEST_PROD_CODE_RATIO] = test_production_code_ratio_str.to_s

      end

      def self.description
        "Outputs the total number of lines of swift code, number of swift files, and a list of the largest swift files, and some other useful statistics"
      end

      def self.authors
        ["@BinaryDennis"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
        [
          ['NUMBER_OF_SWIFT_LINES_IN_LARGEST_FILES', 'The number of lines in the largets swift file, excluding testing files'],
          ['NUMBER_OF_SWIFT_FILES', 'The total number of swift files, excluding testing files'],
          ['NUMBER_OF_SWIFT_LINES', 'The total number of swift lines in all prodcution code swift files'],
          ['NUMBER_OF_SWIFT_TEST_FILES_LINES', 'The total number of swift lines in all testing swift files'],
          ['TEST_PROD_CODE_RATIO', 'The ratio between testing and production code in all swift files']
        ]
      end

      def self.details
        # Optional:
        "Outputs the total number of lines of swift code, number of swift files, and a list of the largest swift files, and some other useful statistics. \
        Default optinos, excludes unit & UI testing swift files and outputs the statistics in ASCII art :)"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :largest_files_cap,
            env_name: "LARGEST_FILES_CAP",
            description: "Determines how many files to list, when showing the largets files",
            optional: true,
            default_value: 10,
            type: Integer),

          FastlaneCore::ConfigItem.new(key: :enable_ascii_art,
            env_name: "ENABLE_ASCII_ART",
            description: "If enabled, shows the total number of swift lines in ASCII art",
            optional: true,
            default_value: true,
            type: [TrueClass, FalseClass]),

          # FastlaneCore::ConfigItem.new(key: :skip_empty_lines,
          #     env_name: "SKIP_EMPTY_LINES",
          #     description: "If enabled, does not include empty lines in the statistics",
          #     optional: true,
          #     default_value: true,
          #     type: [TrueClass, FalseClass]),

          FastlaneCore::ConfigItem.new(key: :files_exclude_regex,
              env_name: "FILES_EXCLUDE_REGEX",
              description: "Regex string used with grep to exclude files from the list of all swift files",
              optional: true,
              default_value: "(/Test|/Pods|/Carthage)",
              type: String),

          FastlaneCore::ConfigItem.new(key: :test_files_include_regex,
              env_name: "TEST_FILES_INCLUDE_REGEX",
              description: "Regex string used with grep when searching for test files",
              optional: true,
              default_value: "/Test",
              type: String)
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
