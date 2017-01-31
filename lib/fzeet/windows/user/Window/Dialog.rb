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
	Dialog = BasicWindow['Fzeet.Dialog',
		wndProc: BasicWindow::DialogProc
	]

	class Dialog
		def initialize(parent, opts = {}, &block)
			@parent = parent

			_opts = {
				xstyle: [:noparentnotify],
				caption: Application.name,
				style: [:sysmenu, :visible],
				x: 0,
				y: 0,
				width: 200,
				height: 150,
				modal: false
			}
			badopts = opts.keys - _opts.keys; raise "Bad option(s): #{badopts.join(', ')}." unless badopts.empty?
			_opts.merge!(opts)

			_opts[:xstyle] = Fzeet.flags(_opts[:xstyle], *self.class::Prefix[:xstyle])
			_opts[:caption] = _opts[:caption].to_s
			_opts[:style] = Fzeet.flags(_opts[:style], *self.class::Prefix[:style])

			@messages ||= {}
			@commands ||= {}
			@notifies ||= {}

			@processed = [0, 0]

			dt = Windows::DLGTEMPLATE.new

			dt[:style] = _opts[:style]
			dt[:dwExtendedStyle] = _opts[:xstyle]
			dt[:x] = _opts[:x]
			dt[:y] = _opts[:y]
			dt[:cx] = _opts[:width]
			dt[:cy] = _opts[:height]

			on(:initdialog) { self.text = _opts[:caption] }

			on(:initdialog, &block) if block

			unless _opts[:modal]
				@handle = Windows.DetonateLastError(FFI::Pointer::NULL, :CreateDialogIndirectParam,
					Windows.GetModuleHandle(nil),
					dt,
					@parent && @parent.handle,
					BasicWindow::DialogProc,
					object_id
				)

				self.dialog = true
			else
				@result = Windows.DetonateLastError([-1, 0], :DialogBoxIndirectParam,
					Windows.GetModuleHandle(nil),
					dt,
					@parent && @parent.handle,
					BasicWindow::DialogProc,
					object_id
				)
			end
		end

		def end(result) Windows.DetonateLastError(0, :EndDialog, @handle, Command[result]); self end

		def result; DialogResult.new(@result) end
	end
end
