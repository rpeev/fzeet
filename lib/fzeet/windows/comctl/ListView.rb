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
		LVS_ICON = 0x0000
		LVS_REPORT = 0x0001
		LVS_SMALLICON = 0x0002
		LVS_LIST = 0x0003
		LVS_TYPEMASK = 0x0003
		LVS_SINGLESEL = 0x0004
		LVS_SHOWSELALWAYS = 0x0008
		LVS_SORTASCENDING = 0x0010
		LVS_SORTDESCENDING = 0x0020
		LVS_SHAREIMAGELISTS = 0x0040
		LVS_NOLABELWRAP = 0x0080
		LVS_AUTOARRANGE = 0x0100
		LVS_EDITLABELS = 0x0200
		LVS_OWNERDATA = 0x1000
		LVS_NOSCROLL = 0x2000
		LVS_TYPESTYLEMASK = 0xfc00
		LVS_ALIGNTOP = 0x0000
		LVS_ALIGNLEFT = 0x0800
		LVS_ALIGNMASK = 0x0c00
		LVS_OWNERDRAWFIXED = 0x0400
		LVS_NOCOLUMNHEADER = 0x4000
		LVS_NOSORTHEADER = 0x8000

		LVS_EX_GRIDLINES = 0x00000001
		LVS_EX_SUBITEMIMAGES = 0x00000002
		LVS_EX_CHECKBOXES = 0x00000004
		LVS_EX_TRACKSELECT = 0x00000008
		LVS_EX_HEADERDRAGDROP = 0x00000010
		LVS_EX_FULLROWSELECT = 0x00000020
		LVS_EX_ONECLICKACTIVATE = 0x00000040
		LVS_EX_TWOCLICKACTIVATE = 0x00000080
		LVS_EX_FLATSB = 0x00000100
		LVS_EX_REGIONAL = 0x00000200
		LVS_EX_INFOTIP = 0x00000400
		LVS_EX_UNDERLINEHOT = 0x00000800
		LVS_EX_UNDERLINECOLD = 0x00001000
		LVS_EX_MULTIWORKAREAS = 0x00002000
		LVS_EX_LABELTIP = 0x00004000
		LVS_EX_BORDERSELECT = 0x00008000
		LVS_EX_DOUBLEBUFFER = 0x00010000
		LVS_EX_HIDELABELS = 0x00020000
		LVS_EX_SINGLEROW = 0x00040000
		LVS_EX_SNAPTOGRID = 0x00080000
		LVS_EX_SIMPLESELECT = 0x00100000
		LVS_EX_JUSTIFYCOLUMNS = 0x00200000
		LVS_EX_TRANSPARENTBKGND = 0x00400000
		LVS_EX_TRANSPARENTSHADOWTEXT = 0x00800000
		LVS_EX_AUTOAUTOARRANGE = 0x01000000
		LVS_EX_HEADERINALLVIEWS = 0x02000000
		LVS_EX_AUTOCHECKSELECT = 0x08000000
		LVS_EX_AUTOSIZECOLUMNS = 0x10000000
		LVS_EX_COLUMNSNAPPOINTS = 0x40000000
		LVS_EX_COLUMNOVERFLOW = 0x80000000

		LVM_FIRST = 0x1000
		LVM_SETUNICODEFORMAT = CCM_SETUNICODEFORMAT
		LVM_GETUNICODEFORMAT = CCM_GETUNICODEFORMAT
		LVM_GETBKCOLOR = LVM_FIRST + 0
		LVM_SETBKCOLOR = LVM_FIRST + 1
		LVM_GETIMAGELIST = LVM_FIRST + 2
		LVM_SETIMAGELIST = LVM_FIRST + 3
		LVM_GETITEMCOUNT = LVM_FIRST + 4
		LVM_GETITEM = LVM_FIRST + 5
		LVM_SETITEM = LVM_FIRST + 6
		LVM_INSERTITEM = LVM_FIRST + 7
		LVM_DELETEITEM = LVM_FIRST + 8
		LVM_DELETEALLITEMS = LVM_FIRST + 9
		LVM_GETCALLBACKMASK = LVM_FIRST + 10
		LVM_SETCALLBACKMASK = LVM_FIRST + 11
		LVM_GETNEXTITEM = LVM_FIRST + 12
		LVM_FINDITEM = LVM_FIRST + 13
		LVM_GETITEMRECT = LVM_FIRST + 14
		LVM_SETITEMPOSITION = LVM_FIRST + 15
		LVM_GETITEMPOSITION = LVM_FIRST + 16
		LVM_GETSTRINGWIDTH = LVM_FIRST + 17
		LVM_HITTEST = LVM_FIRST + 18
		LVM_ENSUREVISIBLE = LVM_FIRST + 19
		LVM_SCROLL = LVM_FIRST + 20
		LVM_REDRAWITEMS = LVM_FIRST + 21
		LVM_ARRANGE = LVM_FIRST + 22
		LVM_EDITLABEL = LVM_FIRST + 23
		LVM_GETEDITCONTROL = LVM_FIRST + 24
		LVM_GETCOLUMN = LVM_FIRST + 25
		LVM_SETCOLUMN = LVM_FIRST + 26
		LVM_INSERTCOLUMN = LVM_FIRST + 27
		LVM_DELETECOLUMN = LVM_FIRST + 28
		LVM_GETCOLUMNWIDTH = LVM_FIRST + 29
		LVM_SETCOLUMNWIDTH = LVM_FIRST + 30
		LVM_GETHEADER = LVM_FIRST + 31
		LVM_CREATEDRAGIMAGE = LVM_FIRST + 33
		LVM_GETVIEWRECT = LVM_FIRST + 34
		LVM_GETTEXTCOLOR = LVM_FIRST + 35
		LVM_SETTEXTCOLOR = LVM_FIRST + 36
		LVM_GETTEXTBKCOLOR = LVM_FIRST + 37
		LVM_SETTEXTBKCOLOR = LVM_FIRST + 38
		LVM_GETTOPINDEX = LVM_FIRST + 39
		LVM_GETCOUNTPERPAGE = LVM_FIRST + 40
		LVM_GETORIGIN = LVM_FIRST + 41
		LVM_UPDATE = LVM_FIRST + 42
		LVM_SETITEMSTATE = LVM_FIRST + 43
		LVM_GETITEMSTATE = LVM_FIRST + 44
		LVM_GETITEMTEXT = LVM_FIRST + 45
		LVM_SETITEMTEXT = LVM_FIRST + 46
		LVM_SETITEMCOUNT = LVM_FIRST + 47
		LVM_SORTITEMS = LVM_FIRST + 48
		LVM_SETITEMPOSITION32 = LVM_FIRST + 49
		LVM_GETSELECTEDCOUNT = LVM_FIRST + 50
		LVM_GETITEMSPACING = LVM_FIRST + 51
		LVM_GETISEARCHSTRING = LVM_FIRST + 52
		LVM_SETICONSPACING = LVM_FIRST + 53
		LVM_SETEXTENDEDLISTVIEWSTYLE = LVM_FIRST + 54
		LVM_GETEXTENDEDLISTVIEWSTYLE = LVM_FIRST + 55
		LVM_GETSUBITEMRECT = LVM_FIRST + 56
		LVM_SUBITEMHITTEST = LVM_FIRST + 57
		LVM_SETCOLUMNORDERARRAY = LVM_FIRST + 58
		LVM_GETCOLUMNORDERARRAY = LVM_FIRST + 59
		LVM_SETHOTITEM = LVM_FIRST + 60
		LVM_GETHOTITEM = LVM_FIRST + 61
		LVM_SETHOTCURSOR = LVM_FIRST + 62
		LVM_GETHOTCURSOR = LVM_FIRST + 63
		LVM_APPROXIMATEVIEWRECT = LVM_FIRST + 64
		LVM_SETWORKAREAS = LVM_FIRST + 65
		LVM_GETWORKAREAS = LVM_FIRST + 70
		LVM_GETNUMBEROFWORKAREAS = LVM_FIRST + 73
		LVM_GETSELECTIONMARK = LVM_FIRST + 66
		LVM_SETSELECTIONMARK = LVM_FIRST + 67
		LVM_SETHOVERTIME = LVM_FIRST + 71
		LVM_GETHOVERTIME = LVM_FIRST + 72
		LVM_SETTOOLTIPS = LVM_FIRST + 74
		LVM_GETTOOLTIPS = LVM_FIRST + 78
		LVM_SORTITEMSEX = LVM_FIRST + 81
		LVM_SETBKIMAGE = LVM_FIRST + 68
		LVM_GETBKIMAGE = LVM_FIRST + 69
		LVM_SETSELECTEDCOLUMN = LVM_FIRST + 140
		LVM_SETVIEW = LVM_FIRST + 142
		LVM_GETVIEW = LVM_FIRST + 143
		LVM_INSERTGROUP = LVM_FIRST + 145
		LVM_SETGROUPINFO = LVM_FIRST + 147
		LVM_GETGROUPINFO = LVM_FIRST + 149
		LVM_REMOVEGROUP = LVM_FIRST + 150
		LVM_MOVEGROUP = LVM_FIRST + 151
		LVM_GETGROUPCOUNT = LVM_FIRST + 152
		LVM_GETGROUPINFOBYINDEX = LVM_FIRST + 153
		LVM_MOVEITEMTOGROUP = LVM_FIRST + 154
		LVM_GETGROUPRECT = LVM_FIRST + 98
		LVM_SETGROUPMETRICS = LVM_FIRST + 155
		LVM_GETGROUPMETRICS = LVM_FIRST + 156
		LVM_ENABLEGROUPVIEW = LVM_FIRST + 157
		LVM_SORTGROUPS = LVM_FIRST + 158
		LVM_INSERTGROUPSORTED = LVM_FIRST + 159
		LVM_REMOVEALLGROUPS = LVM_FIRST + 160
		LVM_HASGROUP = LVM_FIRST + 161
		LVM_GETGROUPSTATE = LVM_FIRST + 92
		LVM_GETFOCUSEDGROUP = LVM_FIRST + 93
		LVM_SETTILEVIEWINFO = LVM_FIRST + 162
		LVM_GETTILEVIEWINFO = LVM_FIRST + 163
		LVM_SETTILEINFO = LVM_FIRST + 164
		LVM_GETTILEINFO = LVM_FIRST + 165
		LVM_SETINSERTMARK = LVM_FIRST + 166
		LVM_GETINSERTMARK = LVM_FIRST + 167
		LVM_INSERTMARKHITTEST = LVM_FIRST + 168
		LVM_GETINSERTMARKRECT = LVM_FIRST + 169
		LVM_SETINSERTMARKCOLOR = LVM_FIRST + 170
		LVM_GETINSERTMARKCOLOR = LVM_FIRST + 171
		LVM_SETINFOTIP = LVM_FIRST + 173
		LVM_GETSELECTEDCOLUMN = LVM_FIRST + 174
		LVM_ISGROUPVIEWENABLED = LVM_FIRST + 175
		LVM_GETOUTLINECOLOR = LVM_FIRST + 176
		LVM_SETOUTLINECOLOR = LVM_FIRST + 177
		LVM_CANCELEDITLABEL = LVM_FIRST + 179
		LVM_MAPINDEXTOID = LVM_FIRST + 180
		LVM_MAPIDTOINDEX = LVM_FIRST + 181
		LVM_ISITEMVISIBLE = LVM_FIRST + 182
		LVM_GETEMPTYTEXT = LVM_FIRST + 204
		LVM_GETFOOTERRECT = LVM_FIRST + 205
		LVM_GETFOOTERINFO = LVM_FIRST + 206
		LVM_GETFOOTERITEMRECT = LVM_FIRST + 207
		LVM_GETFOOTERITEM = LVM_FIRST + 208
		LVM_GETITEMINDEXRECT = LVM_FIRST + 209
		LVM_SETITEMINDEXSTATE = LVM_FIRST + 210
		LVM_GETNEXTITEMINDEX = LVM_FIRST + 211

		LVN_FIRST = 0x1_0000_0000 - 100
		LVN_LAST = 0x1_0000_0000 - 199
		LVN_ITEMCHANGING = LVN_FIRST - 0
		LVN_ITEMCHANGED = LVN_FIRST - 1
		LVN_INSERTITEM = LVN_FIRST - 2
		LVN_DELETEITEM = LVN_FIRST - 3
		LVN_DELETEALLITEMS = LVN_FIRST - 4
		LVN_BEGINLABELEDIT = LVN_FIRST - 5
		LVN_ENDLABELEDIT = LVN_FIRST - 6
		LVN_COLUMNCLICK = LVN_FIRST - 8
		LVN_BEGINDRAG = LVN_FIRST - 9
		LVN_BEGINRDRAG = LVN_FIRST - 11
		LVN_ODCACHEHINT = LVN_FIRST - 13
		LVN_ODFINDITEM = LVN_FIRST - 52
		LVN_ITEMACTIVATE = LVN_FIRST - 14
		LVN_ODSTATECHANGED = LVN_FIRST - 15
		LVN_HOTTRACK = LVN_FIRST - 21
		LVN_GETDISPINFO = LVN_FIRST - 50
		LVN_SETDISPINFO = LVN_FIRST - 51
		LVN_KEYDOWN = LVN_FIRST - 55
		LVN_MARQUEEBEGIN = LVN_FIRST - 56
		LVN_GETINFOTIP = LVN_FIRST - 57
		LVN_INCREMENTALSEARCH = LVN_FIRST - 62
		LVN_COLUMNDROPDOWN = LVN_FIRST - 64
		LVN_COLUMNOVERFLOWCLICK = LVN_FIRST - 66
		LVN_BEGINSCROLL = LVN_FIRST - 80
		LVN_ENDSCROLL = LVN_FIRST - 81
		LVN_LINKCLICK = LVN_FIRST - 84
		LVN_GETEMPTYMARKUP = LVN_FIRST - 87

		LVCF_FMT = 0x0001
		LVCF_WIDTH = 0x0002
		LVCF_TEXT = 0x0004
		LVCF_SUBITEM = 0x0008
		LVCF_IMAGE = 0x0010
		LVCF_ORDER = 0x0020
		LVCF_MINWIDTH = 0x0040
		LVCF_DEFAULTWIDTH = 0x0080
		LVCF_IDEALWIDTH = 0x0100

		LVCFMT_LEFT = 0x0000
		LVCFMT_RIGHT = 0x0001
		LVCFMT_CENTER = 0x0002
		LVCFMT_JUSTIFYMASK = 0x0003
		LVCFMT_IMAGE = 0x0800
		LVCFMT_BITMAP_ON_RIGHT = 0x1000
		LVCFMT_COL_HAS_IMAGES = 0x8000
		LVCFMT_FIXED_WIDTH = 0x00100
		LVCFMT_NO_DPI_SCALE = 0x40000
		LVCFMT_FIXED_RATIO = 0x80000
		LVCFMT_LINE_BREAK = 0x100000
		LVCFMT_FILL = 0x200000
		LVCFMT_WRAP = 0x400000
		LVCFMT_NO_TITLE = 0x800000
		LVCFMT_TILE_PLACEMENTMASK = LVCFMT_LINE_BREAK | LVCFMT_FILL
		LVCFMT_SPLITBUTTON = 0x1000000

		class LVCOLUMN < FFI::Struct
			layout(*[
				:mask, :uint,
				:fmt, :int,
				:cx, :int,
				:pszText, :pointer,
				:cchTextMax, :int,
				:iSubItem, :int,
				:iImage, :int,
				:iOrder, :int,
				(Version >= :vista) ? [
					:cxMin, :int,
					:cxDefault, :int,
					:cxIdeal, :int
				] : nil
			].flatten.compact)
		end

		LVIF_TEXT = 0x00000001
		LVIF_IMAGE = 0x00000002
		LVIF_PARAM = 0x00000004
		LVIF_STATE = 0x00000008
		LVIF_INDENT = 0x00000010
		LVIF_NORECOMPUTE = 0x00000800
		LVIF_GROUPID = 0x00000100
		LVIF_COLUMNS = 0x00000200
		LVIF_COLFMT = 0x00010000

		LVIS_FOCUSED = 0x0001
		LVIS_SELECTED = 0x0002
		LVIS_CUT = 0x0004
		LVIS_DROPHILITED = 0x0008
		LVIS_GLOW = 0x0010
		LVIS_ACTIVATING = 0x0020
		LVIS_OVERLAYMASK = 0x0F00
		LVIS_STATEIMAGEMASK = 0xF000

		class LVITEM < FFI::Struct
			layout(*[
				:mask, :uint,
				:iItem, :int,
				:iSubItem, :int,
				:state, :uint,
				:stateMask, :uint,
				:pszText, :pointer,
				:cchTextMax, :int,
				:iImage, :int,
				:lParam, :long,
				:iIndent, :int,
				(Version >= :xp) ? [
					:iGroupId, :int,
					:cColumns, :uint,
					:puColumns, :pointer,
				] : nil,
				(Version >= :vista) ? [
					:piColFmt, :pointer,
					:iGroup, :int
				] : nil
			].flatten.compact)
		end

		class NMLISTVIEW < FFI::Struct
			layout \
				:hdr, NMHDR,
				:iItem, :int,
				:iSubItem, :int,
				:uNewState, :uint,
				:uOldState, :uint,
				:uChanged, :uint,
				:ptAction, POINT,
				:lParam, :long
		end
	end

	module ListViewMethods
		class ExStyle
			def initialize(listview) @listview = listview end

			def <<(xstyle)
				@listview.sendmsg(:setextendedlistviewstyle, 0,
					@listview.sendmsg(:getextendedlistviewstyle) | Fzeet.constant(xstyle, *@listview.class::Prefix[:xstyle])
				)

				self
			end

			def >>(xstyle)
				@listview.sendmsg(:setextendedlistviewstyle, 0,
					@listview.sendmsg(:getextendedlistviewstyle) & ~Fzeet.constant(xstyle, *@listview.class::Prefix[:xstyle])
				)

				self
			end

			def toggle(what) send((@listview.xstyle?(what)) ? :>> : :<<, what); self end
		end

		def xstyle?(xstyle) (sendmsg(:getextendedlistviewstyle) & (xstyle = Fzeet.constant(xstyle, *self.class::Prefix[:xstyle]))) == xstyle end
		def xstyle; ExStyle.new(self) end

		def insertColumn(i, text, width)
			lvc = Windows::LVCOLUMN.new

			lvc[:mask] = Fzeet.flags([:fmt, :width, :text, :subitem], :lvcf_)
			lvc[:fmt] = Fzeet.flags(:left, :lvcfmt_)
			lvc[:cx] = width
			lvc[:pszText] = ptext = FFI::MemoryPointer.from_string(text)
			lvc[:iSubItem] = i

			sendmsg(:insertcolumn, 0, lvc.pointer)

			self
		ensure
			ptext.free if ptext
		end

		class Item
			def initialize(lvi) @subitems = [lvi] end

			attr_reader :subitems
		end

		def insertItem(i, j, text)
			lvi = Windows::LVITEM.new

			lvi[:mask] = Fzeet.flags(:text, :lvif_)
			lvi[:iItem] = i
			lvi[:iSubItem] = j
			lvi[:pszText] = ptext = FFI::MemoryPointer.from_string(text)

			if j == 0
				@items << Item.new(lvi)

				lvi[:mask] |= Windows::LVIF_PARAM
				lvi[:lParam] = @items[i].object_id

				sendmsg(:insertitem, 0, lvi.pointer)
			else
				@items[i].subitems << lvi

				sendmsg(:setitem, 0, lvi.pointer)
			end

			@items[i].subitems[j].instance_variable_set(:@text, text)

			class << @items[i].subitems[j]
				attr_reader :text
			end

			self
		ensure
			ptext.free if ptext
		end

		def sort(j = 0)
			sendmsg(:sortitems, j,
				FFI::Function.new(:int, [:long, :long, :long], convention: :stdcall) { |lParam1, lParam2, lParamSort|
					yield ObjectSpace._id2ref(lParam1).subitems[lParamSort], ObjectSpace._id2ref(lParam2).subitems[lParamSort], j
				}
			)

			self
		end

		def clear; sendmsg(:deleteallitems); self end
	end

	class ListView < Control
		include ListViewMethods

		Prefix = {
			xstyle: [:lvs_ex_, :ws_ex_],
			style: [:lvs_, :ws_],
			message: [:lvm_, :ccm_, :wm_],
			notification: [:lvn_, :nm_]
		}

		def self.crackNotification(args)
			case args[:notification]
			when Windows::LVN_COLUMNCLICK
				args[:nmlv] = Windows::NMLISTVIEW.new(FFI::Pointer.new(args[:lParam]))
				args[:index] = args[:nmlv][:iSubItem]
			end
		end

		def initialize(parent, id, opts = {}, &block)
			super('SysListView32', parent, id, opts)

			@header = Handle.wrap(FFI::Pointer.new(sendmsg(:getheader)), WindowMethods, HeaderMethods)

			@items = []

			@parent.on(:notify, @id, &block) if block
		end

		attr_reader :header, :items

		def on(notification, &block)
			@parent.on(:notify, @id, Fzeet.constant(notification, *self.class::Prefix[:notification]), &block)

			self
		end
	end
end
