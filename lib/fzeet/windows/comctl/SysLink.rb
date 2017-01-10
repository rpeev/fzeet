require_relative 'Common'

module Fzeet
	module Windows
		LWS_TRANSPARENT = 0x0001
		LWS_IGNORERETURN = 0x0002
		LWS_NOPREFIX = 0x0004
		LWS_USEVISUALSTYLE = 0x0008
		LWS_USECUSTOMTEXT = 0x0010
		LWS_RIGHT = 0x0020

		LM_HITTEST = WM_USER + 0x300
		LM_GETIDEALHEIGHT = WM_USER + 0x301
		LM_SETITEM = WM_USER + 0x302
		LM_GETITEM = WM_USER + 0x303
		LM_GETIDEALSIZE = LM_GETIDEALHEIGHT

		class LITEM < FFI::Struct
			layout \
				:mask, :uint,
				:iLink, :int,
				:state, :uint,
				:stateMask, :uint,
				:szID, [:ushort, 48],
				:szUrl, [:ushort, 2048 + 32 + 4]
		end

		class NMLINK < FFI::Struct
			layout \
				:hdr, NMHDR,
				:item, LITEM
		end
	end

	module SysLinkMethods

	end

	class SysLink < Control
		include SysLinkMethods

		Prefix = {
			xstyle: [:ws_ex_],
			style: [:lws_, :ws_],
			message: [:lm_, :ccm_, :wm_],
			notification: [:nm_]
		}

		def self.crackNotification(args)
			case args[:notification]
			when Windows::NM_CLICK
				args[:link] = Windows::NMLINK.new(FFI::Pointer.new(args[:lParam]))

				args[:id] = Windows.WCSTOMBS(args[:link][:item][:szID])
				args[:url] = Windows.WCSTOMBS(args[:link][:item][:szUrl])
			end
		end

		def initialize(parent, id, opts = {}, &block)
			super('SysLink', parent, id, opts)

			@parent.on(:notify, @id, &block) if block
		end

		def on(notification, &block)
			@parent.on(:notify, @id, Fzeet.constant(notification, *self.class::Prefix[:notification]), &block)

			self
		end
	end
end
