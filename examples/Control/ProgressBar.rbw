require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	ProgressBar.new(window, :progress1, style: :smooth, position: [10, 10, 200, 24]).step = 1
	Button.new(window, :progress, position: [215, 10, 76, 24])

	ProgressBar.new(window, :progress2, style: :marquee, position: [10, 40, 200, 24])
	Button.new(window, :marquee, position: [215, 40, 76, 24])

	window[:progress].on(:clicked) { |args|
		args[:sender].toggle(:enabled) {
			100.times { window[:progress1].step!; sleep(0.1) }
		}
	}

	window[:marquee].on(:clicked) { |args|
		window[:progress2].toggle(:marquee)
		args[:sender].pushed = window[:progress2].marquee?
	}
}
