require 'fzeet'

include Fzeet

Application.run(View.new) { |window|
	UIRibbon.new(window).
		invalidate(CmdGallery1, Windows::UI_INVALIDATIONS_PROPERTY, Windows::UI_PKEY_Categories).
		invalidate(CmdGallery1, Windows::UI_INVALIDATIONS_PROPERTY, Windows::UI_PKEY_ItemsSource).
		invalidate(CmdGallery1, Windows::UI_INVALIDATIONS_STATE).

		invalidate(CmdGallery2, Windows::UI_INVALIDATIONS_PROPERTY, Windows::UI_PKEY_Categories).
		invalidate(CmdGallery2, Windows::UI_INVALIDATIONS_PROPERTY, Windows::UI_PKEY_ItemsSource).
		invalidate(CmdGallery2, Windows::UI_INVALIDATIONS_STATE).

		invalidate(CmdGallery3, Windows::UI_INVALIDATIONS_PROPERTY, Windows::UI_PKEY_Categories).
		invalidate(CmdGallery3, Windows::UI_INVALIDATIONS_PROPERTY, Windows::UI_PKEY_ItemsSource).
		invalidate(CmdGallery3, Windows::UI_INVALIDATIONS_STATE).

		on(:update, CmdGallery1) { |args|
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
							add(I1 = UIRibbon::GalleryItem.new('Item1', 0, '../../res/go-next.bmp')).
							add(I2 = UIRibbon::GalleryItem.new('Item2', 1, '../../res/go-previous.bmp'))
					}

					args[:newValue].unknown = current
				}

				window.ribbon.invalidate(CmdGallery1, Windows::UI_INVALIDATIONS_PROPERTY, Windows::UI_PKEY_SelectedItem)
			when Windows::UI_PKEY_SelectedItem
				args[:newValue].uint = 0
			end
		}.

		on(:update, CmdGallery2) { |args|
			case args[:key]
			when Windows::UI_PKEY_Categories
				args[:value].unknown { |current|
					current.QueryInstance(Windows::UICollection) { |categories|
						categories.
							add(C3 = UIRibbon::GalleryItem.new('Category1', 0)).
							add(C4 = UIRibbon::GalleryItem.new('Category2', 1))
					}

					args[:newValue].unknown = current
				}
			when Windows::UI_PKEY_ItemsSource
				args[:value].unknown { |current|
					current.QueryInstance(Windows::UICollection) { |items|
						items.
							add(I3 = UIRibbon::GalleryItem.new('Item1', 0, '../../res/go-next.bmp')).
							add(I4 = UIRibbon::GalleryItem.new('Item2', 1, '../../res/go-previous.bmp'))
					}

					args[:newValue].unknown = current
				}

				window.ribbon.invalidate(CmdGallery2, Windows::UI_INVALIDATIONS_PROPERTY, Windows::UI_PKEY_SelectedItem)
			when Windows::UI_PKEY_SelectedItem
				args[:newValue].uint = 0
			end
		}.

		on(:update, CmdGallery3) { |args|
			case args[:key]
			when Windows::UI_PKEY_Categories
				args[:value].unknown { |current|
					current.QueryInstance(Windows::UICollection) { |categories|
						categories.
							add(C5 = UIRibbon::GalleryItem.new('Category1', 0)).
							add(C6 = UIRibbon::GalleryItem.new('Category2', 1))
					}

					args[:newValue].unknown = current
				}
			when Windows::UI_PKEY_ItemsSource
				args[:value].unknown { |current|
					current.QueryInstance(Windows::UICollection) { |items|
						items.
							add(I5 = UIRibbon::GalleryItem.new('Item1', 0, '../../res/go-next.bmp')).
							add(I6 = UIRibbon::GalleryItem.new('Item2', 1, '../../res/go-previous.bmp'))
					}

					args[:newValue].unknown = current
				}

				window.ribbon.invalidate(CmdGallery3, Windows::UI_INVALIDATIONS_PROPERTY, Windows::UI_PKEY_SelectedItem)
			when Windows::UI_PKEY_SelectedItem
				args[:newValue].uint = 0
			end
		}.

		on(:execute, CmdGallery1) { |args|
			message "Item with index #{args[:value].uint} selected"
		}.

		on(:execute, CmdGallery2) { |args|
			message "Item with index #{args[:value].uint} selected"
		}.

		on(:execute, CmdGallery3) { |args|
			message (args[:value].nil?) ? "Default action" : "Item with index #{args[:value].uint} selected"
		}

	window.
		on(:draw, Control::Font) { |dc| dc.sms 'Right-click (or menu key) for context menu' }.

		on(:contextmenu) { |args|
			window.ribbon.contextualUI(CmdContextMap1, args[:x], args[:y])
		}
}
