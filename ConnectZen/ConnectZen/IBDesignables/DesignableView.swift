//
//  DesignableView.swift
//  ConnectZen
//
//  Created by Mamta Shah on 10/27/20.
//

import UIKit

class DesignableView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }

}
