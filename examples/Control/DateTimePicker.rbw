require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	DateTimePicker.new(window, :datetime1, position: [10, 10, 150, 24])

	window[:datetime1].on(:datetimechange) { |args| message args[:st].get }
}
