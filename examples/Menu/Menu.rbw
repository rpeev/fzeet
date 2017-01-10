require 'fzeet'

include Fzeet

Application.run { |window|
	window.menu = Menu.new.
		append(:popup, 'Menu&1', PopupMenu.new.
			append(:string, 'Item&1', :item1).
			append([:string, :grayed], 'Item&2', :item2).
			append([:string, :checked], 'Item&3', :item3).

			append(:separator).

			append([:string, :radiocheck, :checked], 'Item&4', :item4).
			append([:string, :radiocheck], 'Item&5', :item5).

			append(:separator).

			append(:popup, 'Menu&2', PopupMenu.new.
				append([:string, :radiocheck, :checked], 'Item&6', :item6).
				append([:string, :radiocheck], 'Item&7', :item7)
			)
		).

		append(:string, 'Item&8', :item8).

		append([:popup, :rightjustify], 'Menu&3', PopupMenu.new.
			append(:string, 'Item&9', :item9)
		)

	window.
		on(:command, :item1) { window.menu[:item2].toggle(:enabled) }.
		on(:command, :item2) { message 'on(:command, :item2)' }.
		on(:command, :item3) { window.menu[:item3].toggle(:checked) }

	[:item4, :item5].each { |id|
		window.on(:command, id) { window.menu[id].select(:item4, :item5) }
	}

	[:item6, :item7].each { |id|
		window.on(:command, id) { window.menu[id].select(:item6, :item7) }
	}

	window.
		on(:command, :item8) { message 'on(:command, :item8)' }.

		on(:command, :item9) {
			message <<-MSG
window.menu[:item2].enabled? - #{window.menu[:item2].enabled?}
window.menu[:item3].checked? - #{window.menu[:item3].checked?}
window.menu[:item4].checked? - #{window.menu[:item4].checked?}
window.menu[:item5].checked? - #{window.menu[:item5].checked?}
window.menu[:item6].checked? - #{window.menu[:item6].checked?}
window.menu[:item7].checked? - #{window.menu[:item7].checked?}
			MSG
		}
}
