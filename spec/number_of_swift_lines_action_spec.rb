describe Fastlane::Actions::NumberOfSwiftLinesAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The number_of_swift_lines plugin is working!")

      Fastlane::Actions::NumberOfSwiftLinesAction.run(nil)
    end
  end
end
