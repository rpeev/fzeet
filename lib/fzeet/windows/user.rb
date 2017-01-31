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

require_relative 'user/MessageBox'
require_relative 'user/Window'
require_relative 'user/Message'
require_relative 'user/Menu'
require_relative 'user/Accelerator'
require_relative 'user/Control'
require_relative 'user/SystemParametersInfo'

module Fzeet
	class Command
		@ids = {
			OK: Windows::IDOK,
			CANCEL: Windows::IDCANCEL,
		}
		@nextId = Windows::WM_APP + 1

		def self.[](id)
			return id if id.kind_of?(Integer)

			id = id.upcase

			@ids[id], @nextId = @nextId, @nextId + 1 unless @ids.include?(id)

			@ids[id]
		end
	end
end
