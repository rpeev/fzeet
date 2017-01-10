require_relative '../lib/fzeet'

include Fzeet

Variant[:bool, true].tap { |variant|
	raise unless variant.bool == true
	variant.bool = false
	raise unless variant.bool == false
}

Variant[:bool, false].tap { |variant|
	raise unless variant.bool == false
	variant.bool = true
	raise unless variant.bool == true
}

Variant[:bool, false].tap { |variant|
	variant.clear

	begin
		variant.bool
	rescue
	else
		raise
	end
}

Variant[:byte, 255].tap { |variant|
	raise unless variant.byte == 255
}

Variant[:char, 255].tap { |variant|
	raise unless variant.char == -1
}

Variant[:qword, 0xdead_beef_feeb_daed].tap { |variant|
	raise unless variant.qword >> 32 == 0xdead_beef
}

Variant[:float, 1.1].tap { |variant|
	#raise unless variant.float == 1.1
	raise unless variant.float - 1.1 < 0.000_000_1
}

Variant[:double, 1.1].tap { |variant|
	raise unless variant.double == 1.1
}

Variant[:string, 'foo'].tap { |variant|
	raise unless variant.string == 'foo'

	variant.clear
}

Variant[:date, Time.local(2000, 3, 4, 5, 6, 7)].tap { |variant|
	local = variant.date

	raise unless local.year == 2000
	raise unless local.month == 3
	raise unless local.day == 4
	raise unless local.hour == 5
	raise unless local.min == 6
	raise unless local.sec == 7
}

Variant[:decimal, 42].tap { |variant|
	raise unless variant.decimal == 42
}

Variant[:decimal, -42].tap { |variant|
	raise unless variant.decimal == -42
}

Variant[:decimal, 1.1].tap { |variant|
	raise unless variant.decimal == 1.1
}

Variant[:decimal, -1.1].tap { |variant|
	raise unless variant.decimal == -1.1
}

IFoo = Windows::COM::Interface[Windows::IDispatch,
	Windows::GUID['00000000-0000-0000-0000-000000000042'],

	value: [[], :int]
]

Foo = Windows::COM::Callback[IFoo]

class Foo
	def value; 42 end
end

Foo.new.tap { |foo|
	raise unless foo.refc == 1

	Variant[:dispatch, foo].tap { |variant|
		raise unless foo.refc == 2

		dispatch = variant.dispatch

		raise unless foo.refc == 3

		dispatch.QueryInstance(Foo) { |instance|
			raise unless foo.refc == 4

			raise unless instance.value == 42
		}.Release

		raise unless foo.refc == 3

		dispatch.Release

		raise unless foo.refc == 2

		variant.clear

		raise unless foo.refc == 1
	}

	foo.Release

	raise unless foo.refc == 0
}

Variant[:array, SafeArray.vector(2)].tap { |variant|
	array = variant.array

	array.
		put(0, Variant[:int, 42]).
		put(1, Variant[:array, SafeArray.vector(2).
			put(0, Variant[:int, 43]).
			put(1, Variant[:bstr, 'foo'])
		])

	raise unless array[0].int == 42
	raise unless array[1].array[0].int == 43
	raise unless array[1].array[1].bstr == 'foo'

	variant.clear
}

FFI::MemoryPointer.new(:int) { |pint|
	pint.write_int(0xc0ffee)

	Variant[:byref, pint].tap { |variant|
		raise unless variant.byref.address == pint.address
		raise unless variant.byref(:int) == 0xc0ffee
	}
}

Decimal[1.1].tap { |decimal|
	Variant[:byref, decimal].tap { |variant|
		raise unless Decimal.new(variant.byref).double == 1.1
	}
}

Variant[:object, [1, 2, 3, 4, 5]].tap { |variant|
	raise unless variant.object.inject(:+) == 15
}
