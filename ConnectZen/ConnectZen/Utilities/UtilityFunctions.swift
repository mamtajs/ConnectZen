//
//  UtilityFunctions.swift
//  ConnectZen
//
//  Created by Mamta Shah on 11/3/20.
//

import Foundation
import UIKit

func showToast(controller: UIViewController, message : String, seconds: Double, colorBackground: UIColor){
    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    alert.view.backgroundColor = colorBackground
    alert.view.alpha = 0.5
    alert.view.layer.cornerRadius = 15
    controller.present(alert, animated: true)
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
        alert.dismiss(animated: true)
    }
}
