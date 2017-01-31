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
	Frame = BasicWindow['Fzeet.Frame',
		wndProc: BasicWindow::FrameProc,
		background: SystemBrush.new(:appworkspace)
	]

	class Frame
		def initialize(opts = {})
			(opts[:style] ||= []) << :overlappedwindow << :clipsiblings << :clipchildren

			super
		end

		def activeChild
			((pchild = FFI::Pointer.new(Windows.SendMessage(client.handle, Windows::WM_MDIGETACTIVE, 0, 0))).null?) ?
				nil :
				Handle.instance(pchild)
		end

		def activate(child)
			Windows.SendMessage(client.handle, Windows::WM_MDIACTIVATE, child.handle.to_i, 0)

			self
		end
	end

	MDIChild = BasicWindow['Fzeet.MDIChild',
		wndProc: BasicWindow::MDIChildProc
	]

	class MDIChild
		def initialize(parent, opts = {})
			(opts[:xstyle] ||= []) << :mdichild
			(opts[:style] ||= []) << :child << :overlappedwindow << :clipsiblings << :clipchildren << :visible
			opts[:parent] = parent

			super(opts)
		end
	end
end
