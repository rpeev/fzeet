require 'fzeet'

include Fzeet

message 'Foo'
message 'Foo', caption: 'Bar', buttons: [:yes, :No], icon: :error
message message('Foo').ok?

question 'Foo'
question 'Foo', caption: 'Bar', buttons: [:yes, :No], icon: :exclamation
message question('Foo').no?
