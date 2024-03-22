//
//  SidebarView.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 18/03/2024.
//

import SwiftUI

struct SidebarView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image("billwerkplus-logo-black")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 20)
        }
        .padding(.vertical)
        .listRowInsets(EdgeInsets())
        List {
            NavigationLink(destination: ReepayContentView()) {
                Label("SDK Checkout", systemImage: "cart.fill")
            }
            if #available(iOS 16.4, *) {
                NavigationLink(destination: MerchantContentView()) {
                    Label("Custom Checkout", systemImage: "cart")
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationBarTitle("Menu", displayMode: .inline)
        .navigationBarHidden(true)
    }
}
