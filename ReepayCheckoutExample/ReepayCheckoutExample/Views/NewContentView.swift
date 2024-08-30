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
    @State var userEventPublisher: PassthroughSubject<UserEvent, Never>?
    @State var userEventCancellables = Set<AnyCancellable>()

    @State var checkoutEventPublisher: PassthroughSubject<CheckoutEvent, Never>?
    @State var checkoutEventCancellables = Set<AnyCancellable>() /// All checkout event types
    @State var acceptEventCancellables = Set<AnyCancellable>()
    @State var cancelEventCancellables = Set<AnyCancellable>()
    @State var closeEventCancellables = Set<AnyCancellable>()

    @State private var showingAlert = false
    @State private var checkoutState: CheckoutState?

    @State private var isListVisible = true
    @State private var selectedDismissButtonVerticalPosition: VerticalPosition = .above
    @State private var selectedDismissButtonHorizontalPosition: HorizontalPosition = .right
    @State private var selectedDismissButtonType: ButtonType = .iconText
    @State private var selectedDismissButtonIconHorizontalPosition: HorizontalPosition = .right
    @State private var selectedSheetMode: Mode = .largeSheet

    @StateObject private var sessionModel = SessionModel()

    func prepareCheckoutSheet(id: String) {
        MyCheckoutConfiguration.shared.setConfiguration(id: id)
        MyCheckoutConfiguration.shared.setCheckoutStyle(mode: selectedSheetMode)
        MyCheckoutConfiguration.shared.setAlertStyle()
        MyCheckoutConfiguration.shared.setIconTextButtonStyle(type: selectedDismissButtonType, buttonHorizontalPosition: selectedDismissButtonHorizontalPosition, buttonVerticalPosition: selectedDismissButtonVerticalPosition, iconHorizontalPosition: selectedDismissButtonIconHorizontalPosition)

        if let configuration = MyCheckoutConfiguration.shared.getConfiguration() {
            AppDelegate.checkoutSheet = CheckoutSheet(configuration: configuration)
            setupSubscribers()
            print("Prepared checkout for: \(id)")
        } else {
            print("Error preparing checkout")
        }
    }

    var configuration: some View {
        List {
            Section {
                VStack {
                    Text("Dismiss Button Type")
                    Picker("", selection: $selectedDismissButtonType) {
                        Text("Icon").tag(ButtonType.icon)
                        Text("IconText").tag(ButtonType.iconText)
                        Text("Text").tag(ButtonType.text)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                VStack {
                    Text("Dismiss Button Vertical Position")
                    Picker("", selection: $selectedDismissButtonVerticalPosition) {
                        Text("Above").tag(VerticalPosition.above)
                        Text("Overlap").tag(VerticalPosition.overlap)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                VStack {
                    Text("Dismiss Button Horizontal Position")
                    Picker("", selection: $selectedDismissButtonHorizontalPosition) {
                        Text("Left").tag(HorizontalPosition.left)
                        Text("Center").tag(HorizontalPosition.center)
                        Text("Right").tag(HorizontalPosition.right)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                VStack {
                    Text("Dismiss Button Icon Position")
                    Picker("", selection: $selectedDismissButtonIconHorizontalPosition) {
                        Text("Left").tag(HorizontalPosition.left)
                        Text("Center").tag(HorizontalPosition.center)
                        Text("Right").tag(HorizontalPosition.right)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                VStack {
                    Text("Sheet Mode")
                    Picker("", selection: $selectedSheetMode) {
                        Text("Medium").tag(Mode.mediumSheet)
                        Text("M & L").tag(Mode.mediumAndLargeSheet)
                        Text("Large").tag(Mode.largeSheet)
                        Text("Fullscreen").tag(Mode.fullScreenCover)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
        .listStyle(.plain)
        .padding(EdgeInsets(top: 50, leading: 25, bottom: 0, trailing: 25))
        .transition(.opacity)
    }

    var body: some View {
        VStack {
            if isListVisible {
                configuration
            }
            Button(action: {
                prepareCheckoutSheet(id: sessionModel.id)
                AppDelegate.checkoutSheet?.present()

                withAnimation {
                    isListVisible.toggle()
                }
            }) {
                Label("Open Checkout", systemImage: "creditcard.fill")
                    .padding()
                    .foregroundColor(Color(hex: "0476ba"))
                    .background(.white)
                    .cornerRadius(10)
            }
            .padding(EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 0))
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Checkout state"),
                  message: Text("Event: \(self.checkoutState!.toString)"),
                  dismissButton: .default(Text("OK"), action: handleCheckoutStateClick))
        }
    }

    func handleCheckoutStateClick() {
        showingAlert = false
    }
}

extension NewContentView {
    private func setupSubscribers() {
        if checkoutEventPublisher == nil {
            guard let checkoutEventPublisher = AppDelegate.checkoutSheet?.getCheckoutEventPublisher().eventPublisher else {
                fatalError("Could not get Checkout Event Publisher from SDK")
            }
            self.checkoutEventPublisher = checkoutEventPublisher
            self.checkoutEventPublisher?
                .sink(receiveValue: { (event: CheckoutEvent) in
                    self.handleEvent(event: event)
                })
                .store(in: &checkoutEventCancellables)
        }

        /// Subscribe specific checkut events:
        AppDelegate.checkoutSheet?.getCheckoutEventPublisher().acceptEventPublisher
            .sink(receiveValue: { (_: CheckoutEvent) in })
            .store(in: &acceptEventCancellables)
        AppDelegate.checkoutSheet?.getCheckoutEventPublisher().cancelEventPublisher
            .sink(receiveValue: { (_: CheckoutEvent) in })
            .store(in: &cancelEventCancellables)
        AppDelegate.checkoutSheet?.getCheckoutEventPublisher().closeEventPublisher
            .sink(receiveValue: { (_: CheckoutEvent) in })
            .store(in: &closeEventCancellables)

        /// Subscribe user events
        if userEventPublisher == nil {
            guard let userEventPublisher = AppDelegate.checkoutSheet?.getUserEventPublisher().eventPublisher else {
                fatalError("Could not get User Event Publisher from SDK")
            }
            self.userEventPublisher = userEventPublisher
            self.userEventPublisher?
                .sink(receiveValue: { (event: UserEvent) in
                    self.handleUserEvent(event: event)
                })
                .store(in: &userEventCancellables)
        }
    }

    private func removeSubscribers() {
        acceptEventCancellables.removeAll()
        cancelEventCancellables.removeAll()
        closeEventCancellables.removeAll()
        checkoutEventCancellables.removeAll()
        checkoutEventPublisher = nil

        userEventCancellables.removeAll()
        userEventPublisher = nil
    }

    private func handleEvent(event: CheckoutEvent) {
        print("Handling event: \(event.state)")
        checkoutState = event.state

        switch event.state {
        case CheckoutState.`init`:
            showingAlert = false
            print("Checkout has initiated")
        case CheckoutState.accept:
            AppDelegate.checkoutSheet?.dismiss(animated: true, completion: {
                if let data = event.message.data, let invoice = data.invoice {
                    print("Invoice with handle '\(invoice)' has been paid")
                }
                showingAlert = true
            })
        case CheckoutState.cancel:
            AppDelegate.checkoutSheet?.dismiss(animated: true, completion: {
                if let data = event.message.data, let sessionId = data.id {
                    print("Session id '\(sessionId)' has been cancelled by user")
                }
                showingAlert = true
            })
        case CheckoutState.close:
            showingAlert = false
        case CheckoutState.error:
            if let data = event.message.data, let error = data.error {
                print("Session has error: \(error)")
            }
            showingAlert = false
        }

        /// Remove the references when events are final states
        if ![CheckoutState.`init`, CheckoutState.error].contains(event.state) {
            removeSubscribers()
            AppDelegate.checkoutSheet = nil
            print("🏁 - Final state: CheckoutState.\(event.state)")

            withAnimation {
                isListVisible.toggle()
            }
        }
    }

    private func handleUserEvent(event: UserEvent) {
        print("Handling action: \(event.action)")

        switch event.action {
        case .cardInputChange:
            print("Checkout card fields has been edited")
        }
    }
}
