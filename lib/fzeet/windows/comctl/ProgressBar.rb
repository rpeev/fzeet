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
		PBS_SMOOTH = 0x01
		PBS_VERTICAL = 0x04
		PBS_MARQUEE = 0x08
		PBS_SMOOTHREVERSE = 0x10

		PBM_SETRANGE = WM_USER + 1
		PBM_SETPOS = WM_USER + 2
		PBM_DELTAPOS = WM_USER + 3
		PBM_SETSTEP = WM_USER + 4
		PBM_STEPIT = WM_USER + 5
		PBM_SETRANGE32 = WM_USER + 6
		PBM_GETRANGE = WM_USER + 7
		PBM_GETPOS = WM_USER + 8
		PBM_SETBARCOLOR = WM_USER + 9
		PBM_SETBKCOLOR = CCM_SETBKCOLOR
		PBM_SETMARQUEE = WM_USER + 10
		PBM_GETSTEP = WM_USER + 13
		PBM_GETBKCOLOR = WM_USER + 14
		PBM_GETBARCOLOR = WM_USER + 15
		PBM_SETSTATE = WM_USER + 16
		PBM_GETSTATE = WM_USER + 17

		PBST_NORMAL = 0x0001
		PBST_ERROR = 0x0002
		PBST_PAUSED = 0x0003
	end

	module ProgressBarMethods
		def step=(step) sendmsg(:setstep, step) end
		def step!; sendmsg(:stepit) end

		def position=(position) sendmsg(:setpos, position) end

		def marquee?; @marquee end
		def marquee=(marquee) sendmsg(:setmarquee, (@marquee = marquee) ? 1 : 0) end
	end

	class ProgressBar < Control
		include ProgressBarMethods

		Prefix = {
			xstyle: [:ws_ex_],
			style: [:pbs_, :ws_],
			message: [:pbm_, :ccm_, :wm_],
			notification: [:nm_]
		}

		def self.crackNotification(args) end

		def initialize(parent, id, opts = {}, &block)
			super('msctls_progress32', parent, id, opts)

			@marquee = false

			@parent.on(:notify, @id, &block) if block
		end

		def on(notification, &block)
			@parent.on(:notify, @id, Fzeet.constant(notification, *self.class::Prefix[:notification]), &block)

			self
		end
	end
end
