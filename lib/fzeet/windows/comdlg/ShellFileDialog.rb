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
	module ShellFileDialogMethods
		def Show(*args)
			raise "#{self}.#{__method__} failed." if
				Windows.FAILED(result = vtbl[:Show].call(self, *args)) &&
				result != Windows.HRESULT_FROM_WIN32(Windows::ERROR_CANCELLED) - 0x1_0000_0000

			result
		end

		def item
			FFI::MemoryPointer.new(:pointer) { |psi|
				next unless GetResult(psi) == Windows::S_OK

				si = Windows::ShellItem.new(psi.read_pointer)

				begin
					yield si
				ensure
					si.Release
				end
			}
		end

		def items
			FFI::MemoryPointer.new(:pointer) { |psia|
				next unless GetResults(psia) == Windows::S_OK

				sia = Windows::ShellItemArray.new(psia.read_pointer)

				begin
					yield sia
				ensure
					sia.Release
				end
			}
		end

		def path; item { |si| return si.path } end

		def paths; items { |sia| return sia.map(&:path) } end

		def show(window = Application.window)
			DialogResult.new((Show(window.handle) == Windows::S_OK) ? Windows::IDOK : Windows::IDCANCEL)
		end
	end

	class ShellFileOpenDialog < Windows::FileOpenDialog
		include ShellFileDialogMethods

		def initialize(opts = {})
			super()

			begin
				yield self
			ensure
				Release()
			end if block_given?
		end

		def multiselect=(multiselect)
			if multiselect
				SetOptions(Windows::FOS_ALLOWMULTISELECT)
			else
				opts = nil

				FFI::MemoryPointer.new(:pointer) { |p| GetOptions(p); opts = p.get_ulong(0) }

				SetOptions(opts & ~Windows::FOS_ALLOWMULTISELECT)
			end
		end
	end

	class ShellFileSaveDialog < Windows::FileSaveDialog
		include ShellFileDialogMethods

		def initialize(opts = {})
			super()

			begin
				yield self
			ensure
				Release()
			end if block_given?
		end
	end

	class ShellFolderDialog < Windows::FileOpenDialog
		include ShellFileDialogMethods

		def initialize(opts = {})
			super()

			SetOptions(Windows::FOS_PICKFOLDERS)

			begin
				yield self
			ensure
				Release()
			end if block_given?
		end
	end
end
