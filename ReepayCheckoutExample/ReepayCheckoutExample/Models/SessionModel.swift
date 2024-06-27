//
//  Session.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 21/03/2024.
//

import Foundation

class SessionModel: ObservableObject {
    @Published var id: String = ""

    init() {
        /// Add Reepay Checkout session ID:
        id = "<reepay_checkout_session_id>"
    }
}
