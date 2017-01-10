require_relative '../oleaut'

module Fzeet
	module Windows
		ffi_lib 'mshtml'
		ffi_convention :stdcall

		IHTMLDocument = COM::Interface[IDispatch,
			GUID['626FC520-A41E-11cf-A731-00A0C9082637'],

			get_Script: [[:pointer], :long]
		]

		HTMLDocument = COM::Instance[IHTMLDocument]

		IHTMLDocument2 = COM::Interface[IHTMLDocument,
			GUID['332c4425-26cb-11d0-b483-00c04fd90119'],

			get_all: [[:pointer], :long],
			get_body: [[:pointer], :long],
			get_activeElement: [[:pointer], :long],
			get_images: [[:pointer], :long],
			get_applets: [[:pointer], :long],
			get_links: [[:pointer], :long],
			get_forms: [[:pointer], :long],
			get_anchors: [[:pointer], :long],
			put_title: [[:pointer], :long],
			get_title: [[:pointer], :long],
			get_scripts: [[:pointer], :long],
			put_designMode: [[:pointer], :long],
			get_designMode: [[:pointer], :long],
			get_selection: [[:pointer], :long],
			get_readyState: [[:pointer], :long],
			get_frames: [[:pointer], :long],
			get_embeds: [[:pointer], :long],
			get_plugins: [[:pointer], :long],
			put_alinkColor: [[VARIANT.by_value], :long],
			get_alinkColor: [[:pointer], :long],
			put_bgColor: [[VARIANT.by_value], :long],
			get_bgColor: [[:pointer], :long],
			put_fgColor: [[VARIANT.by_value], :long],
			get_fgColor: [[:pointer], :long],
			put_linkColor: [[VARIANT.by_value], :long],
			get_linkColor: [[:pointer], :long],
			put_vlinkColor: [[VARIANT.by_value], :long],
			get_vlinkColor: [[:pointer], :long],
			get_referrer: [[:pointer], :long],
			get_location: [[:pointer], :long],
			get_lastModified: [[:pointer], :long],
			put_URL: [[:pointer], :long],
			get_URL: [[:pointer], :long],
			put_domain: [[:pointer], :long],
			get_domain: [[:pointer], :long],
			put_cookie: [[:pointer], :long],
			get_cookie: [[:pointer], :long],
			put_expando: [[:short], :long],
			get_expando: [[:pointer], :long],
			put_charset: [[:pointer], :long],
			get_charset: [[:pointer], :long],
			put_defaultCharset: [[:pointer], :long],
			get_defaultCharset: [[:pointer], :long],
			get_mimeType: [[:pointer], :long],
			get_fileSize: [[:pointer], :long],
			get_fileCreatedDate: [[:pointer], :long],
			get_fileModifiedDate: [[:pointer], :long],
			get_fileUpdatedDate: [[:pointer], :long],
			get_security: [[:pointer], :long],
			get_protocol: [[:pointer], :long],
			get_nameProp: [[:pointer], :long],
			write: [[:pointer], :long],
			writeln: [[:pointer], :long],
			open: [[:pointer, VARIANT.by_value, VARIANT.by_value, VARIANT.by_value, :pointer], :long],
			close: [[], :long],
			clear: [[], :long],
			queryCommandSupported: [[:pointer, :pointer], :long],
			queryCommandEnabled: [[:pointer, :pointer], :long],
			queryCommandState: [[:pointer, :pointer], :long],
			queryCommandIndeterm: [[:pointer, :pointer], :long],
			queryCommandText: [[:pointer, :pointer], :long],
			queryCommandValue: [[:pointer, :pointer], :long],
			execCommand: [[:pointer, :short, VARIANT.by_value, :pointer], :long],
			execCommandShowHelp: [[:pointer, :pointer], :long],
			createElement: [[:pointer, :pointer], :long],
			put_onhelp: [[VARIANT.by_value], :long],
			get_onhelp: [[:pointer], :long],
			put_onclick: [[VARIANT.by_value], :long],
			get_onclick: [[:pointer], :long],
			put_ondblclick: [[VARIANT.by_value], :long],
			get_ondblclick: [[:pointer], :long],
			put_onkeyup: [[VARIANT.by_value], :long],
			get_onkeyup: [[:pointer], :long],
			put_onkeydown: [[VARIANT.by_value], :long],
			get_onkeydown: [[:pointer], :long],
			put_onkeypress: [[VARIANT.by_value], :long],
			get_onkeypress: [[:pointer], :long],
			put_onmouseup: [[VARIANT.by_value], :long],
			get_onmouseup: [[:pointer], :long],
			put_onmousedown: [[VARIANT.by_value], :long],
			get_onmousedown: [[:pointer], :long],
			put_onmousemove: [[VARIANT.by_value], :long],
			get_onmousemove: [[:pointer], :long],
			put_onmouseout: [[VARIANT.by_value], :long],
			get_onmouseout: [[:pointer], :long],
			put_onmouseover: [[VARIANT.by_value], :long],
			get_onmouseover: [[:pointer], :long],
			put_onreadystatechange: [[VARIANT.by_value], :long],
			get_onreadystatechange: [[:pointer], :long],
			put_onafterupdate: [[VARIANT.by_value], :long],
			get_onafterupdate: [[:pointer], :long],
			put_onrowexit: [[VARIANT.by_value], :long],
			get_onrowexit: [[:pointer], :long],
			put_onrowenter: [[VARIANT.by_value], :long],
			get_onrowenter: [[:pointer], :long],
			put_ondragstart: [[VARIANT.by_value], :long],
			get_ondragstart: [[:pointer], :long],
			put_onselectstart: [[VARIANT.by_value], :long],
			get_onselectstart: [[:pointer], :long],
			elementFromPoint: [[:long, :long, :pointer], :long],
			get_parentWindow: [[:pointer], :long],
			get_styleSheets: [[:pointer], :long],
			put_onbeforeupdate: [[VARIANT.by_value], :long],
			get_onbeforeupdate: [[:pointer], :long],
			put_onerrorupdate: [[VARIANT.by_value], :long],
			get_onerrorupdate: [[:pointer], :long],
			toString: [[:pointer], :long],
			createStyleSheet: [[:pointer, :long, :pointer], :long]
		]

		HTMLDocument2 = COM::Instance[IHTMLDocument2]

		class HTMLDocument2
			attr_reader :handlers

			def on(event, &block)
				_event, _block = if event == :ready
					[:readystatechange, -> *args { next unless readyState == 'complete'; block.(*args) }]
				else
					[event, block]
				end

				((@handlers ||= {})[_event] ||= []) << _block
				@dcallbacks ||= []

				send("put_on#{_event}", VARIANT.new.tap { |v|
					v[:vt] = VT_DISPATCH

					v[:pdispVal] = @dcallbacks.push(DCallback.new.tap { |dcb|
						dcb.instance_variable_set(:@document, self)
						dcb.instance_variable_set(:@event, _event)

						def dcb.Invoke(*args)
							@document.handlers[@event].each { |handler|
								(handler.arity == 0) ? handler.call : handler.call(*args)
							}

							S_OK
						end
					}).last
				}) unless @handlers[_event].length > 1

				self
			end

			def parentWindow
				FFI::MemoryPointer.new(:pointer) { |pwindow|
					get_parentWindow(pwindow)

					return HTMLWindow2.new(pwindow.read_pointer)
				}
			end

			alias window parentWindow

			def request?; Windows.CoInternetIsFeatureEnabled(FEATURE_XMLHTTP, GET_FEATURE_FROM_PROCESS) == S_OK end
			def request=(enabled) Windows.DetonateHresult(:CoInternetSetFeatureEnabled, FEATURE_XMLHTTP, SET_FEATURE_ON_PROCESS, (enabled) ? 1 : 0) end

			def request
				disp = nil

				window.QueryInstance(HTMLWindow5) { |htmlwindow5|
					disp = Dispatch.new(VARIANT.new.tap { |v| htmlwindow5.get_XMLHttpRequest(v) }[:pdispVal])

					disp.QueryInstance(HTMLXMLHttpRequestFactory) { |factory|
						FFI::MemoryPointer.new(:pointer) { |prequest|
							factory.create(prequest)

							return HTMLXMLHttpRequest.new(prequest.read_pointer)
						}
					}
				}
			ensure
				disp.Release if disp
			end

			def xrequest
				disp = nil

				window.QueryInstance(HTMLWindow6) { |htmlwindow6|
					disp = Dispatch.new(VARIANT.new.tap { |v| htmlwindow6.get_XDomainRequest(v) }[:pdispVal])

					disp.QueryInstance(HTMLXDomainRequestFactory) { |factory|
						FFI::MemoryPointer.new(:pointer) { |pxrequest|
							factory.create(pxrequest)

							return HTMLXDomainRequest.new(pxrequest.read_pointer)
						}
					}
				}
			ensure
				disp.Release if disp
			end

			def readyState
				FFI::MemoryPointer.new(:pointer) { |pstate|
					get_readyState(pstate)

					return Windows.WCSTOMBS(pstate.read_pointer)
				}
			end

			def all
				pdisp = nil

				FFI::MemoryPointer.new(:pointer) { |pdisp|
					get_all(pdisp)

					disp = Dispatch.new(pdisp.read_pointer)

					return disp.QueryInstance(HTMLElementCollection)
				}
			ensure
				pdisp.Release if pdisp
			end

			alias old_createElement createElement

			def createElement(tag)
				bstr = nil

				FFI::MemoryPointer.new(:pointer) { |pelem|
					old_createElement(bstr = Windows.SysAllocString("#{tag}\0".encode('utf-16le')), pelem)

					return HTMLElement.new(pelem.read_pointer)
				}
			ensure
				Windows.SysFreeString(bstr)
			end
		end

		IHTMLFramesCollection2 = COM::Interface[IDispatch,
			GUID['332c4426-26cb-11d0-b483-00c04fd90119'],

			item: [[:pointer, :pointer], :long],
			get_length: [[:pointer], :long]
		]

		HTMLFramesCollection2 = COM::Instance[IHTMLFramesCollection2]

		IHTMLWindow2 = COM::Interface[IHTMLFramesCollection2,
			GUID['332c4427-26cb-11d0-b483-00c04fd90119'],

			get_frames: [[:pointer], :long],
			put_defaultStatus: [[:pointer], :long],
			get_defaultStatus: [[:pointer], :long],
			put_status: [[:pointer], :long],
			get_status: [[:pointer], :long],
			setTimeout: [[:pointer, :long, :pointer, :pointer], :long],
			clearTimeout: [[:long], :long],
			alert: [[:pointer], :long],
			confirm: [[:pointer, :pointer], :long],
			prompt: [[:pointer, :pointer, :pointer], :long],
			get_Image: [[:pointer], :long],
			get_location: [[:pointer], :long],
			get_history: [[:pointer], :long],
			close: [[], :long],
			put_opener: [[VARIANT.by_value], :long],
			get_opener: [[:pointer], :long],
			get_navigator: [[:pointer], :long],
			put_name: [[:pointer], :long],
			get_name: [[:pointer], :long],
			get_parent: [[:pointer], :long],
			open: [[:pointer, :pointer, :pointer, :short, :pointer], :long],
			get_self: [[:pointer], :long],
			get_top: [[:pointer], :long],
			get_window: [[:pointer], :long],
			navigate: [[:pointer], :long],
			put_onfocus: [[VARIANT.by_value], :long],
			get_onfocus: [[:pointer], :long],
			put_onblur: [[VARIANT.by_value], :long],
			get_onblur: [[:pointer], :long],
			put_onload: [[VARIANT.by_value], :long],
			get_onload: [[:pointer], :long],
			put_onbeforeunload: [[VARIANT.by_value], :long],
			get_onbeforeunload: [[:pointer], :long],
			put_onunload: [[VARIANT.by_value], :long],
			get_onunload: [[:pointer], :long],
			put_onhelp: [[VARIANT.by_value], :long],
			get_onhelp: [[:pointer], :long],
			put_onerror: [[VARIANT.by_value], :long],
			get_onerror: [[:pointer], :long],
			put_onresize: [[VARIANT.by_value], :long],
			get_onresize: [[:pointer], :long],
			put_onscroll: [[VARIANT.by_value], :long],
			get_onscroll: [[:pointer], :long],
			get_document: [[:pointer], :long],
			get_event: [[:pointer], :long],
			get__newEnum: [[:pointer], :long],
			showModalDialog: [[:pointer, :pointer, :pointer, :pointer], :long],
			showHelp: [[:pointer, VARIANT.by_value, :pointer], :long],
			get_screen: [[:pointer], :long],
			get_Option: [[:pointer], :long],
			focus: [[], :long],
			get_closed: [[:pointer], :long],
			blur: [[], :long],
			scroll: [[:long, :long], :long],
			get_clientInformation: [[:pointer], :long],
			setInterval: [[:pointer, :long, :pointer, :pointer], :long],
			clearInterval: [[:long], :long],
			put_offscreenBuffering: [[VARIANT.by_value], :long],
			get_offscreenBuffering: [[:pointer], :long],
			execScript: [[:pointer, :pointer, :pointer], :long],
			toString: [[:pointer], :long],
			scrollBy: [[:long, :long], :long],
			scrollTo: [[:long, :long], :long],
			moveTo: [[:long, :long], :long],
			moveBy: [[:long, :long], :long],
			resizeTo: [[:long, :long], :long],
			resizeBy: [[:long, :long], :long],
			get_external: [[:pointer], :long]
		]

		HTMLWindow2 = COM::Instance[IHTMLWindow2]

		class HTMLWindow2
			attr_reader :handlers

			def on(event, &block)
				((@handlers ||= {})[event] ||= []) << block
				@dcallbacks ||= []

				send("put_on#{event}", VARIANT.new.tap { |v|
					v[:vt] = VT_DISPATCH

					v[:pdispVal] = @dcallbacks.push(DCallback.new.tap { |dcb|
						dcb.instance_variable_set(:@window, self)
						dcb.instance_variable_set(:@event, event)

						def dcb.Invoke(*args)
							@window.handlers[@event].each { |handler|
								(handler.arity == 0) ? handler.call : handler.call(*args)
							}

							S_OK
						end
					}).last
				}) unless @handlers[event].length > 1

				self
			end
		end

		IHTMLWindow5 = COM::Interface[IDispatch,
			GUID['3051040e-98b5-11cf-bb82-00aa00bdce0b'],

			put_XMLHttpRequest: [[VARIANT.by_value], :long],
			get_XMLHttpRequest: [[:pointer], :long]
		]

		HTMLWindow5 = COM::Instance[IHTMLWindow5]

		IHTMLWindow6 = COM::Interface[IDispatch,
			GUID['30510453-98b5-11cf-bb82-00aa00bdce0b'],

			put_XDomainRequest: [[VARIANT.by_value], :long],
			get_XDomainRequest: [[:pointer], :long],
			get_sessionStorage: [[:pointer], :long],
			get_localStorage: [[:pointer], :long],
			put_onhashchange: [[VARIANT.by_value], :long],
			get_onhashchange: [[:pointer], :long],
			get_maxConnectionsPerServer: [[:pointer], :long],
			postMessage: [[:pointer, VARIANT.by_value], :long],
			toStaticHTML: [[:pointer, :pointer], :long],
			put_onmessage: [[VARIANT.by_value], :long],
			get_onmessage: [[:pointer], :long],
			msWriteProfilerMark: [[:pointer], :long]
		]

		HTMLWindow6 = COM::Instance[IHTMLWindow6]

		class HTMLWindow6
			attr_reader :handlers

			def on(event, &block)
				((@handlers ||= {})[event] ||= []) << block
				@dcallbacks ||= []

				send("put_on#{event}", VARIANT.new.tap { |v|
					v[:vt] = VT_DISPATCH

					v[:pdispVal] = @dcallbacks.push(DCallback.new.tap { |dcb|
						dcb.instance_variable_set(:@window, self)
						dcb.instance_variable_set(:@event, event)

						def dcb.Invoke(*args)
							@window.handlers[@event].each { |handler|
								(handler.arity == 0) ? handler.call : handler.call(*args)
							}

							S_OK
						end
					}).last
				}) unless @handlers[event].length > 1

				self
			end
		end

		IHTMLXMLHttpRequestFactory = COM::Interface[IDispatch,
			GUID['3051040c-98b5-11cf-bb82-00aa00bdce0b'],

			create: [[:pointer], :long]
		]

		HTMLXMLHttpRequestFactory = COM::Instance[IHTMLXMLHttpRequestFactory]

		IHTMLXMLHttpRequest = COM::Interface[IDispatch,
			GUID['3051040a-98b5-11cf-bb82-00aa00bdce0b'],

			get_readyState: [[:pointer], :long],
			get_responseBody: [[:pointer], :long],
			get_responseText: [[:pointer], :long],
			get_responseXML: [[:pointer], :long],
			get_status: [[:pointer], :long],
			get_statusText: [[:pointer], :long],
			put_onreadystatechange: [[VARIANT.by_value], :long],
			get_onreadystatechange: [[:pointer], :long],
			abort: [[], :long],
			open: [[:pointer, :pointer, VARIANT.by_value, VARIANT.by_value, VARIANT.by_value], :long],
			send: [[VARIANT.by_value], :long],
			getAllResponseHeaders: [[:pointer], :long],
			getResponseHeader: [[:pointer, :pointer], :long],
			setRequestHeader: [[:pointer, :pointer], :long]
		]

		HTMLXMLHttpRequest = COM::Instance[IHTMLXMLHttpRequest]

		class HTMLXMLHttpRequest
			attr_reader :handlers

			def on(event, &block)
				((@handlers ||= {})[event] ||= []) << block
				@dcallbacks ||= []

				__send__("put_on#{event}", VARIANT.new.tap { |v|
					v[:vt] = VT_DISPATCH

					v[:pdispVal] = @dcallbacks.push(DCallback.new.tap { |dcb|
						dcb.instance_variable_set(:@request, self)
						dcb.instance_variable_set(:@event, event)

						def dcb.Invoke(*args)
							@request.handlers[@event].each { |handler|
								(handler.arity == 0) ? handler.call : handler.call(*args)
							}

							S_OK
						end
					}).last
				}) unless @handlers[event].length > 1

				self
			end

			%w{readyState status}.each { |name|
				define_method(name) {
					FFI::MemoryPointer.new(:pointer) { |plong|
						__send__("get_#{name}", plong)

						return plong.read_long
					}
				}
			}

			%w{statusText responseText}.each { |name|
				define_method(name) {
					ppbstr = FFI::MemoryPointer.new(:pointer)

					begin
						__send__("get_#{name}", ppbstr)

						return nil if (pbstr = ppbstr.read_pointer).null?

						begin
							Windows.WCSTOMBS(pbstr)
						ensure
							Windows.SysFreeString(pbstr)
						end
					ensure
						ppbstr.free
					end
				}
			}

			alias old_open open

			def open(url, method = 'get')
				old_open(
					bstr = Windows.SysAllocString("#{method}\0".encode('utf-16le')),
					bstr2 = Windows.SysAllocString("#{url}\0".encode('utf-16le')),
					VARIANT.new.tap { |v| v[:vt] = VT_BOOL; v[:boolVal] = -1 },
					VARIANT.new,
					VARIANT.new
				)

				self
			ensure
				Windows.SysFreeString(bstr)
				Windows.SysFreeString(bstr2)
			end
		end

		IHTMLXDomainRequestFactory = COM::Interface[IDispatch,
			GUID['30510456-98b5-11cf-bb82-00aa00bdce0b'],

			create: [[:pointer], :long]
		]

		HTMLXDomainRequestFactory = COM::Instance[IHTMLXDomainRequestFactory]

		IHTMLXDomainRequest = COM::Interface[IDispatch,
			GUID['30510454-98b5-11cf-bb82-00aa00bdce0b'],

			get_responseText: [[:pointer], :long],
			put_timeout: [[:long], :long],
			get_timeout: [[:pointer], :long],
			get_contentType: [[:pointer], :long],
			put_onprogress: [[VARIANT.by_value], :long],
			get_onprogress: [[:pointer], :long],
			put_onerror: [[VARIANT.by_value], :long],
			get_onerror: [[:pointer], :long],
			put_ontimeout: [[VARIANT.by_value], :long],
			get_ontimeout: [[:pointer], :long],
			put_onload: [[VARIANT.by_value], :long],
			get_onload: [[:pointer], :long],
			abort: [[], :long],
			open: [[:pointer, :pointer], :long],
			send: [[VARIANT.by_value], :long]
		]

		HTMLXDomainRequest = COM::Instance[IHTMLXDomainRequest]

		class HTMLXDomainRequest
			attr_reader :handlers

			def on(event, &block)
				((@handlers ||= {})[event] ||= []) << block
				@dcallbacks ||= []

				__send__("put_on#{event}", VARIANT.new.tap { |v|
					v[:vt] = VT_DISPATCH

					v[:pdispVal] = @dcallbacks.push(DCallback.new.tap { |dcb|
						dcb.instance_variable_set(:@xrequest, self)
						dcb.instance_variable_set(:@event, event)

						def dcb.Invoke(*args)
							@xrequest.handlers[@event].each { |handler|
								(handler.arity == 0) ? handler.call : handler.call(*args)
							}

							S_OK
						end
					}).last
				}) unless @handlers[event].length > 1

				self
			end

			%w{responseText}.each { |name|
				define_method(name) {
					ppbstr = FFI::MemoryPointer.new(:pointer)

					begin
						__send__("get_#{name}", ppbstr)

						return nil if (pbstr = ppbstr.read_pointer).null?

						begin
							Windows.WCSTOMBS(pbstr)
						ensure
							Windows.SysFreeString(pbstr)
						end
					ensure
						ppbstr.free
					end
				}
			}

			alias old_open open

			def open(url, method = 'get')
				old_open(
					bstr = Windows.SysAllocString("#{method}\0".encode('utf-16le')),
					bstr2 = Windows.SysAllocString("#{url}\0".encode('utf-16le'))
				)

				self
			ensure
				Windows.SysFreeString(bstr)
				Windows.SysFreeString(bstr2)
			end
		end

		IHTMLElement = COM::Interface[IDispatch,
			GUID['3050f1ff-98b5-11cf-bb82-00aa00bdce0b'],

			setAttribute: [[:pointer, VARIANT.by_value, :long], :long],
			getAttribute: [[:pointer, :long, :pointer], :long],
			removeAttribute: [[:pointer, :long, :pointer], :long],
			put_className: [[:pointer], :long],
			get_className: [[:pointer], :long],
			put_id: [[:pointer], :long],
			get_id: [[:pointer], :long],
			get_tagName: [[:pointer], :long],
			get_parentElement: [[:pointer], :long],
			get_style: [[:pointer], :long],
			put_onhelp: [[VARIANT.by_value], :long],
			get_onhelp: [[:pointer], :long],
			put_onclick: [[VARIANT.by_value], :long],
			get_onclick: [[:pointer], :long],
			put_ondblclick: [[VARIANT.by_value], :long],
			get_ondblclick: [[:pointer], :long],
			put_onkeydown: [[VARIANT.by_value], :long],
			get_onkeydown: [[:pointer], :long],
			put_onkeyup: [[VARIANT.by_value], :long],
			get_onkeyup: [[:pointer], :long],
			put_onkeypress: [[VARIANT.by_value], :long],
			get_onkeypress: [[:pointer], :long],
			put_onmouseout: [[VARIANT.by_value], :long],
			get_onmouseout: [[:pointer], :long],
			put_onmouseover: [[VARIANT.by_value], :long],
			get_onmouseover: [[:pointer], :long],
			put_onmousemove: [[VARIANT.by_value], :long],
			get_onmousemove: [[:pointer], :long],
			put_onmousedown: [[VARIANT.by_value], :long],
			get_onmousedown: [[:pointer], :long],
			put_onmouseup: [[VARIANT.by_value], :long],
			get_onmouseup: [[:pointer], :long],
			get_document: [[:pointer], :long],
			put_title: [[:pointer], :long],
			get_title: [[:pointer], :long],
			put_language: [[:pointer], :long],
			get_language: [[:pointer], :long],
			put_onselectstart: [[VARIANT.by_value], :long],
			get_onselectstart: [[:pointer], :long],
			scrollIntoView: [[VARIANT.by_value], :long],
			contains: [[:pointer, :pointer], :long],
			get_sourceIndex: [[:pointer], :long],
			get_recordNumber: [[:pointer], :long],
			put_lang: [[:pointer], :long],
			get_lang: [[:pointer], :long],
			get_offsetLeft: [[:pointer], :long],
			get_offsetTop: [[:pointer], :long],
			get_offsetWidth: [[:pointer], :long],
			get_offsetHeight: [[:pointer], :long],
			get_offsetParent: [[:pointer], :long],
			put_innerHTML: [[:pointer], :long],
			get_innerHTML: [[:pointer], :long],
			put_innerText: [[:pointer], :long],
			get_innerText: [[:pointer], :long],
			put_outerHTML: [[:pointer], :long],
			get_outerHTML: [[:pointer], :long],
			put_outerText: [[:pointer], :long],
			get_outerText: [[:pointer], :long],
			insertAdjacentHTML: [[:pointer, :pointer], :long],
			insertAdjacentText: [[:pointer, :pointer], :long],
			get_parentTextEdit: [[:pointer], :long],
			get_isTextEdit: [[:pointer], :long],
			click: [[], :long],
			get_filters: [[:pointer], :long],
			put_ondragstart: [[VARIANT.by_value], :long],
			get_ondragstart: [[:pointer], :long],
			put_onbeforeupdate: [[VARIANT.by_value], :long],
			get_onbeforeupdate: [[:pointer], :long],
			put_onafterupdate: [[VARIANT.by_value], :long],
			get_onafterupdate: [[:pointer], :long],
			put_onerrorupdate: [[VARIANT.by_value], :long],
			get_onerrorupdate: [[:pointer], :long],
			put_onrowexit: [[VARIANT.by_value], :long],
			get_onrowexit: [[:pointer], :long],
			put_onrowenter: [[VARIANT.by_value], :long],
			get_onrowenter: [[:pointer], :long],
			put_ondatasetchanged: [[VARIANT.by_value], :long],
			get_ondatasetchanged: [[:pointer], :long],
			put_ondataavailable: [[VARIANT.by_value], :long],
			get_ondataavailable: [[:pointer], :long],
			put_ondatasetcomplete: [[VARIANT.by_value], :long],
			get_ondatasetcomplete: [[:pointer], :long],
			put_onfilterchange: [[VARIANT.by_value], :long],
			get_onfilterchange: [[:pointer], :long],
			get_children: [[:pointer], :long],
			get_all: [[:pointer], :long]
		]

		HTMLElement = COM::Instance[IHTMLElement]

		class HTMLElement
			attr_reader :handlers

			def on(event, &block)
				((@handlers ||= {})[event] ||= []) << block
				@dcallbacks ||= []

				send("put_on#{event}", VARIANT.new.tap { |v|
					v[:vt] = VT_DISPATCH

					v[:pdispVal] = @dcallbacks.push(DCallback.new.tap { |dcb|
						dcb.instance_variable_set(:@element, self)
						dcb.instance_variable_set(:@event, event)

						def dcb.Invoke(*args)
							@element.handlers[@event].each { |handler|
								(handler.arity == 0) ? handler.call : handler.call(*args)
							}

							S_OK
						end
					}).last
				}) unless @handlers[event].length > 1

				self
			end

			%w{offsetLeft offsetTop offsetWidth offsetHeight}.each { |name|
				define_method(name) {
					FFI::MemoryPointer.new(:pointer) { |plong|
						send("get_#{name}", plong)

						return plong.read_long
					}
				}
			}

			%w{className id tagName title language lang innerHTML innerText outerHTML outerText}.each { |name|
				define_method(name) {
					ppbstr = FFI::MemoryPointer.new(:pointer)

					begin
						send("get_#{name}", ppbstr)

						return nil if (pbstr = ppbstr.read_pointer).null?

						begin
							Windows.WCSTOMBS(pbstr)
						ensure
							Windows.SysFreeString(pbstr)
						end
					ensure
						ppbstr.free
					end
				}

				next if name == 'tagName'

				define_method("#{name}=") { |v|
					bstr = Windows.SysAllocString("#{v}\0".encode('utf-16le'))

					begin
						send("put_#{name}", bstr)
					ensure
						Windows.SysFreeString(bstr)
					end
				}
			}

			def attr(*args)
				case args.length
				when 1
					getAttribute(bstr = Windows.SysAllocString("#{args[0]}\0".encode('utf-16le')), 0, v = VARIANT.new)

					case v[:vt]
					when VT_BSTR; (v[:bstrVal].null?) ? nil : Windows.WCSTOMBS(v[:bstrVal])
					when VT_I4; v[:lVal]
					when VT_BOOL; v[:boolVal] == -1
					else raise
					end
				when 2
					v = VARIANT.new

					case args[1]
					when String; v[:vt] = VT_BSTR; v[:bstrVal] = bstrv = Windows.SysAllocString("#{args[0]}\0".encode('utf-16le'))
					when Integer; v[:vt] = VT_I4; v[:lVal] = args[1]
					when TrueClass; v[:vt] = VT_BOOL; v[:boolVal] = -1
					when FalseClass, NilClass; v[:vt] = VT_BOOL; v[:boolVal] = 0
					else raise ArgumentError
					end

					setAttribute(bstr = Windows.SysAllocString("#{args[0]}\0".encode('utf-16le')), v, 0)

					self
				else raise ArgumentError
				end
			ensure
				Windows.SysFreeString(bstr) if bstr
				Windows.SysFreeString(bstrv) if bstrv
			end

			def node; QueryInstance(HTMLDOMNode) end

			def style
				FFI::MemoryPointer.new(:pointer) { |pstyle|
					get_style(pstyle)

					return HTMLStyle.new(pstyle.read_pointer)
				}
			end

			def css(hash) s = style; hash.each { |k, v| s.send("#{k}=", v) }; self end
		end

		IHTMLDOMNode = COM::Interface[IDispatch,
			GUID['3050f5da-98b5-11cf-bb82-00aa00bdce0b'],

			get_nodeType: [[:pointer], :long],
			get_parentNode: [[:pointer], :long],
			hasChildNodes: [[:pointer], :long],
			get_childNodes: [[:pointer], :long],
			get_attributes: [[:pointer], :long],
			insertBefore: [[:pointer, VARIANT.by_value, :pointer], :long],
			removeChild: [[:pointer, :pointer], :long],
			replaceChild: [[:pointer, :pointer, :pointer], :long],
			cloneNode: [[:short, :pointer], :long],
			removeNode: [[:short, :pointer], :long],
			swapNode: [[:pointer, :pointer], :long],
			replaceNode: [[:pointer, :pointer], :long],
			appendChild: [[:pointer, :pointer], :long],
			get_nodeName: [[:pointer], :long],
			put_nodeValue: [[VARIANT.by_value], :long],
			get_nodeValue: [[:pointer], :long],
			get_firstChild: [[:pointer], :long],
			get_lastChild: [[:pointer], :long],
			get_previousSibling: [[:pointer], :long],
			get_nextSibling: [[:pointer], :long]
		]

		HTMLDOMNode = COM::Instance[IHTMLDOMNode]

		class HTMLDOMNode
			alias old_appendChild appendChild

			def appendChild(node)
				FFI::MemoryPointer.new(:pointer) { |pnode|
					old_appendChild(node, pnode)

					return HTMLDOMNode.new(pnode)
				}
			end
		end

		IHTMLElementCollection = COM::Interface[IDispatch,
			GUID['3050f21f-98b5-11cf-bb82-00aa00bdce0b'],

			toString: [[:pointer], :long],
			put_length: [[:long], :long],
			get_length: [[:pointer], :long],
			get__newEnum: [[:pointer], :long],
			item: [[VARIANT.by_value, VARIANT.by_value, :pointer], :long],
			tags: [[VARIANT.by_value, :pointer], :long]
		]

		HTMLElementCollection = COM::Instance[IHTMLElementCollection]

		class HTMLElementCollection
			def get(selector)
				v = VARIANT.new

				case selector
				when String
					v[:vt] = VT_BSTR
					v[:bstrVal] = bstr = if selector[0] == '#'
						Windows.SysAllocString("#{selector[1..-1]}\0".encode('utf-16le'))
					else
						_tags = true
						Windows.SysAllocString("#{selector}\0".encode('utf-16le'))
					end
				when Integer
					v[:vt] = VT_I4; v[:intVal] = selector
				else raise ArgumentError
				end

				pdisp = nil

				FFI::MemoryPointer.new(:pointer) { |pdisp|
					(_tags) ? tags(v, pdisp) : item(v, VARIANT.new, pdisp)

					return nil if (pdisp = pdisp.read_pointer).null?

					disp = Dispatch.new(pdisp)

					return disp.QueryInstance((_tags) ? HTMLElementCollection : HTMLElement)
				}
			ensure
				Windows.SysFreeString(bstr) if bstr
				pdisp.Release if pdisp && !pdisp.null?
			end
		end

		IHTMLStyle = COM::Interface[IDispatch,
			GUID['3050f25e-98b5-11cf-bb82-00aa00bdce0b'],

			put_fontFamily: [[:pointer], :long],
			get_fontFamily: [[:pointer], :long],
			put_fontStyle: [[:pointer], :long],
			get_fontStyle: [[:pointer], :long],
			put_fontVariant: [[:pointer], :long],
			get_fontVariant: [[:pointer], :long],
			put_fontWeight: [[:pointer], :long],
			get_fontWeight: [[:pointer], :long],
			put_fontSize: [[:pointer], :long],
			get_fontSize: [[:pointer], :long],
			put_font: [[:pointer], :long],
			get_font: [[:pointer], :long],
			put_color: [[VARIANT.by_value], :long],
			get_color: [[:pointer], :long],
			put_background: [[:pointer], :long],
			get_background: [[:pointer], :long],
			put_backgroundColor: [[VARIANT.by_value], :long],
			get_backgroundColor: [[:pointer], :long],
			put_backgroundImage: [[:pointer], :long],
			get_backgroundImage: [[:pointer], :long],
			put_backgroundRepeat: [[:pointer], :long],
			get_backgroundRepeat: [[:pointer], :long],
			put_backgroundAttachment: [[:pointer], :long],
			get_backgroundAttachment: [[:pointer], :long],
			put_backgroundPosition: [[:pointer], :long],
			get_backgroundPosition: [[:pointer], :long],
			put_backgroundPositionX: [[VARIANT.by_value], :long],
			get_backgroundPositionX: [[:pointer], :long],
			put_backgroundPositionY: [[VARIANT.by_value], :long],
			get_backgroundPositionY: [[:pointer], :long],
			put_wordSpacing: [[VARIANT.by_value], :long],
			get_wordSpacing: [[:pointer], :long],
			put_letterSpacing: [[VARIANT.by_value], :long],
			get_letterSpacing: [[:pointer], :long],
			put_textDecoration: [[:pointer], :long],
			get_textDecoration: [[:pointer], :long],
			put_textDecorationNone: [[:short], :long],
			get_textDecorationNone: [[:pointer], :long],
			put_textDecorationUnderline: [[:short], :long],
			get_textDecorationUnderline: [[:pointer], :long],
			put_textDecorationOverline: [[:short], :long],
			get_textDecorationOverline: [[:pointer], :long],
			put_textDecorationLineThrough: [[:short], :long],
			get_textDecorationLineThrough: [[:pointer], :long],
			put_textDecorationBlink: [[:short], :long],
			get_textDecorationBlink: [[:pointer], :long],
			put_verticalAlign: [[VARIANT.by_value], :long],
			get_verticalAlign: [[:pointer], :long],
			put_textTransform: [[:pointer], :long],
			get_textTransform: [[:pointer], :long],
			put_textAlign: [[:pointer], :long],
			get_textAlign: [[:pointer], :long],
			put_textIndent: [[VARIANT.by_value], :long],
			get_textIndent: [[:pointer], :long],
			put_lineHeight: [[VARIANT.by_value], :long],
			get_lineHeight: [[:pointer], :long],
			put_marginTop: [[VARIANT.by_value], :long],
			get_marginTop: [[:pointer], :long],
			put_marginRight: [[VARIANT.by_value], :long],
			get_marginRight: [[:pointer], :long],
			put_marginBottom: [[VARIANT.by_value], :long],
			get_marginBottom: [[:pointer], :long],
			put_marginLeft: [[VARIANT.by_value], :long],
			get_marginLeft: [[:pointer], :long],
			put_margin: [[:pointer], :long],
			get_margin: [[:pointer], :long],
			put_paddingTop: [[VARIANT.by_value], :long],
			get_paddingTop: [[:pointer], :long],
			put_paddingRight: [[VARIANT.by_value], :long],
			get_paddingRight: [[:pointer], :long],
			put_paddingBottom: [[VARIANT.by_value], :long],
			get_paddingBottom: [[:pointer], :long],
			put_paddingLeft: [[VARIANT.by_value], :long],
			get_paddingLeft: [[:pointer], :long],
			put_padding: [[:pointer], :long],
			get_padding: [[:pointer], :long],
			put_border: [[:pointer], :long],
			get_border: [[:pointer], :long],
			put_borderTop: [[:pointer], :long],
			get_borderTop: [[:pointer], :long],
			put_borderRight: [[:pointer], :long],
			get_borderRight: [[:pointer], :long],
			put_borderBottom: [[:pointer], :long],
			get_borderBottom: [[:pointer], :long],
			put_borderLeft: [[:pointer], :long],
			get_borderLeft: [[:pointer], :long],
			put_borderColor: [[:pointer], :long],
			get_borderColor: [[:pointer], :long],
			put_borderTopColor: [[VARIANT.by_value], :long],
			get_borderTopColor: [[:pointer], :long],
			put_borderRightColor: [[VARIANT.by_value], :long],
			get_borderRightColor: [[:pointer], :long],
			put_borderBottomColor: [[VARIANT.by_value], :long],
			get_borderBottomColor: [[:pointer], :long],
			put_borderLeftColor: [[VARIANT.by_value], :long],
			get_borderLeftColor: [[:pointer], :long],
			put_borderWidth: [[:pointer], :long],
			get_borderWidth: [[:pointer], :long],
			put_borderTopWidth: [[VARIANT.by_value], :long],
			get_borderTopWidth: [[:pointer], :long],
			put_borderRightWidth: [[VARIANT.by_value], :long],
			get_borderRightWidth: [[:pointer], :long],
			put_borderBottomWidth: [[VARIANT.by_value], :long],
			get_borderBottomWidth: [[:pointer], :long],
			put_borderLeftWidth: [[VARIANT.by_value], :long],
			get_borderLeftWidth: [[:pointer], :long],
			put_borderStyle: [[:pointer], :long],
			get_borderStyle: [[:pointer], :long],
			put_borderTopStyle: [[:pointer], :long],
			get_borderTopStyle: [[:pointer], :long],
			put_borderRightStyle: [[:pointer], :long],
			get_borderRightStyle: [[:pointer], :long],
			put_borderBottomStyle: [[:pointer], :long],
			get_borderBottomStyle: [[:pointer], :long],
			put_borderLeftStyle: [[:pointer], :long],
			get_borderLeftStyle: [[:pointer], :long],
			put_width: [[VARIANT.by_value], :long],
			get_width: [[:pointer], :long],
			put_height: [[VARIANT.by_value], :long],
			get_height: [[:pointer], :long],
			put_styleFloat: [[:pointer], :long],
			get_styleFloat: [[:pointer], :long],
			put_clear: [[:pointer], :long],
			get_clear: [[:pointer], :long],
			put_display: [[:pointer], :long],
			get_display: [[:pointer], :long],
			put_visibility: [[:pointer], :long],
			get_visibility: [[:pointer], :long],
			put_listStyleType: [[:pointer], :long],
			get_listStyleType: [[:pointer], :long],
			put_listStylePosition: [[:pointer], :long],
			get_listStylePosition: [[:pointer], :long],
			put_listStyleImage: [[:pointer], :long],
			get_listStyleImage: [[:pointer], :long],
			put_listStyle: [[:pointer], :long],
			get_listStyle: [[:pointer], :long],
			put_whiteSpace: [[:pointer], :long],
			get_whiteSpace: [[:pointer], :long],
			put_top: [[VARIANT.by_value], :long],
			get_top: [[:pointer], :long],
			put_left: [[VARIANT.by_value], :long],
			get_left: [[:pointer], :long],
			get_position: [[:pointer], :long],
			put_zIndex: [[VARIANT.by_value], :long],
			get_zIndex: [[:pointer], :long],
			put_overflow: [[:pointer], :long],
			get_overflow: [[:pointer], :long],
			put_pageBreakBefore: [[:pointer], :long],
			get_pageBreakBefore: [[:pointer], :long],
			put_pageBreakAfter: [[:pointer], :long],
			get_pageBreakAfter: [[:pointer], :long],
			put_cssText: [[:pointer], :long],
			get_cssText: [[:pointer], :long],
			put_pixelTop: [[:long], :long],
			get_pixelTop: [[:pointer], :long],
			put_pixelLeft: [[:long], :long],
			get_pixelLeft: [[:pointer], :long],
			put_pixelWidth: [[:long], :long],
			get_pixelWidth: [[:pointer], :long],
			put_pixelHeight: [[:long], :long],
			get_pixelHeight: [[:pointer], :long],
			put_posTop: [[:float], :long],
			get_posTop: [[:pointer], :long],
			put_posLeft: [[:float], :long],
			get_posLeft: [[:pointer], :long],
			put_posWidth: [[:float], :long],
			get_posWidth: [[:pointer], :long],
			put_posHeight: [[:float], :long],
			get_posHeight: [[:pointer], :long],
			put_cursor: [[:pointer], :long],
			get_cursor: [[:pointer], :long],
			put_clip: [[:pointer], :long],
			get_clip: [[:pointer], :long],
			put_filter: [[:pointer], :long],
			get_filter: [[:pointer], :long],
			setAttribute: [[:pointer, VARIANT.by_value, :long], :long],
			getAttribute: [[:pointer, :long, :pointer], :long],
			removeAttribute: [[:pointer, :long, :pointer], :long],
			toString: [[:pointer], :long]
		]

		HTMLStyle = COM::Instance[IHTMLStyle]

		class HTMLStyle
			%w{
				fontFamily fontStyle fontVariant fontWeight fontSize font
				background backgroundImage backgroundRepeat backgroundAttachment backgroundPosition
				textDecoration textTransform textAlign
				margin padding
				border borderTop borderRight borderBottom borderLeft borderColor borderWidth borderStyle borderTopStyle borderRightStyle borderBottomStyle borderLeftStyle
				styleFloat clear display visibility
				listStyleType listStylePosition listStyleImage listStyle
				whiteSpace position overflow pageBreakBefore pageBreakAfter cssText cursor clip filter
			}.each { |name|
				define_method(name) {
					ppbstr = FFI::MemoryPointer.new(:pointer)

					begin
						send("get_#{name}", ppbstr)

						return nil if (pbstr = ppbstr.read_pointer).null?

						begin
							Windows.WCSTOMBS(pbstr)
						ensure
							Windows.SysFreeString(pbstr)
						end
					ensure
						ppbstr.free
					end
				}

				define_method("#{name}=") { |v|
					bstr = Windows.SysAllocString("#{v}\0".encode('utf-16le'))

					begin
						send("put_#{name}", bstr)
					ensure
						Windows.SysFreeString(bstr)
					end
				}
			}
		end
	end
end
