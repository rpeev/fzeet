require_relative 'Common'

module Fzeet
	module Windows
		UDS_WRAP = 0x0001
		UDS_SETBUDDYINT = 0x0002
		UDS_ALIGNRIGHT = 0x0004
		UDS_ALIGNLEFT = 0x0008
		UDS_AUTOBUDDY = 0x0010
		UDS_ARROWKEYS = 0x0020
		UDS_HORZ = 0x0040
		UDS_NOTHOUSANDS = 0x0080
		UDS_HOTTRACK = 0x0100

		UDM_SETRANGE = WM_USER + 101
		UDM_GETRANGE = WM_USER + 102
		UDM_SETPOS = WM_USER + 103
		UDM_GETPOS = WM_USER + 104
		UDM_SETBUDDY = WM_USER + 105
		UDM_GETBUDDY = WM_USER + 106
		UDM_SETACCEL = WM_USER + 107
		UDM_GETACCEL = WM_USER + 108
		UDM_SETBASE = WM_USER + 109
		UDM_GETBASE = WM_USER + 110
		UDM_SETRANGE32 = WM_USER + 111
		UDM_GETRANGE32 = WM_USER + 112
		UDM_SETUNICODEFORMAT = CCM_SETUNICODEFORMAT
		UDM_GETUNICODEFORMAT = CCM_GETUNICODEFORMAT
		UDM_SETPOS32 = WM_USER + 113
		UDM_GETPOS32 = WM_USER + 114

		UDN_FIRST = 0x1_0000_0000 - 721
		UDN_LAST = 0x1_0000_0000 - 729
		UDN_DELTAPOS = UDN_FIRST - 1

		class NMUPDOWN < FFI::Struct
			layout \
				:hdr, NMHDR,
				:iPos, :int,
				:iDelta, :int
		end
	end

	module UpDownMethods
		def buddy=(buddy) sendmsg(:setbuddy, buddy.handle) end

		def range=(range) sendmsg(:setrange, 0, Windows.MAKELONG(*range.reverse)) end

		def position=(position) sendmsg(:setpos32, 0, position) end
	end

	class UpDown < Control
		include UpDownMethods

		Prefix = {
			xstyle: [:ws_ex_],
			style: [:uds_, :ws_],
			message: [:udm_, :ccm_, :wm_],
			notification: [:udn_, :nm_]
		}

		def self.crackNotification(args) end

		def initialize(parent, id, opts = {}, &block)
			super('msctls_updown32', parent, id, opts)

			@parent.on(:notify, @id, &block) if block
		end

		def on(notification, &block)
			@parent.on(:notify, @id, Fzeet.constant(notification, *self.class::Prefix[:notification]), &block)

			self
		end
	end
end
