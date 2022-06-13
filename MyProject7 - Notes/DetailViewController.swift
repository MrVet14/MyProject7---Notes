//
//  DetailViewController.swift
//  MyProject7 - Notes
//
//  Created by Vitali Vyucheiski on 5/18/22.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var textField: UITextView!
    
    var noteTitle: String = ""
    var noteBody: String = ""
    var noteNumber: Int = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        title = noteTitle
        navigationItem.largeTitleDisplayMode = .never
        
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTitleTapped))
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        navigationItem.rightBarButtonItems = [shareButton, editButton]
        
        textField.text = noteBody
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func editTitleTapped() {
        let ac = UIAlertController(title: "Rename note", message: nil, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            self?.noteTitle = newName
            self?.title = newName
        })

        present(ac, animated: true)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            textField.contentInset = .zero
        } else {
            textField.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        textField.scrollIndicatorInsets = textField.contentInset

        let selectedRange = textField.selectedRange
        textField.scrollRangeToVisible(selectedRange)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        noteBody = textField.text
        NotificationCenter.default.post(name: Notification.Name("noteUpdate"),
                                        object: ["title": noteTitle,
                                                 "body": noteBody,
                                                 "noteNumber": String(noteNumber)])
    }
    
    @objc func shareTapped() {
        let vc = UIActivityViewController(activityItems: [noteTitle, "\n\n" + noteBody], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

}
