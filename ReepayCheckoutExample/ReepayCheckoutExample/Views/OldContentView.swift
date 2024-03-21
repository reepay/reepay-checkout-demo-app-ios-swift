//
//  OldContentView.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 18/03/2024.
//

import Combine
import Foundation
import ReepayCheckoutSheet
import SwiftUI

struct OldContentView: View {
    @State var checkoutSheet: CheckoutSheet?

    @State var acceptEventCancellables = Set<AnyCancellable>()
    @State var cancelEventCancellables = Set<AnyCancellable>()
    @State var closeEventCancellables = Set<AnyCancellable>()

    @State private var showingAlert = false
    @State private var checkoutState: CheckoutState?

    @StateObject private var sessionModel = SessionModel()

    func prepareCheckoutSheet(id: String) {
        MyCheckoutConfiguration.shared.setConfiguration(id: sessionModel.id)
        MyCheckoutConfiguration.shared.setAcceptUrl(url: sessionModel.acceptURL)
        MyCheckoutConfiguration.shared.setCancelUrl(url: sessionModel.cancelURL)
        MyCheckoutConfiguration.shared.setCheckoutStyle()

        if let configuration = MyCheckoutConfiguration.shared.getConfiguration() {
            checkoutSheet = CheckoutSheet(configuration: configuration)
            setupSubscribers()
            print("Prepared checkout for: \(id)")
        } else {
            print("Error preparing checkout")
        }
    }

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: {
                    prepareCheckoutSheet(id: sessionModel.id)
                    self.checkoutSheet?.present()
                    setupSubscribers()
                }) {
                    Label("Pay", systemImage: "creditcard.fill")
                        .padding()
                        .foregroundColor(.green)
                        .background(.black)
                        .cornerRadius(10)
                }
            }
            Spacer()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Checkout state"),
                  message: Text("Event: \(self.checkoutState!.toString)"),
                  dismissButton: .default(Text("OK"), action: handleCheckoutStateClick))
        }
        .onAppear {
            prepareCheckoutSheet(id: sessionModel.id)
        }
    }

    func handleCheckoutStateClick() {
        showingAlert = false
    }

    private func setupSubscribers() {
        checkoutSheet?.getCheckoutEventPublisher().cancelEventPublisher
            .sink(receiveValue: { (event: CheckoutEvent) in
                print("Received event: \(event.state)")
                checkoutSheet?.dismiss()
            })
            .store(in: &acceptEventCancellables)

        checkoutSheet?.getCheckoutEventPublisher().acceptEventPublisher
            .sink(receiveValue: { (event: CheckoutEvent) in
                print("Received event: \(event.state)")
                checkoutSheet?.dismiss()
            })
            .store(in: &cancelEventCancellables)

        checkoutSheet?.getCheckoutEventPublisher().closeEventPublisher
            .sink(receiveValue: { (event: CheckoutEvent) in
                print("Received event: \(event.state)")
            })
            .store(in: &closeEventCancellables)
    }

    private func cancelSubscribers() {
        acceptEventCancellables.removeAll()
        cancelEventCancellables.removeAll()
        closeEventCancellables.removeAll()
    }
}
