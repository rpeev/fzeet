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
	Container = BasicWindow['Fzeet.Container']

	class Container
		def initialize(parent, opts = {})
			opts[:parent] = parent
			(opts[:style] ||= []) << :visible << :child << :clipsiblings << :clipchildren

			super(opts)

			style >> :caption >> :thickframe

			on(:erasebkgnd) { |args|
				Handle.wrap(FFI::Pointer.new(args[:wParam]), DCMethods).
					fillRect(
						rect,
						case @parent
						when Dialog; FFI::Pointer.new(Windows::CTLCOLOR_DLG + 1)
						when BasicWindow; FFI::Pointer.new(Windows.DetonateLastError(-1, :GetClassLong, @parent.handle, Windows::GCL_HBRBACKGROUND))
						end
					)

				args[:result] = 1
			}
		end
	end
end
