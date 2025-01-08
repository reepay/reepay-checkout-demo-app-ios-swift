//
//  ReepayCheckoutExampleApp.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 18/03/2024.
//

import SwiftUI

@main
struct ReepayCheckoutExampleApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MyNavigationView()
                .onOpenURL { url in
                    /// Listen to incoming URL from redirect back to app
                    appDelegate.handleIncomingURL(url)
                }
        }
    }
}

struct MyNavigationView: View {
    var body: some View {
        NavigationView {
            SidebarView()
            InitialView()
        }.preferredColorScheme(.light)
    }

    struct InitialView: View {
        var body: some View {
            ReepayContentView()
            if #available(iOS 16.4, *) {
                MerchantContentView()
            }
        }
    }
}

/// Content View using Reepay CheckoutSheet
struct ReepayContentView: View {
    var body: some View {
        ZStack {
            Color(hex: "0476ba")
            if #available(iOS 15, *) {
                NewContentView()
            } else {
                OldContentView()
            }
        }
    }
}

/// Content View using my own sheet
@available(iOS 16.4, *)
struct MerchantContentView: View {
    var body: some View {
        ZStack {
            Color(hex: "006CFF")
            CustomContentView()
        }
    }
}

struct WebViewContentView: View {
    var body: some View {
        ZStack {
            Color(hex: "01A387")
            NoSdkContentView()
        }
    }
}
