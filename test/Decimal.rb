require_relative '../lib/fzeet'

include Fzeet

Decimal[42].tap { |decimal|
	raise unless decimal.int == 42
}

Decimal[-42].tap { |decimal|
	raise unless decimal.int == -42
}

Decimal[0x7fff_ffff_ffff_ffff].tap { |decimal|
	raise unless decimal.longlong == 0x7fff_ffff_ffff_ffff
}

Decimal[-0x7fff_ffff_ffff_ffff].tap { |decimal|
	raise unless decimal.longlong == -0x7fff_ffff_ffff_ffff
}

Decimal[1.1].tap { |decimal|
	raise unless decimal.double == 1.1
}

Decimal[-1.1].tap { |decimal|
	raise unless decimal.double == -1.1
}
