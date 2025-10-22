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
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        if UIApplication.shared.canOpenURL(url), url.scheme != "http",
            url.scheme != "https"
        {
            UIApplication.shared.open(url)
        }

        if !shouldNavigate {
            decisionHandler(.cancel)
            return
        }

        decisionHandler(.allow)
    }
}
