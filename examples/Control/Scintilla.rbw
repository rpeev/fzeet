require 'fzeet'

include Fzeet

Application.run { |window|
	Scintilla.new(window, :sci1, anchor: :ltrb).tap { |sci|
		sci.focus = true

		sci.font = 'Courier New'
		sci.fontSize = 10

		sci.tabWidth = 2

		sci.text = <<-RUBY
def foo
	42
end
		RUBY
	}
}
