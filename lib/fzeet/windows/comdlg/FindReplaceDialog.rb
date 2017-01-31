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
		FRERR_FINDREPLACECODES = 0x4000
		FRERR_BUFFERLENGTHZERO = 0x4001

		FR_DOWN = 0x00000001
		FR_WHOLEWORD = 0x00000002
		FR_MATCHCASE = 0x00000004
		FR_FINDNEXT = 0x00000008
		FR_REPLACE = 0x00000010
		FR_REPLACEALL = 0x00000020
		FR_DIALOGTERM = 0x00000040
		FR_SHOWHELP = 0x00000080
		FR_ENABLEHOOK = 0x00000100
		FR_ENABLETEMPLATE = 0x00000200
		FR_NOUPDOWN = 0x00000400
		FR_NOMATCHCASE = 0x00000800
		FR_NOWHOLEWORD = 0x00001000
		FR_ENABLETEMPLATEHANDLE = 0x00002000
		FR_HIDEUPDOWN = 0x00004000
		FR_HIDEMATCHCASE = 0x00008000
		FR_HIDEWHOLEWORD = 0x00010000
		FR_RAW = 0x00020000
		FR_MATCHDIAC = 0x20000000
		FR_MATCHKASHIDA = 0x40000000
		FR_MATCHALEFHAMZA = 0x80000000

		callback :FRHOOKPROC, [:pointer, :uint, :uint, :long], :uint

		class FINDREPLACE < FFI::Struct
			layout \
				:lStructSize, :ulong,
				:hwndOwner, :pointer,
				:hInstance, :pointer,
				:Flags, :ulong,
				:lpstrFindWhat, :pointer,
				:lpstrReplaceWith, :pointer,
				:wFindWhatLen, :ushort,
				:wReplaceWithLen, :ushort,
				:lCustData, :long,
				:lpfnHook, :FRHOOKPROC,
				:lpTemplateName, :pointer
		end

		attach_function :FindText, :FindTextA, [:pointer], :pointer
		attach_function :ReplaceText, :ReplaceTextA, [:pointer], :pointer
	end

	class FindReplaceDialog < CommonDialog
		DialogStruct = Windows::FINDREPLACE

		HookProc = -> *args { CommonDialog::HookProc.(*args.unshift(DialogStruct)) }

		Message = Windows.DetonateLastError(0, :RegisterWindowMessage, Windows::FINDMSGSTRING)

		def initialize(opts = {})
			_opts = {

			}
			badopts = opts.keys - _opts.keys; raise "Bad option(s): #{badopts.join(', ')}." unless badopts.empty?
			_opts.merge!(opts)

			@frNotifies = {}

			@struct = DialogStruct.new

			@struct[:lStructSize] = @struct.size
			@struct[:hInstance] = Windows.GetModuleHandle(nil)
			@struct[:Flags] = Fzeet.flags(:enablehook, :fr_)
			@struct[:lpstrFindWhat] = @findbuf = FFI::MemoryPointer.new(:char, 4096)
			@struct[:lpstrReplaceWith] = @replacebuf = FFI::MemoryPointer.new(:char, 4096)
			@struct[:wFindWhatLen] = @findbuf.size
			@struct[:wReplaceWithLen] = @replacebuf.size
			@struct[:lCustData] = object_id
			@struct[:lpfnHook] = HookProc

			super()
		end

		def dispose; [@findbuf, @replacebuf].each(&:free) end

		def findWhat; @findbuf.read_string end
		def replaceWith; @replacebuf.read_string end

		def frProc(args)
			return unless args[:lParam] == @struct.pointer.address

			(handlers = @frNotifies[:all]) and handlers.each { |handler|
				(handler.arity == 0) ? handler.call : handler.call(args)
			}

			if @struct[:Flags] & Windows::FR_DIALOGTERM != 0
				(handlers = @frNotifies[Windows::FR_DIALOGTERM]) and handlers.each { |handler|
					(handler.arity == 0) ? handler.call : handler.call(args)
				}

				self.dialog = false

				dispose
			elsif @struct[:Flags] & Windows::FR_FINDNEXT != 0
				(handlers = @frNotifies[Windows::FR_FINDNEXT]) and handlers.each { |handler|
					(handler.arity == 0) ? handler.call : handler.call(args)
				}
			elsif @struct[:Flags] & Windows::FR_REPLACE != 0
				(handlers = @frNotifies[Windows::FR_REPLACE]) and handlers.each { |handler|
					(handler.arity == 0) ? handler.call : handler.call(args)
				}
			elsif @struct[:Flags] & Windows::FR_REPLACEALL != 0
				(handlers = @frNotifies[Windows::FR_REPLACEALL]) and handlers.each { |handler|
					(handler.arity == 0) ? handler.call : handler.call(args)
				}
			end
		end

		def onNotify(notification, &block)
			notification = Fzeet.constant(notification, :fr_) unless
				notification.kind_of?(Integer) || notification == :all

			(@frNotifies[notification] ||= []) << block

			self
		end
	end

	class FindDialog < FindReplaceDialog
		def show(window = Application.window)
			@struct[:hwndOwner] = window.handle
			@handle = Windows.DetonateLastError(FFI::Pointer::NULL, :FindText, @struct)

			self.dialog = true

			window.on(FindReplaceDialog::Message, &method(:frProc))

			self
		end
	end

	class ReplaceDialog < FindReplaceDialog
		def show(window = Application.window)
			@struct[:hwndOwner] = window.handle
			@handle = Windows.DetonateLastError(FFI::Pointer::NULL, :ReplaceText, @struct)

			self.dialog = true

			window.on(FindReplaceDialog::Message, &method(:frProc))

			self
		end
	end
end
