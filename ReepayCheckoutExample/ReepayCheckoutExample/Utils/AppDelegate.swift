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

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        return true
    }

    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        handleIncomingURL(url)
        return true
    }

    func handleIncomingURL(_ url: URL) {
        print("\n Incoming URL: \(url) \n")
        let queryParams = extractQueryParameters(from: url)
        if let encodedReturnUrl = queryParams["returnUrl"] {
            guard let returnUrl = encodedReturnUrl.removingPercentEncoding else {
                fatalError("Failed to decode returnUrl: \(encodedReturnUrl)")
            }
            print("\n returnUrl: \(returnUrl) \n")
            presentCheckoutReturnUrl(returnUrl: returnUrl)
        }
    }

    private func presentCheckoutReturnUrl(returnUrl: String) {
        if let sheet = AppDelegate.checkoutSheet {
            /// CheckoutSheet is still open, load return URL
            sheet.present(url: returnUrl)
        } else {
            if let configuration = MyCheckoutConfiguration.shared.getConfiguration() {
                /// CheckoutSheet has been closed, reuse existing configuration
                AppDelegate.checkoutSheet = CheckoutSheet(configuration: configuration)
                AppDelegate.checkoutSheet?.present(url: returnUrl)
            } else {
                /// App has been closed, use default configuration
                if let defaultConfiguration = MyCheckoutConfiguration.shared.getDefaultConfiguration() {
                    AppDelegate.checkoutSheet = CheckoutSheet(configuration: defaultConfiguration)
                    if let sheet = AppDelegate.checkoutSheet {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            sheet.present(url: returnUrl)
                        }
                    }
                }
            }
        }
    }

    private func extractQueryParameters(from url: URL) -> [String: String] {
        var queryParams: [String: String] = [:]
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems
        {
            for queryItem in queryItems {
                if let value = queryItem.value {
                    print("Query param - [\(queryItem.name): \(value)]")
                    queryParams[queryItem.name] = value
                }
            }
        }
        return queryParams
    }
}
