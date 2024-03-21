//
//  UIVIewControllerWrapper.swift
//  ReepayCheckoutExample
//
//  Created by Johnny Ly on 18/03/2024.
//

import UIKit
import SwiftUI

struct UIViewControllerWrapper: UIViewControllerRepresentable {
    let viewController: UIViewController

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update the UIViewController if needed
    }

    class Coordinator: NSObject, UIViewControllerTransitioningDelegate {
        let parent: UIViewControllerWrapper

        init(_ parent: UIViewControllerWrapper) {
            self.parent = parent
            print("init UIViewControllerWrapper")
        }
    }
}
