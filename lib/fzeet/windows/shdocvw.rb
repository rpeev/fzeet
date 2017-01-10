require_relative 'com'

module Fzeet
	module Windows
		ffi_lib 'shdocvw'
		ffi_convention :stdcall

		DISPID_BEFORENAVIGATE = 100
		DISPID_NAVIGATECOMPLETE = 101
		DISPID_STATUSTEXTCHANGE = 102
		DISPID_QUIT = 103
		DISPID_DOWNLOADCOMPLETE = 104
		DISPID_COMMANDSTATECHANGE = 105
		DISPID_DOWNLOADBEGIN = 106
		DISPID_NEWWINDOW = 107
		DISPID_PROGRESSCHANGE = 108
		DISPID_WINDOWMOVE = 109
		DISPID_WINDOWRESIZE = 110
		DISPID_WINDOWACTIVATE = 111
		DISPID_PROPERTYCHANGE = 112
		DISPID_TITLECHANGE = 113
		DISPID_TITLEICONCHANGE = 114

		DWebBrowserEvents = COM::Interface[IDispatch,
			GUID['EAB22AC2-30C1-11CF-A7EB-0000C05BAE0B'],

			BeforeNavigate: [[:pointer, :long, :pointer, :pointer, :pointer, :pointer], :void],
			NavigateComplete: [[:pointer], :void],
			StatusTextChange: [[:pointer], :void],
			ProgressChange: [[:long, :long], :void],
			DownloadComplete: [[], :void],
			CommandStateChange: [[:long, :short], :void],
			DownloadBegin: [[], :void],
			NewWindow: [[:pointer, :long, :pointer, :pointer, :pointer, :pointer], :void],
			TitleChange: [[:pointer], :void],
			FrameBeforeNavigate: [[:pointer, :long, :pointer, :pointer, :pointer, :pointer], :void],
			FrameNavigateComplete: [[:pointer], :void],
			FrameNewWindow: [[:pointer, :long, :pointer, :pointer, :pointer, :pointer], :void],
			Quit: [[:pointer], :void],
			WindowMove: [[], :void],
			WindowResize: [[], :void],
			WindowActivate: [[], :void],
			PropertyChange: [[:pointer], :void]
		]

		WebBrowserEvents = COM::Callback[DWebBrowserEvents]

		class WebBrowserEvents
			def Invoke(dispid, *rest)
				method = (self.class::VTBL.members - IDispatch::VTBL.members).find { |name|
					dispidName = "DISPID_#{name.upcase}"

					Windows.const_defined?(dispidName) && Windows.const_get(dispidName) == dispid
				}

				return E_NOTIMPL unless method

				send(method, DISPPARAMS.new(rest[3]))

				S_OK
			end
		end

		NavOpenInNewWindow = 0x0001
		NavNoHistory = 0x0002
		NavNoReadFromCache = 0x0004
		NavNoWriteToCache = 0x0008
		NavAllowAutosearch = 0x0010
		NavBrowserBar = 0x0020
		NavHyperlink = 0x0040
		NavEnforceRestricted = 0x0080
		NavNewWindowsManaged = 0x0100
		NavUntrustedForDownload = 0x0200
		NavTrustedForActiveX = 0x0400
		NavOpenInNewTab = 0x0800
		NavOpenInBackgroundTab = 0x1000
		NavKeepWordWheelText = 0x2000
		NavVirtualTab = 0x4000
		NavBlockRedirectsXDomain = 0x8000
		NavOpenNewForegroundTab = 0x10000

		REFRESH_NORMAL = 0
		REFRESH_IFEXPIRED = 1
		REFRESH_COMPLETELY = 3

		IWebBrowser = COM::Interface[IDispatch,
			GUID['EAB22AC1-30C1-11CF-A7EB-0000C05BAE0B'],

			GoBack: [[], :long],
			GoForward: [[], :long],
			GoHome: [[], :long],
			GoSearch: [[], :long],
			Navigate: [[:pointer, :pointer, :pointer, :pointer, :pointer], :long],
			Refresh: [[], :long],
			Refresh2: [[:pointer], :long],
			Stop: [[], :long],
			get_Application: [[:pointer], :long],
			get_Parent: [[:pointer], :long],
			get_Container: [[:pointer], :long],
			get_Document: [[:pointer], :long],
			get_TopLevelContainer: [[:pointer], :long],
			get_Type: [[:pointer], :long],
			get_Left: [[:pointer], :long],
			put_Left: [[:long], :long],
			get_Top: [[:pointer], :long],
			put_Top: [[:long], :long],
			get_Width: [[:pointer], :long],
			put_Width: [[:long], :long],
			get_Height: [[:pointer], :long],
			put_Height: [[:long], :long],
			get_LocationName: [[:pointer], :long],
			get_LocationURL: [[:pointer], :long],
			get_Busy: [[:pointer], :long]
		]

		WebBrowser = COM::Factory[IWebBrowser, GUID['EAB22AC3-30C1-11CF-A7EB-0000C05BAE0B']]
	end

	class WebBrowser < Windows::WebBrowser
		def initialize(parent)
			@parent = parent

			@oips = Windows::OleInPlaceSite.new

			@oips.instance_variable_set(:@browser, self)

			class << @oips
				attr_reader :browser

				def CanInPlaceActivate
					Windows::S_OK
				end

				def GetWindow(phwnd)
					phwnd.write_pointer(browser.parent.handle)

					Windows::S_OK
				end

				def GetWindowContext(pframe, pdoc, prPos, prClip, pinfo)
					pframe.write_pointer(0)
					pdoc.write_pointer(0)
					Windows.GetClientRect(browser.parent.handle, prPos)
					Windows.GetClientRect(browser.parent.handle, prClip)

					Windows::S_OK
				end

				def OnPosRectChange(prPos)
					browser.QueryInstance(Windows::OleInPlaceObject) { |oipo|
						oipo.SetObjectRects(prPos, prPos)
					}

					Windows::S_OK
				end
			end

			@ocs = Windows::OleClientSite.new

			@ocs.instance_variable_set(:@browser, self)

			class << @ocs
				attr_reader :browser

				def QueryInterface(piid, ppv)
					if Windows::GUID.new(piid) == Windows::IOleInPlaceSite::IID
						ppv.write_pointer(browser.oips); browser.oips.AddRef

						return Windows::S_OK
					end

					super
				end
			end

			super()

			@events = Windows::WebBrowserEvents.new

			@events.instance_variable_set(:@browser, self)

			class << @events
				attr_reader :browser

				(self::VTBL.members - Windows::IDispatch::VTBL.members).each { |name|
					define_method(name) { |dispParams|
						(handlers = browser.handlers && browser.handlers[name]) && handlers.each { |handler|
							(handler.arity == 0) ? handler.call : handler.call(dispParams)
						}
					}
				}
			end

			QueryInstance(Windows::ConnectionPointContainer) { |cpc|
				FFI::MemoryPointer.new(:pointer) { |pcp|
					cpc.FindConnectionPoint(Windows::WebBrowserEvents::IID, pcp)

					@cp = Windows::ConnectionPoint.new(pcp.read_pointer)
				}
			}

			@cookie = nil
			FFI::MemoryPointer.new(:ulong) { |p| @cp.Advise(@events, p); @cookie = p.get_ulong(0) }

			QueryInstance(Windows::OleObject) { |oo|
				oo.SetClientSite(@ocs)
				oo.DoVerb(Windows::OLEIVERB_INPLACEACTIVATE, nil, @ocs, 0, @parent.handle, @parent.rect)
			}

			@parent.
				on(:size) {
					r = @parent.rect

					put_Top(r[:top]); put_Left(r[:left]); put_Width(r[:right]); put_Height(r[:bottom])
				}.

				on(:destroy) {
					@oips.Release
					@ocs.Release
					@cp.Unadvise(@cookie)
					@events.Release
					@cp.Release
					Release()
				}.

				instance_variable_set(:@__WebBrowser__, self)
		end

		attr_reader :parent, :oips, :ocs, :events, :cp, :handlers

		def on(event, &block)
			((@handlers ||= {})[event] ||= []) << block

			self
		end

		def goto(where)
			where = Windows.SysAllocString("#{where}\0".encode('utf-16le'))

			Navigate(where, nil, nil, nil, nil)

			self
		ensure
			Windows.SysFreeString(where)
		end

		def back; GoBack(); self; rescue; self end
		def forward; GoForward(); self; rescue; self end
		def home; GoHome(); self end
		def search; GoSearch(); self end

		def refresh; Refresh(); self end

		def document
			disp = nil

			FFI::MemoryPointer.new(:pointer) { |pdisp|
				get_Document(pdisp)

				disp = Windows::Dispatch.new(pdisp.read_pointer)

				return disp.QueryInstance(Windows::HTMLDocument2)
			}
		ensure
			disp.Release if disp
		end
	end
end
