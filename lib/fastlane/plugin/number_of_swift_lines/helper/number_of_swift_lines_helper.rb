module Fastlane
  module Helper
    class NumberOfSwiftLinesHelper
      # class methods that you define here become available in your action
      # as `Helper::NumberOfSwiftLinesHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the number_of_swift_lines plugin helper!")
      end
    end
  end
end
