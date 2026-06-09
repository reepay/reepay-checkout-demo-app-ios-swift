//
//  WKWebView+Boolean.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 22/10/2025.
//

import ObjectiveC
import WebKit

private var shouldHandleNavigationKey: UInt8 = 0

extension WKWebView {
    public var shouldHandleNavigation: Bool {
        get {
            return (objc_getAssociatedObject(self, &shouldHandleNavigationKey)
                as? NSNumber)?.boolValue ?? true
        }
        set {
            objc_setAssociatedObject(
                self,
                &shouldHandleNavigationKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}
