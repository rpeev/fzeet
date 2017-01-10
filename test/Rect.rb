require_relative '../lib/fzeet'

include Fzeet

# Rect.[](left, top, right, bottom), Rect#to_a
raise unless Rect[100, 200, 300, 400].to_a == [100, 200, 300, 400]

# Rect.[](location, size)
raise unless Rect[Point[100, 200], Size[200, 200]].to_a == [100, 200, 300, 400]

# Rect#wrap, Rect#==
Rect[100, 200, 300, 400].tap { |r|
	Rect.wrap(r.pointer).tap { |r1|
		raise unless r.pointer == r1.pointer # same pointer
		raise if r.equal?(r1) # different objects
		raise unless r == r1 # same coords

		r1[:left] += 50
	}

	raise unless r[:left] == 150
}

# Rect#dup
Rect[100, 200, 300, 400].tap { |r|
	r.dup.tap { |r1|
		raise if r.pointer == r1.pointer # different pointers
		raise if r.equal?(r1) # different objects
		raise unless r == r1 # same coords

		r1[:left] += 50
	}

	raise unless r[:left] == 100
}

# Rect#get, Rect#set, Rect#clear, Rect#empty?
Rect[100, 200, 300, 400].tap { |r|
	raise unless r.set(1, 2, 3, 4).get == [1, 2, 3, 4]
	raise if r.empty?
	raise unless r.clear.get == [0, 0, 0, 0]
	raise unless r.empty?
}

# Rect#lt, Rect#lt=, Rect#lb, Rect#lb=, Rect#rt, Rect#rt=, Rect#rb, Rect#rb=
# Rect#width, Rect#width=, Rect#height, Rect#height=, Rect#size, Rect#size=
# Rect#structSize
Rect[100, 200, 300, 400].tap { |r|
	raise unless r.lt.to_a == [100, 200]
	raise unless r.lb.to_a == [100, 400]
	raise unless r.rt.to_a == [300, 200]
	raise unless r.rb.to_a == [300, 400]

	raise unless r.location.to_a == [100, 200]
	raise unless r.size.to_a == [200, 200]

	r.location = Point[1, 2]
	r.size = Size[3, 4]

	raise unless r.to_a == [1, 2, 4, 6]

	raise unless r.structSize == 16
}

# Rect#include?, Rect#exclude?
Rect[100, 200, 300, 400].tap { |r|
	raise unless r.include?(Point[100, 200])
	raise unless r.include?(Point[299, 399])
	raise if r.include?(Point[300, 400]) # rigth-bottom corner is excluded
	raise unless r.exclude?(Point[300, 400])

	raise unless r.include?(Rect[100, 200, 299, 399])
	raise unless r.include?(Rect[100, 200, 299, 399], Point[299, 399])
}

# Rect#normalized?, Rect#normalize, Point#normalize!
Rect[300, 400, 100, 200].tap { |r|
	raise if r.equal?(r.normalize)
	raise if r.normalized?
	raise unless r.normalize!.to_a == [100, 200, 300, 400]
	raise unless r.normalized?
}

# Rect#offset, Rect#offset!, Rect#inflate, Rect#inflate!
Rect[100, 200, 300, 400].tap { |r|
	raise if r.equal?(r.offset(10, 20))
	raise unless r.offset!(10, 20).to_a == [110, 220, 310, 420]
	raise unless r.offset!(-10, -20).to_a == [100, 200, 300, 400]

	raise if r.equal?(r.inflate(10, 20))
	raise unless r.inflate!(10, 20).to_a == [90, 180, 310, 420]
	raise unless r.inflate!(-10, -20).to_a == [100, 200, 300, 400]
}

# Rect#|, Rect#&, Rect#-
[Rect[100, 200, 300, 400], Rect[110, 220, 310, 420]].tap { |r1, r2|
	raise unless (r1 | r2).to_a == [100, 200, 310, 420]

	raise unless (r1 & r2).to_a == [110, 220, 300, 400]

	raise unless r1 - r2 == r1
	r2[:top] = 200
	raise unless (r1 - r2).to_a == [100, 200, 110, 400]
}
