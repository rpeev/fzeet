require_relative '../core'

module Fzeet
	module Windows
		ffi_lib 'kernel32'
		ffi_convention :stdcall

		attach_function :GetModuleHandle, :GetModuleHandleA, [:string], :pointer

		attach_function :LoadLibrary, :LoadLibraryA, [:string], :pointer
		attach_function :FreeLibrary, [:pointer], :int

		attach_function :GetSystemDefaultLCID, [], :ulong

		if Version >= :xp
			class ACTCTX < FFI::Struct
				layout \
					:cbSize, :ulong,
					:dwFlags, :ulong,
					:lpSource, :pointer,
					:wProcessorArchitecture, :ushort,
					:wLangId, :ushort,
					:lpAssemblyDirectory, :pointer,
					:lpResourceName, :pointer,
					:lpApplicationName, :pointer,
					:hModule, :pointer
			end

			attach_function :CreateActCtx, :CreateActCtxA, [:pointer], :pointer
			attach_function :ReleaseActCtx, [:pointer], :void

			attach_function :ActivateActCtx, [:pointer, :pointer], :int
			attach_function :DeactivateActCtx, [:ulong, :ulong], :int

			COMMON_CONTROLS_ACTCTX = {
				handle: INVALID_HANDLE_VALUE,
				cookie: FFI::MemoryPointer.new(:ulong),
				activated: false
			}

			at_exit {
				DeactivateActCtx(0, COMMON_CONTROLS_ACTCTX[:cookie].get_ulong(0)) if
					COMMON_CONTROLS_ACTCTX[:activated]

				COMMON_CONTROLS_ACTCTX[:cookie].free

				ReleaseActCtx(COMMON_CONTROLS_ACTCTX[:handle]) unless
					COMMON_CONTROLS_ACTCTX[:handle] == INVALID_HANDLE_VALUE
			}
		end

		def EnableVisualStyles
			return unless Version >= :xp

			raise 'Visual styles already enabled.' if COMMON_CONTROLS_ACTCTX[:activated]

			manifest = "#{ENV['TEMP']}/Fzeet.Common-Controls.manifest"

			File.open(manifest, 'w:utf-8') { |file|
				file << <<-XML
<?xml version='1.0' encoding='utf-8' standalone='yes' ?>
<assembly xmlns='urn:schemas-microsoft-com:asm.v1' manifestVersion='1.0'>
	<dependency>
		<dependentAssembly>
			<assemblyIdentity type='Win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*' />
		</dependentAssembly>
	</dependency>
</assembly>
				XML
			}

			ac = ACTCTX.new

			ac[:cbSize] = ac.size
			ac[:lpSource] = source = FFI::MemoryPointer.from_string(File.expand_path(manifest))

			COMMON_CONTROLS_ACTCTX[:handle] = DetonateLastError(INVALID_HANDLE_VALUE, :CreateActCtx, ac) { source.free }

			DetonateLastError(0, :ActivateActCtx, COMMON_CONTROLS_ACTCTX[:handle], COMMON_CONTROLS_ACTCTX[:cookie]) { |failed|
				next unless failed

				ReleaseActCtx(COMMON_CONTROLS_ACTCTX[:handle]); COMMON_CONTROLS_ACTCTX[:handle] = INVALID_HANDLE_VALUE
			}

			COMMON_CONTROLS_ACTCTX[:activated] = true
		end

		module_function :EnableVisualStyles

		attach_function :MulDiv, [:int, :int, :int], :int
	end
end
