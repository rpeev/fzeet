require 'fzeet'

include Fzeet

Application.run(View.new) { |window|
	UIRibbon.new(window,
		[:update, :CmdCombo1] => proc { |args|
			next unless args[:key] == Windows::UI_PKEY_RepresentativeString

			args[:newValue].wstring = 'W' * 10
		}
	).
		invalidate(CmdCombo1, Windows::UI_INVALIDATIONS_PROPERTY, Windows::UI_PKEY_Categories).
		invalidate(CmdCombo1, Windows::UI_INVALIDATIONS_PROPERTY, Windows::UI_PKEY_ItemsSource).
		invalidate(CmdCombo1, Windows::UI_INVALIDATIONS_STATE).

		on(:update, CmdCombo1) { |args|
			case args[:key]
			when Windows::UI_PKEY_Categories
				args[:value].unknown { |current|
					current.QueryInstance(Windows::UICollection) { |categories|
						categories.
							add(C1 = UIRibbon::GalleryItem.new('Category1', 0)).
							add(C2 = UIRibbon::GalleryItem.new('Category2', 1))
					}

					args[:newValue].unknown = current
				}
			when Windows::UI_PKEY_ItemsSource
				args[:value].unknown { |current|
					current.QueryInstance(Windows::UICollection) { |items|
						items.
							add(I1 = UIRibbon::GalleryItem.new('Item1', 0, '../../res/go-next-small.bmp')).
							add(I2 = UIRibbon::GalleryItem.new('Item2', 1, '../../res/go-previous-small.bmp'))
					}

					args[:newValue].unknown = current
				}

				window.ribbon.invalidate(CmdCombo1, Windows::UI_INVALIDATIONS_PROPERTY, Windows::UI_PKEY_SelectedItem)
			when Windows::UI_PKEY_SelectedItem
				args[:newValue].uint = 0
			end
		}.

		on(:execute, CmdCombo1) { |args|
			message "Item with index #{args[:value].uint} selected"
		}

	window.
		on(:draw, Control::Font) { |dc| dc.sms 'Right-click (or menu key) for context menu' }.

		on(:contextmenu) { |args|
			window.ribbon.contextualUI(CmdContextMap1, args[:x], args[:y])
		}
}
