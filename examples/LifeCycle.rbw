require 'fzeet'

include Fzeet

Application.run(deferCreateWindow: true) { |window|
	window.
		on(:create) { |args|
			args[:result] = -1 if question('Create?').no?
		}.

		on(:close) {
			window.dispose if question('Close?', buttons: [:yes, :No]).yes?
		}.

		on(:destroy) {
			message 'on(:destroy)'
		}
}
