//
//  CustomNewContentView.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 21/03/2024.
//

import Combine
import ReepayCheckoutSheet
import SwiftUI

@available(iOS 16.4, *)
struct CustomContentView: View {
    @State private var isShowingSheet = false
    @State private var isShowingFullscreen = false
    
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
        MyCheckoutConfiguration.shared.setCheckoutStyle(mode: nil)
        MyCheckoutConfiguration.shared.setAlertStyle()
        
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
                if self.checkoutSheet != nil {
                    sheetButton
                }
                if self.checkoutSheet != nil {
                    fullscreenButton
                }
            }
            Spacer()
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Checkout state"),
                  message: Text("Event: \(self.checkoutState?.toString ?? "No CheckoutState")"),
                  dismissButton: .default(Text("OK"), action: handleCheckoutStateClick))
        }.onAppear {
            prepareCheckoutSheet(id: sessionModel.id)
        }
    }
    
    func handleCheckoutStateClick() {
        showingAlert = false
    }
    
    var sheetButton: some View {
        Button(action: {
            prepareCheckoutSheet(id: sessionModel.id)
            isShowingSheet.toggle()
        }) {
            Label("Sheet Pay", systemImage: "creditcard")
                .padding()
                .foregroundColor(Color(hex: "006CFF"))
                .background(.white)
                .cornerRadius(10)
        }
        .sheet(isPresented: $isShowingSheet,
               onDismiss: didDismiss)
        {
            VStack {
                HStack {
                    Button(
                        action: {
                            checkoutState = CheckoutState.close
                            isShowingSheet.toggle()
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("Cancel")
                            }
                        }
                    Spacer()
                }.padding()
                if let checkoutVC = self.checkoutSheet?.getCheckoutViewController() {
                    UIViewControllerWrapper(viewController: checkoutVC)
                }
            }.presentationDetents([.fraction(0.8)])
        }
        .foregroundColor(.black)
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
        .presentationDetents([.medium])
        .presentationBackgroundInteraction(.automatic)
        .presentationBackground(.yellow)
        .interactiveDismissDisabled(true)
    }
    
    var fullscreenButton: some View {
        Button(action: {
            prepareCheckoutSheet(id: sessionModel.id)
            isShowingFullscreen.toggle()
        }) {
            Label("Fullscreen Pay", systemImage: "creditcard.fill")
                .padding()
                .foregroundColor(Color(hex: "006CFF"))
                .background(.white)
                .cornerRadius(10)
        }
        .fullScreenCover(isPresented: $isShowingFullscreen,
                         onDismiss: didDismiss)
        {
            Button("My dismiss button",
                   action: {
                       checkoutState = CheckoutState.close
                       isShowingFullscreen.toggle()
                   })
            if let checkoutVC = self.checkoutSheet?.getCheckoutViewController() {
                UIViewControllerWrapper(viewController: checkoutVC)
            }
        }
        .foregroundColor(.black)
        .frame(maxWidth: .infinity,
               maxHeight: .infinity)
        .ignoresSafeArea(edges: .all)
    }
    
    func didDismiss() {
        showingAlert = true
        removeSubscribers()
    }
}

@available(iOS 16.4, *)
extension CustomContentView {
    private func setupSubscribers() {
        checkoutSheet?.getCheckoutEventPublisher().cancelEventPublisher
            .sink(receiveValue: { (event: CheckoutEvent) in
                print("Received event: \(event.state)")
                checkoutSheet?.dismiss()
                self.checkoutState = event.state
                self.showingAlert = true
            })
            .store(in: &cancelEventCancellables)
        
        checkoutSheet?.getCheckoutEventPublisher().acceptEventPublisher
            .sink(receiveValue: { (event: CheckoutEvent) in
                print("Received event: \(event.state)")
                checkoutSheet?.dismiss()
                self.checkoutState = event.state
                self.showingAlert = true
            })
            .store(in: &acceptEventCancellables)
        
        checkoutSheet?.getCheckoutEventPublisher().closeEventPublisher
            .sink(receiveValue: { (event: CheckoutEvent) in
                print("Received event: \(event.state)")
                self.checkoutState = event.state
                self.showingAlert = true
            })
            .store(in: &closeEventCancellables)
    }
    
    private func removeSubscribers() {
        acceptEventCancellables.removeAll()
        cancelEventCancellables.removeAll()
        closeEventCancellables.removeAll()
    }
}
