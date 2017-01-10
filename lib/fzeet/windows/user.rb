require_relative 'user/MessageBox'
require_relative 'user/Window'
require_relative 'user/Message'
require_relative 'user/Menu'
require_relative 'user/Accelerator'
require_relative 'user/Control'
require_relative 'user/SystemParametersInfo'

module Fzeet
	class Command
		@ids = {
			OK: Windows::IDOK,
			CANCEL: Windows::IDCANCEL,
		}
		@nextId = Windows::WM_APP + 1

		def self.[](id)
			return id if id.kind_of?(Integer)

			id = id.upcase

			@ids[id], @nextId = @nextId, @nextId + 1 unless @ids.include?(id)

			@ids[id]
		end
	end
end
