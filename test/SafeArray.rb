require_relative '../lib/fzeet'

include Fzeet

SafeArray.vector(2).tap { |sa|
	raise unless sa[:cDims] == 1
	raise unless sa.length == 2
	raise unless sa.vt == Windows::VT_VARIANT

	sa[0] = Variant[:int, 42]
	raise unless sa[0].int == 42

	sa[1] = Variant[:bstr, 'foo']
	raise unless sa[1].bstr == 'foo'

	sa.dispose
}

raise unless SafeArray.vector(2) { |sa|
	raise unless sa.length == 2
}.nil?

SafeArray.vector(5) { |sa|
	(1..5).each.with_index { |v, i| sa[i] = Variant[:int, v] }

	raise unless sa.inject(1) { |product, variant| product *= variant.int } == 120
}
