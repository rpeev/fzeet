require 'fzeet'

include Fzeet

Application.run { |window|
	Container.new(window, height: 100, anchor: :ltr).tap { |w|
		w.style << :border

		Button.new(w, :button1, position: [10, 10, 76, 24])
	}

	Container.new(window, height: 100, anchor: :lrb).tap { |w|
		w.style << :border

		Button.new(w, :button2, position: [10, 10, 76, 24])

		Container.new(w, height: 50, anchor: :lrb).tap { |w1|
			w1.style << :border

			Button.new(w1, :button3, anchor: :ltrb)
		}
	}
}
