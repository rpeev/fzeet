require 'fzeet/windows'

include Fzeet::Windows

EnableVisualStyles()

MessageBox(nil, 'Hello, world!', 'Hello', MB_ICONINFORMATION)
