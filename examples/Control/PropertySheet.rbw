require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	Button.new(window, :sheet, position: [10, 10, 76, 24]) {
		PropertySheet.new(window)
	}

	Button.new(window, :wizard, position: [90, 10, 76, 24]) {
		PropertySheet.new(window, wizard: true)
	}
}
