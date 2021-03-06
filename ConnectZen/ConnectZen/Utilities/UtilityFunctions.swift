//
//  UtilityFunctions.swift
//  ConnectZen
//
//  Created by Mamta Shah on 11/3/20.
//

import Foundation
import UIKit

func showToast(controller: UIViewController, message : String, seconds: Double, colorBackground: UIColor, title: String){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.view.backgroundColor = colorBackground
    alert.view.alpha = 0.5
    alert.view.layer.cornerRadius = 15
    controller.present(alert, animated: true)
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
        alert.dismiss(animated: true)
    }
}

func navigateToTabBar(){
    let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "TabNavigationVC") as? UINavigationController
    UIApplication.shared.windows.first?.rootViewController = vc
    UIApplication.shared.windows.first?.makeKeyAndVisible()
}

func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}

protocol PassBackPreference {
    func OnPrefAddition(Day: String, StartDate: Date, EndDate: Date)
}
