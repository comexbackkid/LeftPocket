//
//  MailView.swift
//  LeftPocket
//
//  Created by Christian Nachtrieb on 5/31/25.
//

import SwiftUI
import MessageUI

/// A UIViewControllerRepresentable wrapper around MFMailComposeViewController.
/// You pass in:
///   - recipient: [String] (e.g. ["leftpocketpoker@gmail.com"])
///   - subject: String
///   - body: String
///   - attachmentURL: URL? (the file you want attached)
///
/// When the user finishes (sent/canceled), the `onComplete` closure is called.
struct MailView: UIViewControllerRepresentable {
    
    /// The list of “To:” addresses
    let recipients: [String]
    /// The email subject
    let subject: String
    /// The email body (plain text)
    let body: String
    /// File to attach (if any)
    let attachmentURL: URL?
    /// Called when the mail composer finishes (sent/canceled). Dismiss the sheet.
    let onComplete: (MFMailComposeResult, Error?) -> Void
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailView
        
        init(parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            parent.onComplete(result, error)
            controller.dismiss(animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(recipients)
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        
        // If attachmentURL is non‐nil, try to load data and attach
        if let fileURL = attachmentURL,
           let fileData = try? Data(contentsOf: fileURL) {
            // Mimetypes: “text/csv” is safe for a CSV
            vc.addAttachmentData(fileData,
                                 mimeType: "text/csv",
                                 fileName: fileURL.lastPathComponent)
        }
        
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // Nothing to update dynamically
    }
}
