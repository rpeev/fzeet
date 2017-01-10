require 'fzeet'

include Fzeet

Application.run { |window|
	window.menu = Menu.new.
		append(:popup, '&Go To', PopupMenu.new.
			append(:string, '&Back', :back).
			append(:string, '&Forward', :forward).
			append(:string, '&Up', :up)
		)

	(browser = ExplorerBrowser.new(window)).
		SetOptions(Windows::EBO_SHOWFRAMES)

	browser.
		on(:NavigationComplete) { |pidl|
			FFI::MemoryPointer.new(:char, 4096) { |p|
				Windows.SHGetPathFromIDList(pidl, p)

				message p.read_string
			}
		}.

		goto(:Desktop)

	window.
		on(:command, :back, &browser.method(:back)).
		on(:command, :forward, &browser.method(:forward)).
		on(:command, :up, &browser.method(:up))
}
