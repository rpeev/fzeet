require_relative '../SystemParametersInfo'
require_relative '../Window/WindowMethods'

module Fzeet
	module Windows
		class NMHDR < FFI::Struct
			layout \
				:hwndFrom, :pointer,
				:idFrom, :uint,
				:code, :uint
		end
	end

	class Control < Handle
		include WindowMethods

		Windows::NONCLIENTMETRICS.new.tap { |ncm|
			ncm[:cbSize] = ncm.size

			Windows.DetonateLastError(0, :SystemParametersInfo, Windows::SPI_GETNONCLIENTMETRICS, ncm.size, ncm, 0)

			Font = IndirectFont.new(ncm[:lfMenuFont])

			at_exit { Font.dispose }
		}

		def self.crackNotification(args) end

		def initialize(className, parent, id, opts = {})
			@parent = parent
			@id = Command[id]

			handlers = {}

			opts.delete_if { |k, v|
				next false unless v.kind_of?(Proc)

				handlers[k] = v; true
			}

			_opts = {
				xstyle: [],
				caption: id.capitalize,
				style: [],
				x: 0,
				y: 0,
				width: 0,
				height: 0,
				position: [],
				anchor: nil
			}
			badopts = opts.keys - _opts.keys; raise "Bad option(s): #{badopts.join(', ')}." unless badopts.empty?
			_opts.merge!(opts)

			_opts[:xstyle] = Fzeet.flags(_opts[:xstyle], *self.class::Prefix[:xstyle])
			_opts[:caption] = _opts[:caption].to_s
			_opts[:style] = Fzeet.flags([:child, :visible, :tabstop], :ws_) | Fzeet.flags(_opts[:style], *self.class::Prefix[:style])
			_opts[:x], _opts[:y], _opts[:width], _opts[:height] = _opts[:position] unless _opts[:position].empty?

			@handle = Windows.DetonateLastError(FFI::Pointer::NULL, :CreateWindowEx,
				_opts[:xstyle], className, _opts[:caption], _opts[:style],
				_opts[:x], _opts[:y], _opts[:width], _opts[:height],
				@parent.handle, FFI::Pointer.new(@id), Windows.GetModuleHandle(nil), nil
			)

			attach

			sendmsg(:setfont, Font.handle, 1)

			handlers.each { |k, v| on(k, &v) }

			case _opts[:anchor]
			when :ltr
				@parent.on(:size) { |args|
					self.position = @parent.rect.tap { |r| r[:bottom] = _opts[:height] }.to_a

					args[:result] = nil if @parent.class == MDIChild
				}
			when :lrb
				@parent.on(:size) { |args|
					self.position = @parent.rect.tap { |r| r[:top] = r[:bottom] - _opts[:height]; r[:bottom] = _opts[:height] }.to_a

					args[:result] = nil if @parent.class == MDIChild
				}
			when :ltrb
				@parent.on(:size) { |args|
					self.position = @parent.rect.to_a

					args[:result] = nil if @parent.class == MDIChild
				}
			else raise ArgumentError, "Bad anchor spec: #{_opts[:anchor]}."
			end if _opts[:anchor]
		end

		attr_reader :parent, :id

		def dispose; detach end
	end
end
