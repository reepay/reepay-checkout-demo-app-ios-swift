//
//  MyWebView+Coordinator.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 22/10/2025.
//

import WebKit

extension MyWebView.Coordinator {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        // This is our own load if its URL matches. Clear it once matched so it can't
        // wrongly match a later page redirect.
        let isSDKInitiatedLoad = pendingProgrammaticURL != nil
            && navigationAction.request.url == pendingProgrammaticURL
        if isSDKInitiatedLoad {
            pendingProgrammaticURL = nil
        }

        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if UIApplication.shared.canOpenURL(url), url.scheme != "http",
            url.scheme != "https"
        {
            UIApplication.shared.open(url)
        }

        // When navigation handling is off, block page redirects but always allow our
        // own load and any redirect hops it triggers.
        let belongsToSDKNavigation = isSDKInitiatedLoad || sdkInitiatedNavigation != nil
        if !webView.shouldHandleNavigation, !belongsToSDKNavigation {
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
}
