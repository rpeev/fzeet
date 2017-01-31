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
		FNERR_FILENAMECODES = 0x3000
		FNERR_SUBCLASSFAILURE = 0x3001
		FNERR_INVALIDFILENAME = 0x3002
		FNERR_BUFFERTOOSMALL = 0x3003

		OFN_READONLY = 0x00000001
		OFN_OVERWRITEPROMPT = 0x00000002
		OFN_HIDEREADONLY = 0x00000004
		OFN_NOCHANGEDIR = 0x00000008
		OFN_SHOWHELP = 0x00000010
		OFN_ENABLEHOOK = 0x00000020
		OFN_ENABLETEMPLATE = 0x00000040
		OFN_ENABLETEMPLATEHANDLE = 0x00000080
		OFN_NOVALIDATE = 0x00000100
		OFN_ALLOWMULTISELECT = 0x00000200
		OFN_EXTENSIONDIFFERENT = 0x00000400
		OFN_PATHMUSTEXIST = 0x00000800
		OFN_FILEMUSTEXIST = 0x00001000
		OFN_CREATEPROMPT = 0x00002000
		OFN_SHAREAWARE = 0x00004000
		OFN_NOREADONLYRETURN = 0x00008000
		OFN_NOTESTFILECREATE = 0x00010000
		OFN_NONETWORKBUTTON = 0x00020000
		OFN_NOLONGNAMES = 0x00040000
		OFN_EXPLORER = 0x00080000
		OFN_NODEREFERENCELINKS = 0x00100000
		OFN_LONGNAMES = 0x00200000
		OFN_ENABLEINCLUDENOTIFY = 0x00400000
		OFN_ENABLESIZING = 0x00800000
		OFN_DONTADDTORECENT = 0x02000000
		OFN_FORCESHOWHIDDEN = 0x10000000

		OFN_EX_NOPLACESBAR = 0x00000001

		OFN_SHAREFALLTHROUGH = 2
		OFN_SHARENOWARN = 1
		OFN_SHAREWARN = 0

		callback :OFNHOOKPROC, [:pointer, :uint, :uint, :long], :uint

		class OPENFILENAME < FFI::Struct
			layout \
				:lStructSize, :ulong,
				:hwndOwner, :pointer,
				:hInstance, :pointer,
				:lpstrFilter, :pointer,
				:lpstrCustomFilter, :pointer,
				:nMaxCustFilter, :ulong,
				:nFilterIndex, :ulong,
				:lpstrFile, :pointer,
				:nMaxFile, :ulong,
				:lpstrFileTitle, :pointer,
				:nMaxFileTitle, :ulong,
				:lpstrInitialDir, :pointer,
				:lpstrTitle, :pointer,
				:Flags, :ulong,
				:nFileOffset, :ushort,
				:nFileExtension, :ushort,
				:lpstrDefExt, :pointer,
				:lCustData, :long,
				:lpfnHook, :OFNHOOKPROC,
				:lpTemplateName, :pointer,
				:pvReserved, :pointer,
				:dwReserved, :ulong,
				:FlagsEx, :ulong
		end

		attach_function :GetOpenFileName, :GetOpenFileNameA, [:pointer], :int
		attach_function :GetSaveFileName, :GetSaveFileNameA, [:pointer], :int

		CDM_GETSPEC = CDM_FIRST + 0x0000
		CDM_GETFILEPATH = CDM_FIRST + 0x0001
		CDM_GETFOLDERPATH = CDM_FIRST + 0x0002
		CDM_GETFOLDERIDLIST = CDM_FIRST + 0x0003
		CDM_SETCONTROLTEXT = CDM_FIRST + 0x0004
		CDM_HIDECONTROL = CDM_FIRST + 0x0005
		CDM_SETDEFEXT = CDM_FIRST + 0x0006

		CDN_INITDONE = CDN_FIRST - 0x0000
		CDN_SELCHANGE = CDN_FIRST - 0x0001
		CDN_FOLDERCHANGE = CDN_FIRST - 0x0002
		CDN_SHAREVIOLATION = CDN_FIRST - 0x0003
		CDN_HELP = CDN_FIRST - 0x0004
		CDN_FILEOK = CDN_FIRST - 0x0005
		CDN_TYPECHANGE = CDN_FIRST - 0x0006
		CDN_INCLUDEITEM = CDN_FIRST - 0x0007

		class OFNOTIFY < FFI::Struct
			layout \
				:hdr, NMHDR,
				:lpOFN, :pointer,
				:pszFile, :pointer
		end

		class OFNOTIFYEX < FFI::Struct
			layout \
				:hdr, NMHDR,
				:lpOFN, :pointer,
				:psf, :pointer,
				:pidl, :pointer
		end
	end

	class FileDialog < CommonDialog
		DialogStruct = Windows::OPENFILENAME

		HookProc = -> *args { CommonDialog::HookProc.(*args.unshift(DialogStruct)) }

		def initialize(opts = {})
			_opts = {
				filter: nil,
				customFilter: nil,
				filterIndex: 0,
				fileTitle: nil,
				initialDir: nil,
				title: nil,
				flags: 0,
				fileExtension: nil,
				defExt: nil,
				custData: 0,
				hook: nil,
				templateName: nil,
				xflags: 0
			}
			badopts = opts.keys - _opts.keys; raise "Bad option(s): #{badopts.join(', ')}." unless badopts.empty?
			_opts.merge!(opts)

			@struct = DialogStruct.new

			@struct[:lStructSize] = @struct.size
			@struct[:hInstance] = Windows.GetModuleHandle(nil)
			@struct[:lpstrFile] = @buf = FFI::MemoryPointer.new(:char, 4096)
			@struct[:nMaxFile] = @buf.size
			@struct[:Flags] = Fzeet.flags([:enablehook, :explorer, :enablesizing, :overwriteprompt] + [*_opts[:flags]], :ofn_)
			@struct[:lCustData] = object_id
			@struct[:lpfnHook] = HookProc

			super()

			begin
				yield self
			ensure
				dispose
			end if block_given?
		end

		def dispose; @buf.free end

		def path; @buf.read_string end
	end

	class FileOpenDialog < FileDialog
		def show(window = Application.window)
			@struct[:hwndOwner] = window.handle

			DialogResult.new((Windows.GetOpenFileName(@struct) == 0) ? Windows::IDCANCEL : Windows::IDOK)
		end

		def paths
			return [path] if
				(path = @buf.read_string).length + 1 != @struct[:nFileOffset]

			result, tip = [], path.length + 1

			until @buf.get_bytes(tip, 2) == "\0\0"
				result << (name = @buf.get_string(tip))

				tip += name.length + 1
			end

			result.map! { |last| "#{path}\\#{last}" }
		end

		def multiselect=(multiselect)
			(multiselect) ?
				@struct[:Flags] |= Windows::OFN_ALLOWMULTISELECT :
				@struct[:Flags] &= ~Windows::OFN_ALLOWMULTISELECT
		end
	end

	class FileSaveDialog < FileDialog
		def show(window = Application.window)
			@struct[:hwndOwner] = window.handle

			DialogResult.new((Windows.GetSaveFileName(@struct) == 0) ? Windows::IDCANCEL : Windows::IDOK)
		end
	end

	class FolderDialog < CommonDialog
		DialogStruct = Windows::BROWSEINFO

		HookProc = -> *args { CommonDialog::HookProc.(*args.unshift(DialogStruct)) }

		def initialize(opts = {})
			_opts = {
				root: nil,
				displayName: nil,
				title: nil,
				flags: 0,
				hook: nil,
				param: 0,
				image: 0
			}
			badopts = opts.keys - _opts.keys; raise "Bad option(s): #{badopts.join(', ')}." unless badopts.empty?
			_opts.merge!(opts)

			@struct = DialogStruct.new

			@struct[:ulFlags] = Fzeet.flags([:returnonlyfsdirs, :usenewui], :bif_)
			@struct[:lpfn] = HookProc
			@struct[:lParam] = object_id

			super()
		end

		def path; @path && @path.dup end

		def show(window = Application.window)
			@struct[:hwndOwner] = window.handle

			@path = nil

			DialogResult.new(((pidl = Windows.SHBrowseForFolder(@struct)).null?) ? Windows::IDCANCEL : Windows::IDOK).tap { |result|
				next unless result.ok?

				FFI::MemoryPointer.new(:char, 4096) { |p|
					Windows.SHGetPathFromIDList(pidl, p)

					@path = p.read_string
				}
			}
		ensure
			Windows.CoTaskMemFree(pidl)
		end
	end
end
