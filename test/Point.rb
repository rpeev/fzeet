require_relative '../lib/fzeet'

include Fzeet

# Point.[], Point#to_a
raise unless Point[42, 43].to_a == [42, 43]

# Point#wrap, Point#==
Point[42, 43].tap { |pt|
	Point.wrap(pt.pointer).tap { |pt1|
		raise unless pt.pointer == pt1.pointer # same pointer
		raise if pt.equal?(pt1) # different objects
		raise unless pt == pt1 # same coords

		pt1[:x] += 2
	}

	raise unless pt[:x] == 44
}

# Point#dup
Point[42, 43].tap { |pt|
	pt.dup.tap { |pt1|
		raise if pt.pointer == pt1.pointer # different pointers
		raise if pt.equal?(pt1) # different objects
		raise unless pt == pt1 # same coords

		pt1[:x] += 2
	}

	raise unless pt[:x] == 42
}

# Point#get, Point#set, Point#clear
Point[42, 43].tap { |pt|
	raise unless pt.set(1, 2).get == [1, 2]
	raise unless pt.clear.get == [0, 0]
}

# Point#inside?, Point#outside?
Rect[100, 200, 300, 400].tap { |r|
	raise unless Point[100, 200].inside?(r)
	raise unless Point[299, 399].inside?(r)
	raise if Point[300, 400].inside?(r) # rigth-bottom corner is excluded
	raise unless Point[300, 400].outside?(r)
}

# Point#offset, Point#offset!
Point[42, 43].tap { |pt|
	raise if pt.equal?(pt.offset(10, 20))
	raise unless pt.offset!(10, 20).to_a == [52, 63]
	raise unless pt.offset!(-10, -20).to_a == [42, 43]
}

# Point#client, Point#client!, Point#screen, Point#screen!
Window.new(x: 100, y: 200).tap { |window|
	Point[100, 200].tap { |screen|
		raise if screen.equal?(screen.client(window))
		screen.client!(window).tap { |client|
			raise if client.equal?(client.screen(window))
			raise unless client.to_a.all? { |coord| coord < 0 }
			raise unless client.screen!(window).to_a == [100, 200]
		}
	}
}
