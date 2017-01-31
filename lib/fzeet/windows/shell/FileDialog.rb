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
		FOS_OVERWRITEPROMPT = 0x00000002
		FOS_STRICTFILETYPES = 0x00000004
		FOS_NOCHANGEDIR = 0x00000008
		FOS_PICKFOLDERS = 0x00000020
		FOS_FORCEFILESYSTEM = 0x00000040
		FOS_ALLNONSTORAGEITEMS = 0x00000080
		FOS_NOVALIDATE = 0x00000100
		FOS_ALLOWMULTISELECT = 0x00000200
		FOS_PATHMUSTEXIST = 0x00000800
		FOS_FILEMUSTEXIST = 0x00001000
		FOS_CREATEPROMPT = 0x00002000
		FOS_SHAREAWARE = 0x00004000
		FOS_NOREADONLYRETURN = 0x00008000
		FOS_NOTESTFILECREATE = 0x00010000
		FOS_HIDEMRUPLACES = 0x00020000
		FOS_HIDEPINNEDPLACES = 0x00040000
		FOS_NODEREFERENCELINKS = 0x00100000
		FOS_DONTADDTORECENT = 0x02000000
		FOS_FORCESHOWHIDDEN = 0x10000000
		FOS_DEFAULTNOMINIMODE = 0x20000000
		FOS_FORCEPREVIEWPANEON = 0x40000000

		IFileDialog = COM::Interface[IModalWindow,
			GUID['42f85136-db7e-439c-85f1-e4075d135fc8'],

			SetFileTypes: [[:uint, :pointer], :long],
			SetFileTypeIndex: [[:uint], :long],
			GetFileTypeIndex: [[:pointer], :long],
			Advise: [[:pointer, :pointer], :long],
			Unadvise: [[:ulong], :long],
			SetOptions: [[:uint], :long],
			GetOptions: [[:pointer], :long],
			SetDefaultFolder: [[:pointer], :long],
			SetFolder: [[:pointer], :long],
			GetFolder: [[:pointer], :long],
			GetCurrentSelection: [[:pointer], :long],
			SetFileName: [[:pointer], :long],
			GetFileName: [[:pointer], :long],
			SetTitle: [[:pointer], :long],
			SetOkButtonLabel: [[:pointer], :long],
			SetFileNameLabel: [[:pointer], :long],
			GetResult: [[:pointer], :long],
			AddPlace: [[:pointer, :uint], :long],
			SetDefaultExtension: [[:pointer], :long],
			Close: [[:long], :long],
			SetClientGuid: [[:pointer], :long],
			ClearClientData: [[], :long],
			SetFilter: [[:pointer], :long]
		]

		FileDialog = COM::Instance[IFileDialog]

		IFileOpenDialog = COM::Interface[IFileDialog,
			GUID['d57c7288-d4ad-4768-be02-9d969532d960'],

			GetResults: [[:pointer], :long],
			GetSelectedItems: [[:pointer], :long]
		]

		FileOpenDialog = COM::Factory[IFileOpenDialog, GUID['DC1C5A9C-E88A-4dde-A5A1-60F82A20AEF7']]

		IFileSaveDialog = COM::Interface[IFileDialog,
			GUID['84bccd23-5fde-4cdb-aea4-af64b83d78ab'],

			SetSaveAsItem: [[:pointer], :long],
			SetProperties: [[:pointer], :long],
			SetCollectedProperties: [[:pointer, :int], :long],
			GetProperties: [[:pointer], :long],
			ApplyProperties: [[:pointer, :pointer, :pointer, :pointer], :long],
		]

		FileSaveDialog = COM::Factory[IFileSaveDialog, GUID['C0B4E2F3-BA21-4773-8DBA-335EC946EB8B']]
	end
end
