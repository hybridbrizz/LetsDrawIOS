//
//  UIView+showToast.swift
//  LiquidOceanIOS
//
//  Created by Eric Versteeg on 4/5/25.
//  Copyright © 2025 Eric Versteeg. All rights reserved.
//

import UIKit

// Extension by Claude
extension UIView {
    /**
     Displays a toast-style popup with the given message.
     
     - Parameters:
        - message: The text to display in the toast
        - duration: How long the toast should appear (in seconds)
        - backgroundColor: The background color of the toast (default: dark gray)
        - textColor: The color of the text (default: white)
        - font: The font to use for the message (default: system font, 14pt)
        - bottomPadding: Padding from the bottom of the screen (default: 50)
        - cornerRadius: Corner radius of the toast (default: 10)
     */
    func showToast(
        message: String,
        duration: TimeInterval = 2.0,
        backgroundColor: UIColor = .darkGray.withAlphaComponent(0.9),
        textColor: UIColor = .white,
        font: UIFont = .systemFont(ofSize: 14),
        bottomPadding: CGFloat = 50,
        cornerRadius: CGFloat = 10
    ) {
        // Find the window to add the toast to
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
            return
        }
        
        // Create the toast container view
        let toastContainer = UIView()
        toastContainer.backgroundColor = backgroundColor
        toastContainer.layer.cornerRadius = cornerRadius
        toastContainer.clipsToBounds = true
        toastContainer.alpha = 0.0
        
        // Create the label for the message
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = textColor
        messageLabel.font = font
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        
        // Add the label to the container
        toastContainer.addSubview(messageLabel)
        window.addSubview(toastContainer)
        
        // Set up constraints
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Message label constraints
            messageLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 15),
            messageLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -15),
            messageLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -10),
            
            // Toast container constraints
            toastContainer.centerXAnchor.constraint(equalTo: window.centerXAnchor),
            toastContainer.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -bottomPadding),
            toastContainer.widthAnchor.constraint(lessThanOrEqualTo: window.widthAnchor, multiplier: 0.8)
        ])
        
        // Animate toast appearing
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            // Wait for the specified duration
            UIView.animate(withDuration: 0.2, delay: duration, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: { _ in
                // Remove the toast container from view
                toastContainer.removeFromSuperview()
            })
        })
    }
}
