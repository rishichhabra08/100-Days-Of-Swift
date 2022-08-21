//
//  ViewController.swift
//  Project28
//
//  Created by Rishi Chhabra on 20/08/22.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {
    
    @IBOutlet var secret: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = "Nothing To See Here"
        
        
        let notificationCentre = NotificationCenter.default
        
        notificationCentre.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        notificationCentre.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        notificationCentre.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        
        
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        print(keyboardValue)
        
        let keyboardScreenEnd = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        
        secret.scrollRangeToVisible(selectedRange)
        
        
    }
    
    
    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        
        var error : NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify Yourself"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        let ac = UIAlertController(title: "Authentication Error", message: "you could not be verified; please try again", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "Ok", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry Unavailable", message: "Your device is not configured!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            self.present(ac, animated: true)
        }
//        unlockSecretMessage()
        
    }
    
    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret Stuff"
        
        secret.text = KeychainWrapper.standard.string(forKey: "secretMessage") ?? ""
         
    }
    
    @objc func saveSecretMessage() {
        guard secret.isHidden == false else {return}
        
        KeychainWrapper.standard.set(secret.textStorage, forKey: "secretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing To See Here"
    }
}

