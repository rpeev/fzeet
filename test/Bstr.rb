require_relative '../lib/fzeet'

include Fzeet

Bstr['foo'].tap { |bstr|
	raise unless bstr.length == 3
	raise unless bstr.multibyte == 'foo'

	bstr.dispose
}

raise unless Bstr.from('foo') { |bstr|
	raise unless bstr.length == 3
}.nil?
