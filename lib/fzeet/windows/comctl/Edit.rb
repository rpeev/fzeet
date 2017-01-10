require_relative 'Common'

module Fzeet
	module Windows
		ECM_FIRST = 0x1500

		EM_SETCUEBANNER = ECM_FIRST + 1
		EM_GETCUEBANNER = ECM_FIRST + 2
		EM_SHOWBALLOONTIP = ECM_FIRST + 3
		EM_HIDEBALLOONTIP = ECM_FIRST + 4

		class EDITBALLOONTIP < FFI::Struct
			layout \
				:cbStruct, :ulong,
				:pszTitle, :pointer,
				:pszText, :pointer,
				:ttiIcon, :int
		end
	end
end
