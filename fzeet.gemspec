require 'rake'

require_relative 'lib/fzeet'

Gem::Specification.new do |spec|
  spec.name = 'fzeet'
  spec.version = FZEET_VERSION

  spec.summary = 'Ruby FFI (x86) bindings to (plus rubyesque APIs on top) GUI/COM related Windows APIs'
  spec.description = 'Ruby FFI (x86) bindings to (plus rubyesque APIs on top) GUI/COM related Windows APIs'
  spec.homepage = 'https://github.com/rpeev/fzeet'

  spec.authors = ['Radoslav Peev']
  spec.email = ['rpeev@ymail.com']
  spec.licenses = ['MIT']

  spec.files = FileList[
    'LICENSE', 'LICENSE_Scintilla',
    'README.md', 'screenshot.png',
    'RELNOTES.md',
    'lib/fzeet.rb',
    'lib/fzeet/*.rb',
    'lib/fzeet/windows/*.rb',
    'lib/fzeet/windows/core/*.rb',
    'lib/fzeet/windows/kernel/*.rb',
    'lib/fzeet/windows/gdi/*.rb',
    'lib/fzeet/windows/user/*.rb',
    'lib/fzeet/windows/user/Window/*.rb',
    'lib/fzeet/windows/user/Control/*.rb',
    'lib/fzeet/windows/comctl/*.rb',
    'lib/fzeet/windows/comdlg/*.rb',
    'lib/fzeet/windows/com/*.rb',
    'lib/fzeet/windows/ole/*.rb',
    'lib/fzeet/windows/oleaut/*.rb',
    'lib/fzeet/windows/shell/*.rb',
    'lib/fzeet/windows/mshtml/*.rb',
    'lib/fzeet/windows/scintilla/*.*',
    'examples/*.*', 'examples/res/*.*',
    'examples/Raw/*.*', 'examples/Raw/UIRibbon/*.*',
    'examples/Menu/*.*',
    'examples/Control/*.*', 'examples/Control/WebBrowser/*.*',
    'examples/Dialog/*.*',
    'examples/UIRibbon/*.*', 'examples/UIRibbon/Control/*.*'
  ]
  spec.require_paths = ['lib']
  spec.add_runtime_dependency('ffi', '~> 1')
end
