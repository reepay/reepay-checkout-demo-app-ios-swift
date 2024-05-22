//
//  MyCheckoutConfiguration.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 19/03/2024.
//

import ReepayCheckoutSheet

class MyCheckoutConfiguration {
    static let shared = MyCheckoutConfiguration()
    private var configuration: CheckoutConfiguration?

    func getConfiguration() -> CheckoutConfiguration? {
        return configuration
    }

    func setConfiguration(id: String) {
        guard let configuration = CheckoutConfiguration(
            sessionID: id
        ) else {
            fatalError("Invalid session ID")
        }
        self.configuration = configuration
    }

    func setAcceptUrl(url: String) {
        if var configuration = configuration, !url.isEmpty {
            configuration.acceptURL = url
            self.configuration = configuration
        }
    }

    func setCancelUrl(url: String) {
        if var configuration = configuration, !url.isEmpty {
            configuration.cancelURL = url
            self.configuration = configuration
        }
    }

    func setCheckoutStyle() {
        var checkoutStyle = CheckoutStyle()
        checkoutStyle.mode = .customSheet
        checkoutStyle.sheetHeightFraction = 0.7
        checkoutStyle.dismissable = false
        checkoutStyle.hasDismissButton = true
        checkoutStyle.dismissButtonColor = "#DC5151"

        if var configuration = configuration {
            configuration.checkoutStyle = checkoutStyle
            self.configuration = configuration
        }
    }

    func setOldCheckoutStyle() {
        var checkoutStyle = CheckoutStyle()
        checkoutStyle.mode = .mediumAndLargeSheet
        checkoutStyle.dismissable = true
        checkoutStyle.hasDismissButton = true
        checkoutStyle.dismissButtonColor = "#2A3439"

        if var configuration = configuration {
            configuration.checkoutStyle = checkoutStyle
            self.configuration = configuration
        }
    }

    func setAlertStyle() {
        var alertStyle = AlertStyle()
        alertStyle.title = "Close"
        alertStyle.message = "Are you sure?"
        alertStyle.preferredStyle = .alert
        alertStyle.dismissConfirmText = "Yes!"
        alertStyle.dismissCancelText = "Not really"

        if var configuration = configuration {
            configuration.checkoutStyle.dismissAlertStyle = alertStyle
            self.configuration = configuration
        }
    }
}
