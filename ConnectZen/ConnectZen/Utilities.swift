//
//  Utilities.swift
//  ConnectZen
//
//  Created by Shrishti Jain
//

import Foundation
import UIKit

class Utilities {
    
    static func styleTextField(_ textfield:UITextField) {
        
        // Create the bottom line
        let bottomLine = CALayer()
        
        bottomLine.frame = CGRect(x: 0, y: textfield.frame.height - 2, width: textfield.frame.width, height: 2)
        
        bottomLine.backgroundColor = UIColor.init(red: 48/255, green: 173/255, blue: 99/255, alpha: 1).cgColor
        
        // Remove border on text field
        textfield.borderStyle = .none
        
        // Add the line to the text field
        textfield.layer.addSublayer(bottomLine)
        
    }
    
    static func styleFilledButton(_ button:UIButton, cornerRadius:CGFloat) {
        // Filled rounded corner style
        button.backgroundColor = UIColor.init(red: 8/255, green: 232/255, blue: 222/255, alpha: 1)
        button.layer.cornerRadius = cornerRadius
        button.layer.opacity = 1
        button.tintColor = UIColor.black
        button.setTitleColor(UIColor.black, for: .normal)
    }
    
    static func disabledFilledButton(_ button:UIButton, cornerRadius:CGFloat) {
        // Filled rounded corner style
        button.backgroundColor = UIColor.init(red: 8/255, green: 232/255, blue: 222/255, alpha: 1)
        button.layer.cornerRadius = cornerRadius
        button.layer.opacity = 0.5
        button.tintColor = UIColor.black
        button.setTitleColor(UIColor.black, for: .normal)
    }
   
    static func styleHollowButton(_ button:UIButton) {
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 15
        button.tintColor = UIColor.black
        button.layer.shadowColor = UIColor(named: "buttonShadow")?.cgColor
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    static func styleFilledButtonWithShadow(_ button:UIButton) {
        
        button.backgroundColor = UIColor.white
        //button.layer.borderWidth = 1
        //button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 10
        button.tintColor = UIColor.black
        button.layer.shadowColor = UIColor(named: "buttonShadow")?.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.showsTouchWhenHighlighted = true
        button.setTitleColor(UIColor.gray, for: .highlighted)
    }
    
    static func styleFilledButtonWithShadowDestructive(_ button:UIButton) {
        
        button.backgroundColor = UIColor.white
        //button.layer.borderWidth = 1
        //button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 10
        button.tintColor = UIColor.red
        button.layer.shadowColor = UIColor(named: "buttonShadow")?.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = CGSize(width: 1, height: 1)
        button.showsTouchWhenHighlighted = true
        button.setTitleColor(UIColor.gray, for: .highlighted)
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])(?=.*[0-9])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
    static func isEmailValid(_ email: String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    
}

/*extension UIButton{
    override open var isHighlighted:Bool{
        didSet{
            if(isHighlighted){
                self.backgroundColor = lightColor
            }
            else{
                self.backgroundColor = brightColor
            }
        }
    }
}*/
