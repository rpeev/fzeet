require_relative '../lib/fzeet'

include Fzeet

Windows::OSVERSIONINFOEX.new.tap { |ovi|
	ovi[:dwMajorVersion] = 5
	ovi[:dwMinorVersion] = 2

	raise unless ovi.hex == 0x0502
	raise unless ovi >= :xp
	raise unless ovi > 2000
	raise unless ovi < :vista
	raise unless ovi.name == 'Windows XP'
}
