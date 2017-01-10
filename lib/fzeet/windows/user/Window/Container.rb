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
