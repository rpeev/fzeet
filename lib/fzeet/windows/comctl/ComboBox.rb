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
		CBM_FIRST = 0x1700

		CB_SETMINVISIBLE = CBM_FIRST + 1
		CB_GETMINVISIBLE = CBM_FIRST + 2
		CB_SETCUEBANNER = CBM_FIRST + 3
		CB_GETCUEBANNER = CBM_FIRST + 4
	end
end
