require 'fzeet'

include Fzeet

message <<-MSG
Ruby #{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}

Windows #{Windows::Version}
MSG
