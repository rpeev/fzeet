require 'fzeet'

include Fzeet

Application.run { |window| window.dialog = true
	ascending = [true, true]

	ListView.new(window, :listview1, style: :report, anchor: :ltrb).
		tap { |lv| lv.xstyle << :gridlines << :fullrowselect }.
		insertColumn(0, 'Column1', 100).insertColumn(1, 'Column2', 100).
		insertItem(0, 0, 'Item5').insertItem(0, 1, 'Item2').
		insertItem(1, 0, 'Item1').insertItem(1, 1, 'Item6').
		insertItem(2, 0, 'Item3').insertItem(2, 1, 'Item4').

		on(:columnclick) { |args|
			lv, index = args[:sender], args[:index]
			asc, header = ascending[index], lv.header

			lv.sort(index) { |a, b| (asc) ? a.text <=> b.text : b.text <=> a.text }

			header.count.times { |i|
				style = (asc) ? :sortup : :sortdown if i == index

				header.modifyItem(i, "Column#{i + 1}", style)
			}

			ascending[index] = !asc
		}
}
