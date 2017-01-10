require 'fzeet'

include Fzeet

Application.run { |window|
	dc = nil

	window.
		on(:lbuttondown) { |args|
			window.capture = true
			dc = ClientDC.new(window)

			dc.move(args[:x], args[:y])
		}.

		on(:lbuttonup) {
			dc.dispose; dc = nil
			window.capture = false
		}.

		on(:mousemove) { |args|
			next unless window.capture?

			dc.line(args[:x], args[:y])
		}
}
