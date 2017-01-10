require_relative 'Common'

module Fzeet
	module Windows
		BS_PUSHBUTTON = 0x00000000
		BS_DEFPUSHBUTTON = 0x00000001
		BS_CHECKBOX = 0x00000002
		BS_AUTOCHECKBOX = 0x00000003
		BS_RADIOBUTTON = 0x00000004
		BS_3STATE = 0x00000005
		BS_AUTO3STATE = 0x00000006
		BS_GROUPBOX = 0x00000007
		BS_USERBUTTON = 0x00000008
		BS_AUTORADIOBUTTON = 0x00000009
		BS_PUSHBOX = 0x0000000A
		BS_OWNERDRAW = 0x0000000B
		BS_TYPEMASK = 0x0000000F
		BS_LEFTTEXT = 0x00000020
		BS_TEXT = 0x00000000
		BS_ICON = 0x00000040
		BS_BITMAP = 0x00000080
		BS_LEFT = 0x00000100
		BS_RIGHT = 0x00000200
		BS_CENTER = 0x00000300
		BS_TOP = 0x00000400
		BS_BOTTOM = 0x00000800
		BS_VCENTER = 0x00000C00
		BS_PUSHLIKE = 0x00001000
		BS_MULTILINE = 0x00002000
		BS_NOTIFY = 0x00004000
		BS_FLAT = 0x00008000
		BS_RIGHTBUTTON = BS_LEFTTEXT

		BM_GETCHECK = 0x00F0
		BM_SETCHECK = 0x00F1
		BM_GETSTATE = 0x00F2
		BM_SETSTATE = 0x00F3
		BM_SETSTYLE = 0x00F4
		BM_CLICK = 0x00F5
		BM_GETIMAGE = 0x00F6
		BM_SETIMAGE = 0x00F7
		BM_SETDONTCLICK = 0x00F8

		BST_UNCHECKED = 0x0000
		BST_CHECKED = 0x0001
		BST_INDETERMINATE = 0x0002
		BST_PUSHED = 0x0004
		BST_FOCUS = 0x0008

		BN_CLICKED = 0
		BN_PAINT = 1
		BN_HILITE = 2
		BN_UNHILITE = 3
		BN_DISABLE = 4
		BN_DOUBLECLICKED = 5
		BN_PUSHED = BN_HILITE
		BN_UNPUSHED = BN_UNHILITE
		BN_DBLCLK = BN_DOUBLECLICKED
		BN_SETFOCUS = 6
		BN_KILLFOCUS = 7
	end

	module ButtonMethods
		def image=(image) sendmsg(:setimage, Windows::IMAGE_BITMAP, image.handle) end

		def note=(text) Windows.LPWSTR(text) { |p| sendmsg(:setnote, 0, p) } end

		def checked?; sendmsg(:getcheck) == Windows::BST_CHECKED end
		def checked=(checked) sendmsg(:setcheck, (checked) ? Windows::BST_CHECKED : Windows::BST_UNCHECKED) end

		def indeterminate?; sendmsg(:getcheck) == Windows::BST_INDETERMINATE end
		def indeterminate=(indeterminate) sendmsg(:setcheck, (indeterminate) ? Windows::BST_INDETERMINATE : Windows::BST_UNCHECKED) end

		def pushed?; (sendmsg(:getstate) & Windows::BST_PUSHED) == Windows::BST_PUSHED end
		def pushed=(pushed) sendmsg(:setstate, (pushed) ? 1 : 0) end
	end

	class Button < Control
		include ButtonMethods

		Prefix = {
			xstyle: [:ws_ex_],
			style: [:bs_, :ws_],
			message: [:bm_, :bcm_, :ccm_, :wm_],
			notification: [:bn_, :bcn_, :nm_]
		}

		def initialize(parent, id, opts = {}, &block)
			super('Button', parent, id, opts)

			width, height = 0, 0

			using(ScreenDC.new) { |dc| dc.select(Font) {
				minw = dc.textExtent('W' * 8).to_a[0]
				width, height = dc.textExtent("W#{text}W").to_a

				width = minw if width < minw; height = (height * 1.8).ceil
			}}

			self.location = 10, 10 if location.client!(parent).to_a == [0, 0]
			self.size = width, height if size.to_a == [0, 0]

			@parent.on(:command, @id, &block) if block
		end

		def on(notification, &block)
			if (notification = Fzeet.constant(notification, *self.class::Prefix[:notification])) < Windows::BCN_LAST
				@parent.on(:command, @id, notification, &block)
			else
				@parent.on(:notify, @id, notification, &block)
			end

			self
		end
	end
end
