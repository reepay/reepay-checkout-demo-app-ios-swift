//
//  ReepayCheckoutExampleApp.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 18/03/2024.
//

import SwiftUI

@main
struct ReepayCheckoutExampleApp: App {
    var body: some Scene {
        WindowGroup {
            MyNavigationView()
        }
    }
}

struct MyNavigationView: View {
    var body: some View {
        NavigationView {
            SidebarView()
            ReepayContentView()
            if #available(iOS 16.4, *) {
                MerchantContentView()
            }
        }.preferredColorScheme(.light)
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
            CustomNewContentView()
        }
    }
}
