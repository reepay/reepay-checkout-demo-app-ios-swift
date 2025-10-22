//
//  WKWebView+Boolean.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 22/10/2025.
//

import ObjectiveC
import WebKit

private var shouldNavigateKey: UInt8 = 0

extension WKWebView {
    public var shouldNavigate: Bool {
        get {
            return objc_getAssociatedObject(self, &shouldNavigateKey)
                as? Bool ?? true
        }
        set {
            objc_setAssociatedObject(
                self,
                &shouldNavigateKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
