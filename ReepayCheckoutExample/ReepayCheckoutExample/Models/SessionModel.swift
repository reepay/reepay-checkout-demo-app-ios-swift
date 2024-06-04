//
//  Session.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 21/03/2024.
//

import Foundation

class SessionModel: ObservableObject {
    @Published var id: String = ""
    @Published var acceptURL: String = ""
    @Published var cancelURL: String = ""

    init() {
        /// 1. Add Reepay Checkout session ID
        id = "<reepay_checkout_session_id>"

        /// 2. Add accept and cancel URLs of your Reepay Checkout session
        acceptURL = "myapp://domain.com/accept"
        cancelURL = "myapp://domain.com/cancel"
    }
}
