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
