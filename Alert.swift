//
//  Alert.swift
//
//
//  Created by Alexander Kozharsky on 20.01.17.
//  Copyright © 2017 Alexander Kozharsky. All rights reserved.
//

import UIKit

/**
 Alert controller.
 Simply shows alert with extended parameters
*/
class Alert {
    //MARK: Public properties
    public static var currentAlert: UIAlertController?
    
    //MARK: Public class methods
    /**
     Function shows alert with extended parameters
     - Parameter title: Alert window title
     - Parameter message: Specifies alert message
     - Parameter target: (optional) Specifies presentating view controller
     - Parameter dismissAfter: (optional) Specifies what time needed to dismiss alert. If specified, then `OK` button not appearing
     - Parameter okHandler: Handler closure for `OK` button
     - Parameter completion: Completion handler called after alert dismiss
    */
    @discardableResult
    public class func show(with title: String, message: String, target: UIViewController? = nil, dismissAfter: Int? = nil, okHandler: ((UIAlertAction) -> Void)? = nil, completion: (() -> Void)? = nil) -> UIAlertController? {
        if let currentAlert = self.currentAlert, let currentMessage = currentAlert.message {
            let currentMessageSplit = currentMessage.components(separatedBy: "\n")
            for previousMessage in currentMessageSplit {
                if message == previousMessage {
                    return nil
                }
            }
            
            currentAlert.message = "\(currentMessage)\n\(message)"
            return nil
        }
        
        let currentViewController = target ?? Alert.getCurrentViewController()
        let deadline = dismissAfter ?? 0
        currentViewController.view.endEditing(true)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if deadline < 1 {
            let alertOKAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                if let okHandler = okHandler {
                    okHandler(action)
                }
                
                self.currentAlert = nil
            })
            alertController.addAction(alertOKAction)
        }
        
        self.currentAlert = alertController
        
        if deadline > 0 {
            currentViewController.present(alertController, animated: true, completion: {
                let deadline = DispatchTime.now() + Double(deadline)
                let completionHandler = completion ?? {}
                DispatchQueue.main.asyncAfter(deadline: deadline, execute: {
                    alertController.dismiss(animated: true, completion: {
                        completionHandler()
                        self.currentAlert = nil
                    })
                })
            })
        } else {
            currentViewController.present(alertController, animated: true, completion: completion)
        }
        
        return alertController
    }
    
    //MARK: Private class methods
    /** Returns current top view controller */
    private class func getCurrentViewController() -> UIViewController {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        } else {
            return UIViewController()
        }
    }
}
