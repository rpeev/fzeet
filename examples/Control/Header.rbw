require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	Header.new(window, :header1, style: :buttons, height: 30, anchor: :ltr).
		insertItem(0, 'Item1', 100).
		insertItem(1, 'Item2', 100)
}
