//
//  NoSdkContentView.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 07/01/2025.
//

import SwiftUI
import WebKit

struct NoSdkContentView: View {
    @State private var showWebView = false
    @StateObject private var sessionModel = SessionModel()

    var body: some View {
        VStack {
            Button(action: {
                showWebView.toggle()
            }) {
                Label("Open Checkout", systemImage: "creditcard.fill")
                    .padding()
                    .foregroundColor(.black)
                    .background(.white)
                    .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showWebView, onDismiss: didDismiss) {
            VStack {
                HStack {
                    Button(
                        action: {
                            showWebView.toggle()
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("Close")
                            }.foregroundColor(.black)
                        }
                    Spacer()
                }.padding()
                let url = "\(Constants.ReepayBaseURL)\(sessionModel.id)"
                MyWebView(url: URL(string: url)!).frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .foregroundColor(.black)
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
    }

    func didDismiss() {
        print("Sheet dismissed")
    }
}
