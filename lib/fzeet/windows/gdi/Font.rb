require_relative 'Common'

module Fzeet
	module Windows
		class LOGFONT < FFI::Struct
			layout \
				:lfHeight, :long,
				:lfWidth, :long,
				:lfEscapement, :long,
				:lfOrientation, :long,
				:lfWeight, :long,
				:lfItalic, :uchar,
				:lfUnderline, :uchar,
				:lfStrikeOut, :uchar,
				:lfCharSet, :uchar,
				:lfOutPrecision, :uchar,
				:lfClipPrecision, :uchar,
				:lfQuality, :uchar,
				:lfPitchAndFamily, :uchar,
				:lfFaceName, [:char, 32]

			def face; self[:lfFaceName].to_s end
			def face=(face) self[:lfFaceName] = face end

			def size; -Rational(self[:lfHeight] * 72, Application.devcaps[:logpixelsy]) end
			def size=(size) self[:lfHeight] = -Windows.MulDiv((size * 10).to_i, Application.devcaps[:logpixelsy], 720) end

			def bold?; self[:lfWeight] >= 700 end
			def bold=(bold) self[:lfWeight] = (bold) ? 700 : 0 end

			def italic?; self[:lfItalic] == 1 end
			def italic=(italic) self[:lfItalic] = (italic) ? 1 : 0 end

			def underline?; self[:lfUnderline] == 1 end
			def underline=(underline) self[:lfUnderline] = (underline) ? 1 : 0 end

			def strikeout?; self[:lfStrikeOut] == 1 end
			def strikeout=(strikeout) self[:lfStrikeOut] = (strikeout) ? 1 : 0 end

			def update(from)
				case from
				when PropertyStore
					from.each { |k, v|
						case k
						when UI_PKEY_FontProperties_Family; self.face = v.wstring
						when UI_PKEY_FontProperties_Size; self.size = v.decimal.to_f
						when UI_PKEY_FontProperties_Bold; self.bold = v.uint == 2
						when UI_PKEY_FontProperties_Italic; self.italic = v.uint == 2
						when UI_PKEY_FontProperties_Underline; self.underline = v.uint == 2
						when UI_PKEY_FontProperties_Strikethrough; self.strikeout = v.uint == 2
						end
					}
				else raise ArgumentError
				end

				self
			end
		end

		attach_function :CreateFontIndirect, :CreateFontIndirectA, [:pointer], :pointer
	end

	Windows::LOGFONT.send(:include, Toggle)
end
