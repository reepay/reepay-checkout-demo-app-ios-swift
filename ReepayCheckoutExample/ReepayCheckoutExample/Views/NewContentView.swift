//
//  ContentView.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 18/03/2024.
//

import Combine
import ReepayCheckoutSheet
import SwiftUI

@available(iOS 15, *)
struct NewContentView: View {
    @State var checkoutSheet: CheckoutSheet?

    @State var acceptEventCancellables = Set<AnyCancellable>()
    @State var cancelEventCancellables = Set<AnyCancellable>()
    @State var closeEventCancellables = Set<AnyCancellable>()

    @State private var showingAlert = false
    @State private var checkoutState: CheckoutState?

    @StateObject private var sessionModel = SessionModel()

    func prepareCheckoutSheet() {
        MyCheckoutConfiguration.shared.setConfiguration(id: sessionModel.id)
        MyCheckoutConfiguration.shared.setAcceptUrl(url: sessionModel.acceptURL)
        MyCheckoutConfiguration.shared.setCancelUrl(url: sessionModel.cancelURL)
        MyCheckoutConfiguration.shared.setCheckoutStyle()
        MyCheckoutConfiguration.shared.setAlertStyle()

        if let configuration = MyCheckoutConfiguration.shared.getConfiguration() {
            checkoutSheet = CheckoutSheet(configuration: configuration)
            setupSubscribers()
            print("Prepared checkout for: \(sessionModel.id)")
        } else {
            print("Error preparing checkout")
        }
    }

    var body: some View {
        VStack {
            Button(action: {
                prepareCheckoutSheet()
                self.checkoutSheet?.present()
            }) {
                Label("Betal", systemImage: "creditcard.fill")
                    .padding()
                    .foregroundColor(Color(hex: "0476ba"))
                    .background(.white)
                    .cornerRadius(10)
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Checkout state"),
                  message: Text("Event: \(self.checkoutState!.toString)"),
                  dismissButton: .default(Text("OK"), action: handleCheckoutStateClick))
        }.onAppear {
            prepareCheckoutSheet()
        }
    }

    func handleCheckoutStateClick() {
        showingAlert = false
    }
}

extension NewContentView {
    private func setupSubscribers() {
        checkoutSheet?.getCheckoutEventPublisher().cancelEventPublisher
            .sink(receiveValue: { (event: CheckoutEvent) in
                print("Received event: \(event.state)")
                checkoutSheet?.dismiss()
                self.showingAlert = true
                self.checkoutState = event.state
            })
            .store(in: &cancelEventCancellables)

        checkoutSheet?.getCheckoutEventPublisher().acceptEventPublisher
            .sink(receiveValue: { (event: CheckoutEvent) in
                print("Received event: \(event.state)")
                checkoutSheet?.dismiss()
                self.showingAlert = true
                self.checkoutState = event.state
            })
            .store(in: &acceptEventCancellables)

        checkoutSheet?.getCheckoutEventPublisher().closeEventPublisher
            .sink(receiveValue: { (event: CheckoutEvent) in
                print("Received event: \(event.state)")
                self.showingAlert = true
                self.checkoutState = event.state
            })
            .store(in: &closeEventCancellables)
    }

    private func removeSubscribers() {
        acceptEventCancellables.removeAll()
        cancelEventCancellables.removeAll()
        closeEventCancellables.removeAll()
    }
}
