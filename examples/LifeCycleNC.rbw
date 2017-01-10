require 'fzeet'

include Fzeet

Application.quitWhenMainWindowCloses = false

Application.run(deferCreateWindow: true) { |window|
	window.
		on(:nccreate) { |args|
			args[:result] = 0 if question('NCCreate?').no?
		}.

		on(:create) { |args|
			args[:result] = -1 if question('Create?').no?
		}.

		on(:close) {
			window.dispose if question('Close?', buttons: [:yes, :No]).yes?
		}.

		on(:destroy) {
			message 'on(:destroy)'
		}.

		on(:ncdestroy) {
			message 'on(:ncdestroy)'

			Application.quit
		}
}
