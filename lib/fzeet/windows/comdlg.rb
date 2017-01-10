require_relative 'comdlg/FileDialog'
require_relative 'comdlg/ShellFileDialog' if Fzeet::Windows::Version >= :vista
require_relative 'comdlg/FontDialog'
require_relative 'comdlg/ColorDialog'
require_relative 'comdlg/FindReplaceDialog'
require_relative 'comdlg/PrintDialog'
