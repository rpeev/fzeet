require_relative 'Common'

module Fzeet
	module Windows
		attach_function :CreateMenu, [], :pointer
		attach_function :CreatePopupMenu, [], :pointer
		attach_function :DestroyMenu, [:pointer], :int

		MF_INSERT = 0x00000000
		MF_CHANGE = 0x00000080
		MF_APPEND = 0x00000100
		MF_DELETE = 0x00000200
		MF_REMOVE = 0x00001000
		MF_BYCOMMAND = 0x00000000
		MF_BYPOSITION = 0x00000400
		MF_SEPARATOR = 0x00000800
		MF_ENABLED = 0x00000000
		MF_GRAYED = 0x00000001
		MF_DISABLED = 0x00000002
		MF_UNCHECKED = 0x00000000
		MF_CHECKED = 0x00000008
		MF_USECHECKBITMAPS = 0x00000200
		MF_STRING = 0x00000000
		MF_BITMAP = 0x00000004
		MF_OWNERDRAW = 0x00000100
		MF_POPUP = 0x00000010
		MF_MENUBARBREAK = 0x00000020
		MF_MENUBREAK = 0x00000040
		MF_UNHILITE = 0x00000000
		MF_HILITE = 0x00000080
		MF_DEFAULT = 0x00001000
		MF_SYSMENU = 0x00002000
		MF_HELP = 0x00004000
		MF_RIGHTJUSTIFY = 0x00004000
		MF_MOUSESELECT = 0x00008000
		MF_END = 0x00000080

		MFT_STRING = MF_STRING
		MFT_BITMAP = MF_BITMAP
		MFT_MENUBARBREAK = MF_MENUBARBREAK
		MFT_MENUBREAK = MF_MENUBREAK
		MFT_OWNERDRAW = MF_OWNERDRAW
		MFT_RADIOCHECK = 0x00000200
		MFT_SEPARATOR = MF_SEPARATOR
		MFT_RIGHTORDER = 0x00002000
		MFT_RIGHTJUSTIFY = MF_RIGHTJUSTIFY

		MFS_GRAYED = 0x00000003
		MFS_DISABLED = MFS_GRAYED
		MFS_CHECKED = MF_CHECKED
		MFS_HILITE = MF_HILITE
		MFS_ENABLED = MF_ENABLED
		MFS_UNCHECKED = MF_UNCHECKED
		MFS_UNHILITE = MF_UNHILITE
		MFS_DEFAULT = MF_DEFAULT

		attach_function :AppendMenu, :AppendMenuA, [:pointer, :uint, :uint, :string], :int
		attach_function :GetMenuState, [:pointer, :uint, :uint], :uint
		attach_function :EnableMenuItem, [:pointer, :uint, :uint], :int
		attach_function :CheckMenuItem, [:pointer, :uint, :uint], :ulong
		attach_function :CheckMenuRadioItem, [:pointer, :uint, :uint, :uint, :uint], :int

		MIIM_STATE = 0x00000001
		MIIM_ID = 0x00000002
		MIIM_SUBMENU = 0x00000004
		MIIM_CHECKMARKS = 0x00000008
		MIIM_TYPE = 0x00000010
		MIIM_DATA = 0x00000020
		MIIM_STRING = 0x00000040
		MIIM_BITMAP = 0x00000080
		MIIM_FTYPE = 0x00000100

		class MENUITEMINFO < FFI::Struct
			layout \
				:cbSize, :uint,
				:fMask, :uint,
				:fType, :uint,
				:fState, :uint,
				:wID, :uint,
				:hSubMenu, :pointer,
				:hbmpChecked, :pointer,
				:hbmpUnchecked, :pointer,
				:dwItemData, :ulong,
				:dwTypeData, :pointer,
				:cch, :uint,
				:hbmpItem, :pointer
		end

		attach_function :GetMenuItemInfo, :GetMenuItemInfoA, [:pointer, :uint, :int, :pointer], :int
		attach_function :SetMenuItemInfo, :SetMenuItemInfoA, [:pointer, :uint, :int, :pointer], :int

		TPM_LEFTBUTTON = 0x0000
		TPM_RIGHTBUTTON = 0x0002
		TPM_LEFTALIGN = 0x0000
		TPM_CENTERALIGN = 0x0004
		TPM_RIGHTALIGN = 0x0008
		TPM_TOPALIGN = 0x0000
		TPM_VCENTERALIGN = 0x0010
		TPM_BOTTOMALIGN = 0x0020
		TPM_HORIZONTAL = 0x0000
		TPM_VERTICAL = 0x0040
		TPM_NONOTIFY = 0x0080
		TPM_RETURNCMD = 0x0100
		TPM_RECURSE = 0x0001
		TPM_HORPOSANIMATION = 0x0400
		TPM_HORNEGANIMATION = 0x0800
		TPM_VERPOSANIMATION = 0x1000
		TPM_VERNEGANIMATION = 0x2000
		TPM_NOANIMATION = 0x4000
		TPM_LAYOUTRTL = 0x8000
		TPM_WORKAREA = 0x10000

		attach_function :TrackPopupMenu, [:pointer, :uint, :int, :int, :int, :pointer, :pointer], :int

		module MenuMethods
			def rdetach; submenus.each(&:rdetach); detach end

			class Item
				def initialize(menu, id) @menu, @id = menu, Command[id] end

				attr_reader :menu, :id

				def enabled?
					flags = Windows.DetonateLastError(-1, :GetMenuState, @menu.handle, @id, 0)

					(flags & Windows::MF_GRAYED) != Windows::MF_GRAYED
				end

				def enabled=(enabled)
					Windows.DetonateLastError(-1, :EnableMenuItem,
						@menu.handle,
						@id,
						(enabled) ? Windows::MF_ENABLED : Windows::MF_GRAYED
					)
				end

				def checked?
					flags = Windows.DetonateLastError(-1, :GetMenuState, @menu.handle, @id, 0)

					(flags & Windows::MF_CHECKED) == Windows::MF_CHECKED
				end

				def checked=(checked)
					Windows.DetonateLastError(-1, :CheckMenuItem,
						@menu.handle,
						@id,
						(checked) ? Windows::MF_CHECKED : Windows::MF_UNCHECKED
					)
				end

				def select(first, last)
					Windows.DetonateLastError(0, :CheckMenuRadioItem,
						@menu.handle, Command[first], Command[last], @id, 0
					)

					self
				end

				def info(mask)
					Windows.DetonateLastError(0, :GetMenuItemInfo,
						@menu.handle,
						@id,
						0,
						info = Windows::MENUITEMINFO.new.tap { |mii|
							mii[:cbSize] = mii.size
							mii[:fMask] = Fzeet.constant(mask, :miim_)
						}
					)

					info
				end

				def info=(mii)
					Windows.DetonateLastError(0, :SetMenuItemInfo,
						@menu.handle,
						@id,
						0,
						mii.tap { mii[:cbSize] = mii.size }
					)
				end

				def image; (Handle.instance?(handle = info(:bitmap)[:hbmpItem])) ? Handle.instance(handle) : nil end

				def image=(image)
					self.info = Windows::MENUITEMINFO.new.tap { |mii|
						mii[:fMask] = Windows::MIIM_BITMAP
						mii[:hbmpItem] = image.handle
					}
				end
			end

			def [](id) Item.new(self, id) end

			def append(flags, item = nil, id = 0)
				Windows.DetonateLastError(0, :AppendMenu,
					@handle,
					Fzeet.flags(flags, :mf_, :mft_, :mfs_),
					case id
					when Integer; id
					when Symbol; Command[id]
					when Windows::MenuMethods; submenus << id; id.handle.to_i
					else raise ArgumentError
					end,
					item
				)

				self
			end

			def images=(images) images.each { |id, image| self[id].image = image } end
		end
	end

	Windows::MenuMethods::Item.send(:include, Toggle)

	class Menu < Handle
		include Windows::MenuMethods

		def initialize
			@submenus = []

			@handle = Windows.DetonateLastError(FFI::Pointer::NULL, :CreateMenu); attach
		end

		attr_reader :submenus

		def dispose; Windows.DestroyMenu(@handle); rdetach end
	end

	class PopupMenu < Handle
		include Windows::MenuMethods

		def initialize
			@submenus = []

			@handle = Windows.DetonateLastError(FFI::Pointer::NULL, :CreatePopupMenu); attach
		end

		attr_reader :submenus

		def dispose; Windows.DestroyMenu(@handle); rdetach end

		def track(window, x, y, flags = 0) Windows.TrackPopupMenu(@handle, Fzeet.flags(flags, :tpm_), x, y, 0, window.handle, nil); self end
	end
end
