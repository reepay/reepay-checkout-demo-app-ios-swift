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
            sessionId: id
        ) else {
            fatalError("Invalid session ID")
        }
        self.configuration = configuration
    }

    func setCheckoutStyle(mode: Mode?) {
        var checkoutStyle = CheckoutStyle()
        checkoutStyle.mode = mode ?? .customSheet
        checkoutStyle.sheetHeightFraction = 0.7
        checkoutStyle.sheetDismissable = .withAlertOnChanges
        checkoutStyle.hideHeader = true

        if var configuration = configuration {
            configuration.checkoutStyle = checkoutStyle
            self.configuration = configuration
        }
    }

    func setOldCheckoutStyle() {
        var checkoutStyle = CheckoutStyle()
        checkoutStyle.mode = .mediumAndLargeSheet
        checkoutStyle.sheetDismissable = .always

        if var configuration = configuration {
            configuration.checkoutStyle = checkoutStyle
            self.configuration = configuration
        }
    }

    func setIconTextButtonStyle(type: ButtonType, buttonHorizontalPosition: HorizontalPosition, buttonVerticalPosition: VerticalPosition, iconHorizontalPosition: HorizontalPosition) {
        var buttonStyle = ButtonStyle(type: type)
        buttonStyle.horizontalPosition = buttonHorizontalPosition
        buttonStyle.verticalPosition = buttonVerticalPosition

        var textStyle = TextStyle(text: "Close payment", size: 15, weight: .semibold)
        textStyle.color = "0476BA"
        buttonStyle.textStyle = textStyle

        var iconStyle = IconStyle()
        iconStyle.bundleIdentifier = "com.reepay.ReepayCheckoutExample"
        iconStyle.name = "octagon-xmark"
        iconStyle.color = "700000"
        iconStyle.position = iconHorizontalPosition
        buttonStyle.iconStyle = iconStyle

        if var configuration = configuration {
            configuration.checkoutStyle.dismissButtonStyle = buttonStyle
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
