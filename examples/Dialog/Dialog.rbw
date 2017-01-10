require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	Button.new(window, :modeless, position: [10, 10, 76, 24]) {
		Dialog.new(window, caption: 'Modeless', x: 100, y: 100) { |args|
			dialog = args[:window]

			Button.new(dialog, :ok, position: [228, 242, 76, 24]) {
				dialog.dispose; window[:modeless].toggle(:enabled)
			}

			Button.new(dialog, :cancel, position: [308, 242, 76, 24]) {
				dialog.dispose; window[:modeless].toggle(:enabled)
			}

			Button.new(dialog, :button1, position: [10, 10, 76, 24]) {
				dialog.message 'clicked'
			}
		}

		window[:modeless].toggle(:enabled)
	}

	Button.new(window, :modal, position: [90, 10, 76, 24]) {
		message Dialog.new(window, modal: true, caption: 'Modal', x: 150, y: 150) { |args|
			dialog = args[:window]

			Button.new(dialog, :ok, position: [228, 242, 76, 24]) {
				dialog.end(:ok)
			}

			Button.new(dialog, :cancel, position: [308, 242, 76, 24]) {
				dialog.end(:cancel)
			}

			Button.new(dialog, :button1, position: [10, 10, 76, 24]) {
				dialog.message 'clicked'
			}
		}.result.ok?
	}
}
