require_relative '../lib/fzeet'

include Fzeet

# SystemTime.[], SystemTime#get
SystemTime[Time.local(2000, 3, 4, 5, 6, 7, 8.9 * 1000)].tap { |st|
	local = st.get

	raise unless local.year == 2000
	raise unless local.month == 3
	raise unless local.day == 4
	raise unless local.hour == 5
	raise unless local.min == 6
	raise unless local.sec == 7
	raise unless st[:wMilliseconds] == 9
	raise unless local.usec == 9000
}

# SystemTime#wrap, SystemTime#==
SystemTime[Time.local(2000, 3, 4)].tap { |st|
	SystemTime.wrap(st.pointer).tap { |st1|
		raise unless st.pointer == st1.pointer # same pointer
		raise if st.equal?(st1) # different objects
		raise unless st == st1 # same time

		st1[:wYear] += 10
	}

	raise unless st[:wYear] == 2010
}

# SystemTime#dup
SystemTime[Time.local(2000, 3, 4)].tap { |st|
	st.dup.tap { |st1|
		raise if st.pointer == st1.pointer # different pointers
		raise if st.equal?(st1) # different objects
		raise unless st == st1 # same time

		st1[:wYear] += 10
	}

	raise unless st[:wYear] == 2000
}
