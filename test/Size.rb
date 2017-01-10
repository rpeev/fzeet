require_relative '../lib/fzeet'

include Fzeet

# Size.[], Size#to_a
raise unless Size[42, 43].to_a == [42, 43]

# Size#wrap, Size#==
Size[42, 43].tap { |s|
	Size.wrap(s.pointer).tap { |s1|
		raise unless s.pointer == s1.pointer # same pointer
		raise if s.equal?(s1) # different objects
		raise unless s == s1 # same lengths

		s1[:cx] += 2
	}

	raise unless s[:cx] == 44
}

# Size#dup
Size[42, 43].tap { |s|
	s.dup.tap { |s1|
		raise if s.pointer == s1.pointer # different pointers
		raise if s.equal?(s1) # different objects
		raise unless s == s1 # same lengths

		s1[:cx] += 2
	}

	raise unless s[:cx] == 42
}

# Size#get, Size#set, Size#clear
Size[42, 43].tap { |s|
	raise unless s.set(1, 2).get == [1, 2]
	raise unless s.clear.get == [0, 0]
}

# Size#inflate, Size#inflate!
Size[42, 43].tap { |s|
	raise if s.equal?(s.inflate(10, 20))
	raise unless s.inflate!(10, 20).to_a == [52, 63]
	raise unless s.inflate!(-10, -20).to_a == [42, 43]
}
