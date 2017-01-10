require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	TreeView.new(window, :treeview1, style: [:haslines, :linesatroot, :hasbuttons], anchor: :ltrb).
		append('Foo').
			append('Baz').
				append('Quux').
			parent. # Baz
		parent. # Foo
			append('Baz1').
	root. # window[:treeview1]
		append('Bar')
}
