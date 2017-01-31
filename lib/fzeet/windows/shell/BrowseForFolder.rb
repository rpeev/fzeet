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
		BIF_RETURNONLYFSDIRS = 0x00000001
		BIF_DONTGOBELOWDOMAIN = 0x00000002
		BIF_STATUSTEXT = 0x00000004
		BIF_RETURNFSANCESTORS = 0x00000008
		BIF_EDITBOX = 0x00000010
		BIF_VALIDATE = 0x00000020
		BIF_NEWDIALOGSTYLE = 0x00000040
		BIF_USENEWUI = BIF_NEWDIALOGSTYLE | BIF_EDITBOX
		BIF_BROWSEINCLUDEURLS = 0x00000080
		BIF_UAHINT = 0x00000100
		BIF_NONEWFOLDERBUTTON = 0x00000200
		BIF_NOTRANSLATETARGETS = 0x00000400
		BIF_BROWSEFORCOMPUTER = 0x00001000
		BIF_BROWSEFORPRINTER = 0x00002000
		BIF_BROWSEINCLUDEFILES = 0x00004000
		BIF_SHAREABLE = 0x00008000
		BIF_BROWSEFILEJUNCTIONS = 0x00010000

		callback :BFFCALLBACK, [:pointer, :uint, :long, :long], :int

		class BROWSEINFO < FFI::Struct
			layout \
				:hwndOwner, :pointer,
				:pidlRoot, :pointer,
				:pszDisplayName, :pointer,
				:lpszTitle, :pointer,
				:ulFlags, :uint,
				:lpfn, :BFFCALLBACK,
				:lParam, :long,
				:iImage, :int
		end

		attach_function :SHBrowseForFolder, :SHBrowseForFolderA, [:pointer], :pointer

		BFFM_INITIALIZED = 1
		BFFM_SELCHANGED = 2
		BFFM_VALIDATEFAILED = 3
		BFFM_IUNKNOWN = 5

		BFFM_SETSTATUSTEXT = WM_USER + 100
		BFFM_ENABLEOK = WM_USER + 101
		BFFM_SETSELECTION = WM_USER + 102
		BFFM_SETOKTEXT = WM_USER + 105
		BFFM_SETEXPANDED = WM_USER + 106
	end
end
