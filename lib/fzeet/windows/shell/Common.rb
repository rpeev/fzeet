require_relative '../user'
require_relative '../com'

module Fzeet
	module Windows
		ffi_lib 'shell32'
		ffi_convention :stdcall

		class PROPERTYKEY < FFI::Struct
			layout \
				:fmtid, GUID,
				:pid, :ulong

			def self.[](type, index)
				new.tap { |key|
					key[:fmtid].tap { |guid|
						guid[:Data1] = 0x00000000 + index
						guid[:Data2] = 0x7363
						guid[:Data3] = 0x696e
						[0x84, 0x41, 0x79, 0x8a, 0xcf, 0x5a, 0xeb, 0xb7].each_with_index { |part, i|
							guid[:Data4][i] = part
						}
					}

					key[:pid] = type
				}
			end

			def ==(other) Windows.memcmp(other, self, size) == 0 end
		end

		attach_function :ShellExecute, :ShellExecuteA, [:pointer, :string, :string, :string, :string, :int], :pointer

		attach_function :SHGetPathFromIDList, :SHGetPathFromIDListA, [:pointer, :pointer], :int

		SIGDN_NORMALDISPLAY = 0x00000000
		SIGDN_PARENTRELATIVEPARSING = 0x80018001
		SIGDN_DESKTOPABSOLUTEPARSING = 0x80028000
		SIGDN_PARENTRELATIVEEDITING = 0x80031001
		SIGDN_DESKTOPABSOLUTEEDITING = 0x8004c000
		SIGDN_FILESYSPATH = 0x80058000
		SIGDN_URL = 0x80068000
		SIGDN_PARENTRELATIVEFORADDRESSBAR = 0x8007c001
		SIGDN_PARENTRELATIVE = 0x80080001

		SICHINT_DISPLAY = 0x00000000
		SICHINT_ALLFIELDS = 0x80000000
		SICHINT_CANONICAL = 0x10000000
		SICHINT_TEST_FILESYSPATH_IF_NOT_EQUAL = 0x20000000

		IShellItem = COM::Interface[IUnknown,
			GUID['43826d1e-e718-42ee-bc55-a1e261c37bfe'],

			BindToHandler: [[:pointer, :pointer, :pointer, :pointer], :long],
			GetParent: [[:pointer], :long],
			GetDisplayName: [[:ulong, :pointer], :long],
			GetAttributes: [[:ulong, :pointer], :long],
			Compare: [[:pointer, :ulong, :pointer], :long]
		]

		ShellItem = COM::Instance[IShellItem]

		class ShellItem
			def path
				result = nil

				FFI::MemoryPointer.new(:pointer) { |pwcs|
					next unless GetDisplayName(SIGDN_FILESYSPATH, pwcs) == S_OK

					wcs = pwcs.read_pointer

					begin
						result = Windows.WCSTOMBS(wcs)
					ensure
						Windows.CoTaskMemFree(wcs)
					end
				}

				result
			end
		end

		SIATTRIBFLAGS_AND = 0x00000001
		SIATTRIBFLAGS_OR = 0x00000002
		SIATTRIBFLAGS_APPCOMPAT = 0x00000003
		SIATTRIBFLAGS_MASK = 0x00000003
		SIATTRIBFLAGS_ALLITEMS = 0x00004000

		IShellItemArray = COM::Interface[IUnknown,
			GUID['b63ea76d-1f85-456f-a19c-48159efa858b'],

			BindToHandler: [[:pointer, :pointer, :pointer, :pointer], :long],
			GetPropertyStore: [[:ulong, :pointer, :pointer], :long],
			GetPropertyDescriptionList: [[:pointer, :pointer, :pointer], :long],
			GetAttributes: [[:ulong, :ulong, :pointer], :long],
			GetCount: [[:pointer], :long],
			GetItemAt: [[:ulong, :pointer], :long],
			EnumItems: [[:pointer], :long]
		]

		ShellItemArray = COM::Instance[IShellItemArray]

		class ShellItemArray
			include Enumerable

			def count; FFI::MemoryPointer.new(:ulong) { |pc| next unless GetCount(pc) == S_OK; return pc.get_ulong(0) } end
			alias :size :count
			alias :length :count

			def get(i)
				FFI::MemoryPointer.new(:pointer) { |psi|
					next unless GetItemAt(i, psi) == S_OK

					si = ShellItem.new(psi.read_pointer)

					begin
						yield si
					ensure
						si.Release
					end
				}
			end

			def each(&block) length.times { |i| get(i, &block) }; self end
		end

		IModalWindow = COM::Interface[IUnknown,
			GUID['b4db1657-70d7-485e-8e3e-6fcb5a5c1802'],

			Show: [[:pointer], :long]
		]

		ModalWindow = COM::Instance[IModalWindow]

		IExplorerBrowserEvents = COM::Interface[IUnknown,
			GUID['361bbdc7-e6ee-4e13-be58-58e2240c810f'],

			OnNavigationPending: [[:pointer], :long],
			OnViewCreated: [[:pointer], :long],
			OnNavigationComplete: [[:pointer], :long],
			OnNavigationFailed: [[:pointer], :long]
		]

		ExplorerBrowserEvents = COM::Callback[IExplorerBrowserEvents]

		EBO_NONE = 0x00000000
		EBO_NAVIGATEONCE = 0x00000001
		EBO_SHOWFRAMES = 0X00000002
		EBO_ALWAYSNAVIGATE = 0x00000004
		EBO_NOTRAVELLOG = 0x00000008
		EBO_NOWRAPPERWINDOW = 0x00000010
		EBO_HTMLSHAREPOINTVIEW = 0x00000020

		EBF_NONE = 0x0000000
		EBF_SELECTFROMDATAOBJECT = 0x0000100
		EBF_NODROPTARGET = 0x0000200

		IExplorerBrowser = COM::Interface[IUnknown,
			GUID['dfd3b6b5-c10c-4be9-85f6-a66969f402f6'],

			Initialize: [[:pointer, :pointer, :pointer], :long],
			Destroy: [[], :long],
			SetRect: [[:pointer, RECT.by_value], :long],
			SetPropertyBag: [[:buffer_in], :long],
			SetEmptyText: [[:buffer_in], :long],
			SetFolderSettings: [[:pointer], :long],
			Advise: [[:pointer, :pointer], :long],
			Unadvise: [[:ulong], :long],
			SetOptions: [[:ulong], :long],
			GetOptions: [[:pointer], :long],
			BrowseToIDList: [[:pointer, :uint], :long],
			BrowseToObject: [[:pointer, :uint], :long],
			FillFromObject: [[:pointer, :ulong], :long],
			RemoveAll: [[], :long],
			GetCurrentView: [[:pointer, :pointer], :long]
		]

		ExplorerBrowser = COM::Factory[IExplorerBrowser, GUID['71f96385-ddd6-48d3-a0c1-ae06e8b055fb']]

		FOLDERID_NetworkFolder = GUID['D20BEEC4-5CA8-4905-AE3B-BF251EA09B53']
		FOLDERID_ComputerFolder = GUID['0AC0837C-BBF8-452A-850D-79D08E667CA7']
		FOLDERID_InternetFolder = GUID['4D9F7874-4E0C-4904-967B-40B0D20C3E4B']
		FOLDERID_ControlPanelFolder = GUID['82A74AEB-AEB4-465C-A014-D097EE346D63']
		FOLDERID_PrintersFolder = GUID['76FC4E2D-D6AD-4519-A663-37BD56068185']
		FOLDERID_SyncManagerFolder = GUID['43668BF8-C14E-49B2-97C9-747784D784B7']
		FOLDERID_SyncSetupFolder = GUID['0F214138-B1D3-4a90-BBA9-27CBC0C5389A']
		FOLDERID_ConflictFolder = GUID['4bfefb45-347d-4006-a5be-ac0cb0567192']
		FOLDERID_SyncResultsFolder = GUID['289a9a43-be44-4057-a41b-587a76d7e7f9']
		FOLDERID_RecycleBinFolder = GUID['B7534046-3ECB-4C18-BE4E-64CD4CB7D6AC']
		FOLDERID_ConnectionsFolder = GUID['6F0CD92B-2E97-45D1-88FF-B0D186B8DEDD']
		FOLDERID_Fonts = GUID['FD228CB7-AE11-4AE3-864C-16F3910AB8FE']
		FOLDERID_Desktop = GUID['B4BFCC3A-DB2C-424C-B029-7FE99A87C641']
		FOLDERID_Startup = GUID['B97D20BB-F46A-4C97-BA10-5E3608430854']
		FOLDERID_Programs = GUID['A77F5D77-2E2B-44C3-A6A2-ABA601054A51']
		FOLDERID_StartMenu = GUID['625B53C3-AB48-4EC1-BA1F-A1EF4146FC19']
		FOLDERID_Recent = GUID['AE50C081-EBD2-438A-8655-8A092E34987A']
		FOLDERID_SendTo = GUID['8983036C-27C0-404B-8F08-102D10DCFD74']
		FOLDERID_Documents = GUID['FDD39AD0-238F-46AF-ADB4-6C85480369C7']
		FOLDERID_Favorites = GUID['1777F761-68AD-4D8A-87BD-30B759FA33DD']
		FOLDERID_NetHood = GUID['C5ABBF53-E17F-4121-8900-86626FC2C973']
		FOLDERID_PrintHood = GUID['9274BD8D-CFD1-41C3-B35E-B13F55A758F4']
		FOLDERID_Templates = GUID['A63293E8-664E-48DB-A079-DF759E0509F7']
		FOLDERID_CommonStartup = GUID['82A5EA35-D9CD-47C5-9629-E15D2F714E6E']
		FOLDERID_CommonPrograms = GUID['0139D44E-6AFE-49F2-8690-3DAFCAE6FFB8']
		FOLDERID_CommonStartMenu = GUID['A4115719-D62E-491D-AA7C-E74B8BE3B067']
		FOLDERID_PublicDesktop = GUID['C4AA340D-F20F-4863-AFEF-F87EF2E6BA25']
		FOLDERID_ProgramData = GUID['62AB5D82-FDC1-4DC3-A9DD-070D1D495D97']
		FOLDERID_CommonTemplates = GUID['B94237E7-57AC-4347-9151-B08C6C32D1F7']
		FOLDERID_PublicDocuments = GUID['ED4824AF-DCE4-45A8-81E2-FC7965083634']
		FOLDERID_RoamingAppData = GUID['3EB685DB-65F9-4CF6-A03A-E3EF65729F3D']
		FOLDERID_LocalAppData = GUID['F1B32785-6FBA-4FCF-9D55-7B8E7F157091']
		FOLDERID_LocalAppDataLow = GUID['A520A1A4-1780-4FF6-BD18-167343C5AF16']
		FOLDERID_InternetCache = GUID['352481E8-33BE-4251-BA85-6007CAEDCF9D']
		FOLDERID_Cookies = GUID['2B0F765D-C0E9-4171-908E-08A611B84FF6']
		FOLDERID_History = GUID['D9DC8A3B-B784-432E-A781-5A1130A75963']
		FOLDERID_System = GUID['1AC14E77-02E7-4E5D-B744-2EB1AE5198B7']
		FOLDERID_SystemX86 = GUID['D65231B0-B2F1-4857-A4CE-A8E7C6EA7D27']
		FOLDERID_Windows = GUID['F38BF404-1D43-42F2-9305-67DE0B28FC23']
		FOLDERID_Profile = GUID['5E6C858F-0E22-4760-9AFE-EA3317B67173']
		FOLDERID_Pictures = GUID['33E28130-4E1E-4676-835A-98395C3BC3BB']
		FOLDERID_ProgramFilesX86 = GUID['7C5A40EF-A0FB-4BFC-874A-C0F2E0B9FA8E']
		FOLDERID_ProgramFilesCommonX86 = GUID['DE974D24-D9C6-4D3E-BF91-F4455120B917']
		FOLDERID_ProgramFilesX64 = GUID['6D809377-6AF0-444b-8957-A3773F02200E']
		FOLDERID_ProgramFilesCommonX64 = GUID['6365D5A7-0F0D-45e5-87F6-0DA56B6A4F7D']
		FOLDERID_ProgramFiles = GUID['905e63b6-c1bf-494e-b29c-65b732d3d21a']
		FOLDERID_ProgramFilesCommon = GUID['F7F1ED05-9F6D-47A2-AAAE-29D317C6F066']
		FOLDERID_UserProgramFiles = GUID['5cd7aee2-2219-4a67-b85d-6c9ce15660cb']
		FOLDERID_UserProgramFilesCommon = GUID['bcbd3057-ca5c-4622-b42d-bc56db0ae516']
		FOLDERID_AdminTools = GUID['724EF170-A42D-4FEF-9F26-B60E846FBA4F']
		FOLDERID_CommonAdminTools = GUID['D0384E7D-BAC3-4797-8F14-CBA229B392B5']
		FOLDERID_Music = GUID['4BD8D571-6D19-48D3-BE97-422220080E43']
		FOLDERID_Videos = GUID['18989B1D-99B5-455B-841C-AB7C74E4DDFC']
		FOLDERID_Ringtones = GUID['C870044B-F49E-4126-A9C3-B52A1FF411E8']
		FOLDERID_PublicPictures = GUID['B6EBFB86-6907-413C-9AF7-4FC2ABF07CC5']
		FOLDERID_PublicMusic = GUID['3214FAB5-9757-4298-BB61-92A9DEAA44FF']
		FOLDERID_PublicVideos = GUID['2400183A-6185-49FB-A2D8-4A392A602BA3']
		FOLDERID_PublicRingtones = GUID['E555AB60-153B-4D17-9F04-A5FE99FC15EC']
		FOLDERID_ResourceDir = GUID['8AD10C31-2ADB-4296-A8F7-E4701232C972']
		FOLDERID_LocalizedResourcesDir = GUID['2A00375E-224C-49DE-B8D1-440DF7EF3DDC']
		FOLDERID_CommonOEMLinks = GUID['C1BAE2D0-10DF-4334-BEDD-7AA20B227A9D']
		FOLDERID_CDBurning = GUID['9E52AB10-F80D-49DF-ACB8-4330F5687855']
		FOLDERID_UserProfiles = GUID['0762D272-C50A-4BB0-A382-697DCD729B80']
		FOLDERID_Playlists = GUID['DE92C1C7-837F-4F69-A3BB-86E631204A23']
		FOLDERID_SamplePlaylists = GUID['15CA69B3-30EE-49C1-ACE1-6B5EC372AFB5']
		FOLDERID_SampleMusic = GUID['B250C668-F57D-4EE1-A63C-290EE7D1AA1F']
		FOLDERID_SamplePictures = GUID['C4900540-2379-4C75-844B-64E6FAF8716B']
		FOLDERID_SampleVideos = GUID['859EAD94-2E85-48AD-A71A-0969CB56A6CD']
		FOLDERID_PhotoAlbums = GUID['69D2CF90-FC33-4FB7-9A0C-EBB0F0FCB43C']
		FOLDERID_Public = GUID['DFDF76A2-C82A-4D63-906A-5644AC457385']
		FOLDERID_ChangeRemovePrograms = GUID['df7266ac-9274-4867-8d55-3bd661de872d']
		FOLDERID_AppUpdates = GUID['a305ce99-f527-492b-8b1a-7e76fa98d6e4']
		FOLDERID_AddNewPrograms = GUID['de61d971-5ebc-4f02-a3a9-6c82895e5c04']
		FOLDERID_Downloads = GUID['374DE290-123F-4565-9164-39C4925E467B']
		FOLDERID_PublicDownloads = GUID['3D644C9B-1FB8-4f30-9B45-F670235F79C0']
		FOLDERID_SavedSearches = GUID['7d1d3a04-debb-4115-95cf-2f29da2920da']
		FOLDERID_QuickLaunch = GUID['52a4f021-7b75-48a9-9f6b-4b87a210bc8f']
		FOLDERID_Contacts = GUID['56784854-C6CB-462b-8169-88E350ACB882']
		FOLDERID_SidebarParts = GUID['A75D362E-50FC-4fb7-AC2C-A8BEAA314493']
		FOLDERID_SidebarDefaultParts = GUID['7B396E54-9EC5-4300-BE0A-2482EBAE1A26']
		FOLDERID_PublicGameTasks = GUID['DEBF2536-E1A8-4c59-B6A2-414586476AEA']
		FOLDERID_GameTasks = GUID['054FAE61-4DD8-4787-80B6-090220C4B700']
		FOLDERID_SavedGames = GUID['4C5C32FF-BB9D-43b0-B5B4-2D72E54EAAA4']
		FOLDERID_Games = GUID['CAC52C1A-B53D-4edc-92D7-6B2E8AC19434']
		FOLDERID_SEARCH_MAPI = GUID['98ec0e18-2098-4d44-8644-66979315a281']
		FOLDERID_SEARCH_CSC = GUID['ee32e446-31ca-4aba-814f-a5ebd2fd6d5e']
		FOLDERID_Links = GUID['bfb9d5e0-c6a9-404c-b2b2-ae6db6af4968']
		FOLDERID_UsersFiles = GUID['f3ce0f7c-4901-4acc-8648-d5d44b04ef8f']
		FOLDERID_UsersLibraries = GUID['A302545D-DEFF-464b-ABE8-61C8648D939B']
		FOLDERID_SearchHome = GUID['190337d1-b8ca-4121-a639-6d472d16972a']
		FOLDERID_OriginalImages = GUID['2C36C0AA-5812-4b87-BFD0-4CD0DFB19B39']
		FOLDERID_DocumentsLibrary = GUID['7b0db17d-9cd2-4a93-9733-46cc89022e7c']
		FOLDERID_MusicLibrary = GUID['2112AB0A-C86A-4ffe-A368-0DE96E47012E']
		FOLDERID_PicturesLibrary = GUID['A990AE9F-A03B-4e80-94BC-9912D7504104']
		FOLDERID_VideosLibrary = GUID['491E922F-5643-4af4-A7EB-4E7A138D8174']
		FOLDERID_RecordedTVLibrary = GUID['1A6FDBA2-F42D-4358-A798-B74D745926C5']
		FOLDERID_HomeGroup = GUID['52528A6B-B9E3-4add-B60D-588C2DBA842D']
		FOLDERID_DeviceMetadataStore = GUID['5CE4A5E9-E4EB-479D-B89F-130C02886155']
		FOLDERID_Libraries = GUID['1B3EA5DC-B587-4786-B4EF-BD1DC332AEAE']
		FOLDERID_PublicLibraries = GUID['48daf80b-e6cf-4f4e-b800-0e69d84ee384']
		FOLDERID_UserPinned = GUID['9e3995ab-1f9c-4f13-b827-48b24b6c7174']
		FOLDERID_ImplicitAppShortcuts = GUID['bcb5256f-79f6-4cee-b725-dc34e402fd46']

		if Version >= :vista
			attach_function :SHGetKnownFolderIDList, [:pointer, :ulong, :pointer, :pointer], :long
		end

		SBSP_DEFBROWSER = 0x0000
		SBSP_SAMEBROWSER = 0x0001
		SBSP_NEWBROWSER = 0x0002
		SBSP_DEFMODE = 0x0000
		SBSP_OPENMODE = 0x0010
		SBSP_EXPLOREMODE = 0x0020
		SBSP_HELPMODE = 0x0040
		SBSP_NOTRANSFERHIST = 0x0080
		SBSP_ABSOLUTE = 0x0000
		SBSP_RELATIVE = 0x1000
		SBSP_PARENT = 0x2000
		SBSP_NAVIGATEBACK = 0x4000
		SBSP_NAVIGATEFORWARD = 0x8000
		SBSP_ALLOW_AUTONAVIGATE = 0x00010000
		SBSP_KEEPSAMETEMPLATE = 0x00020000
		SBSP_KEEPWORDWHEELTEXT = 0x00040000
		SBSP_ACTIVATE_NOFOCUS = 0x00080000
		SBSP_CREATENOHISTORY = 0x00100000
		SBSP_PLAYNOSOUND = 0x00200000
		SBSP_CALLERUNTRUSTED = 0x00800000
		SBSP_TRUSTFIRSTDOWNLOAD = 0x01000000
		SBSP_UNTRUSTEDFORDOWNLOAD = 0x02000000
		SBSP_NOAUTOSELECT = 0x04000000
		SBSP_WRITENOHISTORY = 0x08000000
		SBSP_TRUSTEDFORACTIVEX = 0x10000000
		SBSP_FEEDNAVIGATION = 0x20000000
		SBSP_REDIRECT = 0x40000000
		SBSP_INITIATEDBYHLINKFRAME = 0x80000000
	end

	def shell(name, args = nil, dir = nil, verb = 'open')
		raise 'ShellExecute failed.' unless Windows.ShellExecute(nil, verb, name, args, dir, Windows::SW_NORMAL).to_i > 32
	end

	module_function :shell

	class ExplorerBrowser < Windows::ExplorerBrowser
		def initialize(parent)
			@parent = parent

			super()

			@events = Windows::ExplorerBrowserEvents.new

			@events.instance_variable_set(:@browser, self)

			class << @events
				attr_reader :browser

				(self::VTBL.members - Windows::IUnknown::VTBL.members).each { |name|
					define_method(name) { |*args|
						(handlers = browser.handlers && browser.handlers[name]) && handlers.each { |handler|
							(handler.arity == 0) ? handler.call : handler.call(*args)
						}

						Windows::S_OK
					}
				}
			end

			@cookie = nil
			FFI::MemoryPointer.new(:ulong) { |p| Advise(@events, p); @cookie = p.get_ulong(0) }

			Initialize(@parent.handle, parent.rect, nil)

			@parent.
				on(:size) { SetRect(nil, @parent.rect) }.
				on(:destroy) { Unadvise(@cookie); @events.Release; Destroy(); Release() }.

				instance_variable_set(:@__ExplorerBrowser__, self)
		end

		attr_reader :parent, :events, :handlers

		def on(event, &block)
			((@handlers ||= {})["On#{event}".to_sym] ||= []) << block

			self
		end

		def goto(where)
			pidl = nil

			FFI::MemoryPointer.new(:pointer) { |p|
				Windows.SHGetKnownFolderIDList(Windows.const_get("FOLDERID_#{where}"), 0, nil, p)

				BrowseToIDList(pidl = p.read_pointer, 0)
			}

			self
		ensure
			Windows.CoTaskMemFree(pidl)
		end

		def back; BrowseToIDList(nil, Windows::SBSP_NAVIGATEBACK); self end
		def forward; BrowseToIDList(nil, Windows::SBSP_NAVIGATEFORWARD); self end
		def up; BrowseToIDList(nil, Windows::SBSP_PARENT); self end
	end
end
