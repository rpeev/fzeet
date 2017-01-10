require_relative '../ole'

module Fzeet
	module Windows
		ffi_lib 'oleaut32'
		ffi_convention :stdcall

		OLEIVERB_PRIMARY = 0
		OLEIVERB_SHOW = -1
		OLEIVERB_OPEN = -2
		OLEIVERB_HIDE = -3
		OLEIVERB_UIACTIVATE = -4
		OLEIVERB_INPLACEACTIVATE = -5
		OLEIVERB_DISCARDUNDOSTATE = -6

		IOleWindow = COM::Interface[IUnknown,
			GUID['00000114-0000-0000-C000-000000000046'],

			GetWindow: [[:pointer], :long],
			ContextSensitiveHelp: [[:int], :long]
		]

		OleWindow = COM::Instance[IOleWindow]

		IOleInPlaceObject = COM::Interface[IOleWindow,
			GUID['00000113-0000-0000-C000-000000000046'],

			InPlaceDeactivate: [[], :long],
			UIDeactivate: [[], :long],
			SetObjectRects: [[:pointer, :pointer], :long],
			ReactivateAndUndo: [[], :long]
		]

		OleInPlaceObject = COM::Instance[IOleInPlaceObject]

		IOleInPlaceSite = COM::Interface[IOleWindow,
			GUID['00000119-0000-0000-C000-000000000046'],

			CanInPlaceActivate: [[], :long],
			OnInPlaceActivate: [[], :long],
			OnUIActivate: [[], :long],
			GetWindowContext: [[:pointer, :pointer, :pointer, :pointer, :pointer], :long],
			Scroll: [[:long_long], :long],
			OnUIDeactivate: [[:int], :long],
			OnInPlaceDeactivate: [[], :long],
			DiscardUndoState: [[], :long],
			DeactivateAndUndo: [[], :long],
			OnPosRectChange: [[:pointer], :long]
		]

		OleInPlaceSite = COM::Callback[IOleInPlaceSite]

		IOleClientSite = COM::Interface[IUnknown,
			GUID['00000118-0000-0000-C000-000000000046'],

			SaveObject: [[], :long],
			GetMoniker: [[:ulong, :ulong, :pointer], :long],
			GetContainer: [[:pointer], :long],
			ShowObject: [[], :long],
			OnShowWindow: [[:int], :long],
			RequestNewObjectLayout: [[], :long]
		]

		OleClientSite = COM::Callback[IOleClientSite]

		OLEGETMONIKER_ONLYIFTHERE = 1
		OLEGETMONIKER_FORCEASSIGN = 2
		OLEGETMONIKER_UNASSIGN = 3
		OLEGETMONIKER_TEMPFORUSER = 4

		OLEWHICHMK_CONTAINER = 1
		OLEWHICHMK_OBJREL = 2
		OLEWHICHMK_OBJFULL = 3

		USERCLASSTYPE_FULL = 1
		USERCLASSTYPE_SHORT = 2
		USERCLASSTYPE_APPNAME = 3

		OLEMISC_RECOMPOSEONRESIZE = 0x00000001
		OLEMISC_ONLYICONIC = 0x00000002
		OLEMISC_INSERTNOTREPLACE = 0x00000004
		OLEMISC_STATIC = 0x00000008
		OLEMISC_CANTLINKINSIDE = 0x00000010
		OLEMISC_CANLINKBYOLE1 = 0x00000020
		OLEMISC_ISLINKOBJECT = 0x00000040
		OLEMISC_INSIDEOUT = 0x00000080
		OLEMISC_ACTIVATEWHENVISIBLE = 0x00000100
		OLEMISC_RENDERINGISDEVICEINDEPENDENT = 0x00000200
		OLEMISC_INVISIBLEATRUNTIME = 0x00000400
		OLEMISC_ALWAYSRUN = 0x00000800
		OLEMISC_ACTSLIKEBUTTON = 0x00001000
		OLEMISC_ACTSLIKELABEL = 0x00002000
		OLEMISC_NOUIACTIVATE = 0x00004000
		OLEMISC_ALIGNABLE = 0x00008000
		OLEMISC_SIMPLEFRAME = 0x00010000
		OLEMISC_SETCLIENTSITEFIRST = 0x00020000
		OLEMISC_IMEMODE = 0x00040000
		OLEMISC_IGNOREACTIVATEWHENVISIBLE = 0x00080000
		OLEMISC_WANTSTOMENUMERGE = 0x00100000
		OLEMISC_SUPPORTSMULTILEVELUNDO = 0x00200000

		OLECLOSE_SAVEIFDIRTY = 0
		OLECLOSE_NOSAVE = 1
		OLECLOSE_PROMPTSAVE = 2

		IOleObject = COM::Interface[IUnknown,
			GUID['00000112-0000-0000-C000-000000000046'],

			SetClientSite: [[:pointer], :long],
			GetClientSite: [[:pointer], :long],
			SetHostNames: [[:pointer, :pointer], :long],
			Close: [[:ulong], :long],
			SetMoniker: [[:ulong, :pointer], :long],
			GetMoniker: [[:ulong, :ulong, :pointer], :long],
			InitFromData: [[:pointer, :int, :ulong], :long],
			GetClipboardData: [[:ulong, :pointer], :long],
			DoVerb: [[:long, :pointer, :pointer, :long, :pointer, :pointer], :long],
			EnumVerbs: [[:pointer], :long],
			Update: [[], :long],
			IsUpToDate: [[], :long],
			GetUserClassID: [[:pointer], :long],
			GetUserType: [[:ulong, :pointer], :long],
			SetExtent: [[:ulong, :pointer], :long],
			GetExtent: [[:ulong, :pointer], :long],
			Advise: [[:pointer, :pointer], :long],
			Unadvise: [[:ulong], :long],
			EnumAdvise: [[:pointer], :long],
			GetMiscStatus: [[:ulong, :pointer], :long],
			SetColorScheme: [[:pointer], :long]
		]

		OleObject = COM::Instance[IOleObject]

		class PARAMDATA < FFI::Struct
			layout \
				:szName, :pointer,
				:vt, :ushort
		end

		CC_FASTCALL = 0
		CC_CDECL = 1
		CC_MSCPASCAL = CC_CDECL + 1
		CC_PASCAL = CC_MSCPASCAL
		CC_MACPASCAL = CC_PASCAL + 1
		CC_STDCALL = CC_MACPASCAL + 1
		CC_FPFASTCALL = CC_STDCALL + 1
		CC_SYSCALL = CC_FPFASTCALL + 1
		CC_MPWCDECL = CC_SYSCALL + 1
		CC_MPWPASCAL = CC_MPWCDECL + 1
		CC_MAX = CC_MPWPASCAL + 1

		DISPATCH_METHOD = 0x1
		DISPATCH_PROPERTYGET = 0x2
		DISPATCH_PROPERTYPUT = 0x4
		DISPATCH_PROPERTYPUTREF = 0x8

		class METHODDATA < FFI::Struct
			layout \
				:szName, :pointer,
				:ppdata, :pointer,
				:dispid, :long,
				:iMeth, :uint,
				:cc, :uint,
				:cArgs, :uint,
				:wFlags, :ushort,
				:vtReturn, :ushort
		end

		class INTERFACEDATA < FFI::Struct
			layout \
				:pmethdata, :pointer,
				:cMembers, :uint
		end

		attach_function :CreateDispTypeInfo, [:pointer, :ulong, :pointer], :long

		class DISPPARAMS < FFI::Struct
			layout \
				:rgvarg, :pointer,
				:rgdispidNamedArgs, :pointer,
				:cArgs, :uint,
				:cNamedArgs, :uint
		end

		attach_function :DispInvoke, [:pointer, :pointer, :long, :ushort, :pointer, :pointer, :pointer, :pointer], :long
	end
end
