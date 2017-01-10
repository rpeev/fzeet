require_relative '../user'
require_relative '../com'
require_relative '../shell'

module Fzeet
	module Windows
		ffi_lib 'comdlg32'
		ffi_convention :stdcall

		CDERR_DIALOGFAILURE = 0xFFFF
		CDERR_GENERALCODES = 0x0000
		CDERR_STRUCTSIZE = 0x0001
		CDERR_INITIALIZATION = 0x0002
		CDERR_NOTEMPLATE = 0x0003
		CDERR_NOHINSTANCE = 0x0004
		CDERR_LOADSTRFAILURE = 0x0005
		CDERR_FINDRESFAILURE = 0x0006
		CDERR_LOADRESFAILURE = 0x0007
		CDERR_LOCKRESFAILURE = 0x0008
		CDERR_MEMALLOCFAILURE = 0x0009
		CDERR_MEMLOCKFAILURE = 0x000A
		CDERR_NOHOOK = 0x000B
		CDERR_REGISTERMSGFAIL = 0x000C

		attach_function :CommDlgExtendedError, [], :ulong

		CDM_FIRST = WM_USER + 100
		CDM_LAST = WM_USER + 200

		CDN_FIRST = 0x1_0000_0000 - 601
		CDN_LAST = 0x1_0000_0000 - 699

		LBSELCHSTRING = 'commdlg_LBSelChangedNotify'
		SHAREVISTRING = 'commdlg_ShareViolation'
		FILEOKSTRING = 'commdlg_FileNameOK'
		COLOROKSTRING = 'commdlg_ColorOK'
		SETRGBSTRING = 'commdlg_SetRGBColor'
		HELPMSGSTRING = 'commdlg_help'
		FINDMSGSTRING = 'commdlg_FindReplace'

		CD_LBSELNOITEMS = -1
		CD_LBSELCHANGE = 0
		CD_LBSELSUB = 1
		CD_LBSELADD = 2
	end

	class CommonDialog < Handle
		include WindowMethods

		HookProc = -> klass, hwnd, uMsg, wParam, lParam {
			begin
				if klass == Windows::BROWSEINFO
					if uMsg == Windows::BFFM_IUNKNOWN
						instance = ObjectSpace._id2ref(lParam)

						if @@instances.include?(hwnd.to_i)
							@@instances.delete(hwnd.to_i)
						else
							@@instances[hwnd.to_i] = instance

							@@instances[hwnd.to_i].instance_variable_set(:@handle, hwnd)
						end
					end
				else
					if uMsg == Windows::WM_INITDIALOG
						@@instances[hwnd.to_i] = ObjectSpace._id2ref(
							klass.new(FFI::Pointer.new(lParam))[:lCustData].to_i
						)

						@@instances[hwnd.to_i].instance_variable_set(:@handle, hwnd)
					end
				end

				result = @@instances[hwnd.to_i].hookProc(hwnd, uMsg, wParam, lParam) if @@instances[hwnd.to_i]
			rescue
				answer = Fzeet.message %Q{#{$!}\n\n#{$!.backtrace.join("\n")}}, buttons: [:abort, :retry, :ignore], icon: :error

				Application.quit if answer.abort?
			ensure
				if uMsg == Windows::WM_NCDESTROY
					@@instances.delete(hwnd.to_i)
				end
			end

			result || 0
		}

		def self.crackMessage(hwnd, uMsg, wParam, lParam)
			window = @@instances[hwnd.to_i]

			args = {
				hwnd: hwnd,
				uMsg: uMsg,
				wParam: wParam,
				lParam: lParam,
				result: 0,
				window: window,
				sender: window
			}

			args
		end

		def initialize
			@messages = {}
		end

		attr_reader :struct

		def hookProc(hwnd, uMsg, wParam, lParam)
			args, result = nil, nil

			if (handlers = @messages[uMsg])
				args ||= self.class.crackMessage(hwnd, uMsg, wParam, lParam)

				handlers.each { |handler|
					(handler.arity == 0) ? handler.call : handler.call(args)

					result = args[:result]
				}
			end

			result
		end

		def on(msg, &block)
			(@messages[Fzeet.constant(msg, :wm_)] ||= []) << block

			self
		end
	end
end
