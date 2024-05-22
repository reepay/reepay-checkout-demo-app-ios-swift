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

    @State var eventPublisher: PassthroughSubject<CheckoutEvent, Never>?
    @State var eventCancellables = Set<AnyCancellable>() /// All event types
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
        }.onDisappear {
            removeSubscribers()
        }
    }

    func handleCheckoutStateClick() {
        showingAlert = false
    }
}

extension NewContentView {
    private func setupSubscribers() {
        if eventPublisher == nil {
            guard let eventPublisher = checkoutSheet?.getCheckoutEventPublisher().eventPublisher else {
                fatalError("Could not get Checkout Event Publisher from SDK")
            }
            self.eventPublisher = eventPublisher
            self.eventPublisher?
                .sink(receiveValue: { (event: CheckoutEvent) in
                    handleEvent(event: event)
                })
                .store(in: &eventCancellables)
        }

        /// Store specific events:
        checkoutSheet?.getCheckoutEventPublisher().acceptEventPublisher
            .sink(receiveValue: { (_: CheckoutEvent) in })
            .store(in: &acceptEventCancellables)
        checkoutSheet?.getCheckoutEventPublisher().cancelEventPublisher
            .sink(receiveValue: { (_: CheckoutEvent) in })
            .store(in: &cancelEventCancellables)
        checkoutSheet?.getCheckoutEventPublisher().closeEventPublisher
            .sink(receiveValue: { (_: CheckoutEvent) in })
            .store(in: &closeEventCancellables)
    }

    private func removeSubscribers() {
        eventCancellables.removeAll()
        eventPublisher = nil
    }

    private func handleEvent(event: CheckoutEvent) {
        print("Handling event: \(event.state)")
        checkoutState = event.state

        switch event.state {
        case CheckoutState.`init`:
            showingAlert = false
            print("Checkout has initiated")
        case CheckoutState.accept:
            checkoutSheet?.dismiss()
            showingAlert = true
        case CheckoutState.cancel:
            checkoutSheet?.dismiss()
            showingAlert = true
        case CheckoutState.close:
            showingAlert = true
        case CheckoutState.error:
            showingAlert = true
        }
    }
}
