require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	MonthCalendar.new(window, :monthcal1, position: [10, 10, 240, 170])

	window[:monthcal1].on(:selchange) { |args| message args[:st1].get }
}
