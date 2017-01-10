require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	Button.new(window, :button1)
}
