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
        id = "<reepay_session_id>"
        acceptURL = "https://sandbox.reepay.com/api/httpstatus/200/accept"
        cancelURL = "https://sandbox.reepay.com/api/httpstatus/200/cancel"
    }
}
