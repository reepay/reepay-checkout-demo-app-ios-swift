//
//  AppDelegate.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 03/07/2024.
//

import Foundation
import ReepayCheckoutSheet
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    static var checkoutSheet: CheckoutSheet?

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        handleIncomingURL(url)
        return true
    }

    func handleIncomingURL(_ url: URL) {
        print("\n Incoming URL: \(url) \n")

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }

        if let queryItems = components.queryItems {
            for queryItem in queryItems {
                if let value = queryItem.value {
                    print("Query param - [\(queryItem.name): \(value)]")

                    if queryItem.name == "return_url" {
                        if let sheet = AppDelegate.checkoutSheet {
                            sheet.present(url: value)
                        } else {
                            if let configuration = MyCheckoutConfiguration.shared.getConfiguration() {
                                AppDelegate.checkoutSheet = CheckoutSheet(configuration: configuration)
                                AppDelegate.checkoutSheet?.present(url: value)
                            }
                        }
                    }
                }
            }
        }
    }
}
