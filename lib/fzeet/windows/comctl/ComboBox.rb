require_relative 'Common'

module Fzeet
	module Windows
		CBM_FIRST = 0x1700

		CB_SETMINVISIBLE = CBM_FIRST + 1
		CB_GETMINVISIBLE = CBM_FIRST + 2
		CB_SETCUEBANNER = CBM_FIRST + 3
		CB_GETCUEBANNER = CBM_FIRST + 4
	end
end
