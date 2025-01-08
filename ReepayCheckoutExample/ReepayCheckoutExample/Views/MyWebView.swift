//
//  MyWebView.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 07/01/2025.
//

import SwiftUI
@preconcurrency import WebKit

struct MyWebView: UIViewRepresentable {
    let url: URL

    // Coordinator to handle script messages and navigation
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler, WKScriptMessageHandlerWithReply {
        weak var webView: WKWebView?

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            print("WebView finished loading")
        }

        // Handle WKScriptMessageHandlerWithReply (iOS 17+)
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage, replyHandler: @escaping (Any?, String?) -> Void) {
            if let response = message.body as? [String: Any] {
                print("[iOS17+] Received response: \(response)")

                if let reply = getEventReply(response: response) {
                    replyHandler(reply, nil)
                } else {
                    publishEvent(response: response)
                }
            } else {
                fatalError("Error: Unsupported message type")
            }
        }

        // Handle WKScriptMessageHandler (iOS <17)
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if let response = message.body as? [String: Any] {
                print("[iOS<17] Received response: \(response)")

                if let reply = getEventReply(response: response) {
                    replyWithResolveMessage(message: reply)
                } else {
                    publishEvent(response: response)
                }
            } else {
                fatalError("Error: Unsupported message type")
            }
        }

        // Inject JavaScript as a response (iOS <17)
        func replyWithResolveMessage(message: String) {
            let responseScript = "window.webkit.messageHandlers.ReepayCheckout.resolveMessage(\(message))"
            webView?.evaluateJavaScript(responseScript, completionHandler: { _, error in
                if let error = error {
                    fatalError("Error injecting JavaScript: \(error.localizedDescription)")
                }
            })
        }

        func getEventReply(response: [String: Any]) -> String? {
            let eventName = response["event"] as? String
            var reply: [String: Any]

            switch eventName {
            case "Init":
                /// Let ReepayCheckout know a webview is being used and should send webview events to my app:
                reply = [
                    "isWebView": true,
                    "userAgent": "Unknown",
                ]
            case "card_input_change":
                /// Let ReepayCheckout know webview has changed/touched by user and stop sending further "card_input_change" events:
                reply = [
                    "isWebViewChanged": true,
                ]
            default:
                return nil
            }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: reply, options: [])
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("Replying to ReepayCheckout: \(jsonString)")
                    return jsonString
                }
            } catch {
                fatalError("Error: Could not serialize response object")
            }
            return nil
        }

        func publishEvent(response: [String: Any]) {
            let eventName = response["event"] as? String

            switch eventName {
            case "Open":
                print("ReepayCheckout opened")
            case "Error":
                print("ReepayCheckout error")
            case "Close":
                print("ReepayCheckout closed")
            case "Accept":
                print("Payment completed with: \(response)")
            case "Cancel":
                print("Payment cancelled with: \(response)")
            default:
                print("Unhandled event: \(String(describing: eventName))")
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        return coordinator
    }

    func makeUIView(context: Context) -> WKWebView {
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true

        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = prefs

        let webView = WKWebView(frame: .zero, configuration: configuration)
        context.coordinator.webView = webView

        let contentController = webView.configuration.userContentController

        if #available(iOS 17.0, *) {
            contentController.addScriptMessageHandler(context.coordinator, contentWorld: .page, name: Constants.ReepayCheckoutChannel)
        } else {
            contentController.add(context.coordinator, name: Constants.ReepayCheckoutChannel)
        }

        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: url))
    }
}
