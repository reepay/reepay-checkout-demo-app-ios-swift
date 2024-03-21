//
//  UIVIewControllerWrapper.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 18/03/2024.
//

import SwiftUI
import UIKit

struct UIViewControllerWrapper: UIViewControllerRepresentable {
    let viewController: UIViewController

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    class Coordinator: NSObject, UIViewControllerTransitioningDelegate {
        let parent: UIViewControllerWrapper

        init(_ parent: UIViewControllerWrapper) {
            self.parent = parent
        }
    }
}
