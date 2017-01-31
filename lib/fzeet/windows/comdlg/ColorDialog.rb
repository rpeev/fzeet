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
		CCERR_CHOOSECOLORCODES = 0x5000

		CC_RGBINIT = 0x00000001
		CC_FULLOPEN = 0x00000002
		CC_PREVENTFULLOPEN = 0x00000004
		CC_SHOWHELP = 0x00000008
		CC_ENABLEHOOK = 0x00000010
		CC_ENABLETEMPLATE = 0x00000020
		CC_ENABLETEMPLATEHANDLE = 0x00000040
		CC_SOLIDCOLOR = 0x00000080
		CC_ANYCOLOR = 0x00000100

		callback :CCHOOKPROC, [:pointer, :uint, :uint, :long], :uint

		class CHOOSECOLOR < FFI::Struct
			layout \
				:lStructSize, :ulong,
				:hwndOwner, :pointer,
				:hInstance, :pointer,
				:rgbResult, :ulong,
				:lpCustColors, :pointer,
				:Flags, :ulong,
				:lCustData, :long,
				:lpfnHook, :CCHOOKPROC,
				:lpTemplateName, :pointer
		end

		attach_function :ChooseColor, :ChooseColorA, [:pointer], :int
	end

	class ColorDialog < CommonDialog
		DialogStruct = Windows::CHOOSECOLOR

		HookProc = -> *args { CommonDialog::HookProc.(*args.unshift(DialogStruct)) }

		def initialize(opts = {})
			_opts = {

			}
			badopts = opts.keys - _opts.keys; raise "Bad option(s): #{badopts.join(', ')}." unless badopts.empty?
			_opts.merge!(opts)

			@struct = DialogStruct.new

			@struct[:lStructSize] = @struct.size
			@struct[:hInstance] = Windows.GetModuleHandle(nil)
			@struct[:lpCustColors] = @buf = FFI::MemoryPointer.new(:ulong, 16)
			@struct[:Flags] = Fzeet.flags(:enablehook, :cc_)
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

		def show(window = Application.window)
			@struct[:hwndOwner] = window.handle

			DialogResult.new((Windows.ChooseColor(@struct) == 0) ? Windows::IDCANCEL : Windows::IDOK)
		end

		def color; result = @struct[:rgbResult]; [Windows.GetRValue(result), Windows.GetBValue(result), Windows.GetBValue(result)] end
	end
end
