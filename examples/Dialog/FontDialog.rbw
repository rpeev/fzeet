require 'fzeet'

include Fzeet

Application.run(View.new) { |window|
	font = IndirectFont.new(Control::Font.logfont)
	color = 0

	window.menu = Menu.new.
		append(:popup, '&View', PopupMenu.new.
			append(:string, '&Font...', :font)
		)

	window.
		on(:command, :font) {
			dialog = FontDialog.new(font: font, color: color)

			dialog.on(:initdialog) { message 'on(:initdialog)' }

			next unless dialog.show.ok?

			font.dispose; font = dialog.font; color = dialog.color

			window.invalidate
		}.

		on(:paint) { window.paint { |dc| dc.select(font) {
			dc.color = color
			dc.sms 'The quick brown fox jumps over the lazy dog. 1234567890'
		}}}.

		on(:destroy) { font.dispose }
}
