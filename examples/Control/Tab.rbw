require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	Tab.new(window, :tab1, anchor: :ltrb).
		insert('Tab1').
		insert('Tab2').
		insert('Tab3').

		on(:selchanging) { |args|
			args[:result] = 1 if question('Change?').no?
		}.

		on(:selchange) { |args|
			message "Tab#{args[:sender].current.index + 1} selected"
		}
}
