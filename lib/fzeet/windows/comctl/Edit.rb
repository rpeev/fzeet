if __FILE__ == $0
	require 'ffi'

	# FIXME: dirty fix to propagate FFI structs layout down the inheritance hierarchy
	# TODO: switch to composition instead inheriting FFI structs
	module PropagateFFIStructLayout
		def inherited(child_class)
			child_class.instance_variable_set '@layout', layout
		end
	end

	class FFI::Struct
		def self.inherited(child_class)
			child_class.extend PropagateFFIStructLayout
		end
	end
	# END FIXME
end

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
