//
//  NotificationBanner.swift
//  ConnectZen
//
//  Created by Shrishti Jain on 11/9/20.

import Foundation
import UIKit

class NotificationBanner {
  static let labelLeftMarging = CGFloat(16)
  static let labelTopMargin = CGFloat(40)
  static let animateDuration = 0.5
  static let bannerAppearanceDuration: TimeInterval = 4
  
  static func showFailure(_ text: String) {
    let superView = UIApplication.shared.keyWindow!.rootViewController!.view!

    let height = CGFloat(40)
    let width = superView.bounds.size.width

    let bannerView = UIView(frame: CGRect(x: 0, y: 0-height, width: width, height: height))
    bannerView.layer.opacity = 1
    bannerView.backgroundColor = UIColor(red: 255/255, green: 51/255, blue: 51/255, alpha: 1)
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    
    let label = UILabel(frame: CGRect.zero)
    label.textColor = UIColor.black
    label.numberOfLines = 0
    label.text = text
    label.translatesAutoresizingMaskIntoConstraints = false
    
    bannerView.addSubview(label)
    superView.addSubview(bannerView)
    
    let labelCenterYContstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: bannerView, attribute: .centerY, multiplier: 1, constant: 0)
    let labelCenterXConstraint = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: bannerView, attribute: .centerX, multiplier: 1, constant: 0)
    let labelWidthConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width - labelLeftMarging*2)
    let labelTopConstraint = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: bannerView, attribute: .top, multiplier: 1, constant: labelTopMargin)
    
    let bannerWidthConstraint = NSLayoutConstraint(item: bannerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width)
    let bannerCenterXConstraint = NSLayoutConstraint(item: bannerView, attribute: .leading, relatedBy: .equal, toItem: superView, attribute: .leading, multiplier: 1, constant: 0)
    let bannerTopConstraint = NSLayoutConstraint(item: bannerView, attribute: .top, relatedBy: .equal, toItem: superView, attribute: .top, multiplier: 1, constant: 0-height)
    
    NSLayoutConstraint.activate([labelCenterYContstraint, labelCenterXConstraint, labelWidthConstraint, labelTopConstraint, bannerWidthConstraint, bannerCenterXConstraint, bannerTopConstraint])
    
    UIView.animate(withDuration: animateDuration) {
      bannerTopConstraint.constant = 0
      superView.layoutIfNeeded()
    }
    
    //remove subview after time 2 sec
    UIView.animate(withDuration: animateDuration, delay: bannerAppearanceDuration, options: [], animations: {
      bannerTopConstraint.constant = 0 - bannerView.frame.height
      superView.layoutIfNeeded()
    }, completion: { finished in
      if finished {
        bannerView.removeFromSuperview()
      }
    })
  }
    
    static func successShow(_ text: String) {
      let superView = UIApplication.shared.keyWindow!.rootViewController!.view!

      let height = CGFloat(40)
      let width = superView.bounds.size.width

      let bannerView = UIView(frame: CGRect(x: 0, y: 0-height, width: width, height: height))
        bannerView.layer.opacity = 1
        bannerView.backgroundColor = UIColor(red: 34/255, green: 228/255, blue: 172/255, alpha: 1)
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      
      let label = UILabel(frame: CGRect.zero)
      label.textColor = UIColor.black
      label.numberOfLines = 0
      label.text = text
      label.translatesAutoresizingMaskIntoConstraints = false
      
      bannerView.addSubview(label)
      superView.addSubview(bannerView)
      
      let labelCenterYContstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: bannerView, attribute: .centerY, multiplier: 1, constant: 0)
      let labelCenterXConstraint = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: bannerView, attribute: .centerX, multiplier: 1, constant: 0)
      let labelWidthConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width - labelLeftMarging*2)
      let labelTopConstraint = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: bannerView, attribute: .top, multiplier: 1, constant: labelTopMargin)
      
      let bannerWidthConstraint = NSLayoutConstraint(item: bannerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width)
      let bannerCenterXConstraint = NSLayoutConstraint(item: bannerView, attribute: .leading, relatedBy: .equal, toItem: superView, attribute: .leading, multiplier: 1, constant: 0)
      let bannerTopConstraint = NSLayoutConstraint(item: bannerView, attribute: .top, relatedBy: .equal, toItem: superView, attribute: .top, multiplier: 1, constant: 0-height)
      
      NSLayoutConstraint.activate([labelCenterYContstraint, labelCenterXConstraint, labelWidthConstraint, labelTopConstraint, bannerWidthConstraint, bannerCenterXConstraint, bannerTopConstraint])
      
      UIView.animate(withDuration: animateDuration) {
        bannerTopConstraint.constant = 0
        superView.layoutIfNeeded()
      }
      
      //remove subview after time 2 sec
      UIView.animate(withDuration: animateDuration, delay: bannerAppearanceDuration, options: [], animations: {
        bannerTopConstraint.constant = 0 - bannerView.frame.height
        superView.layoutIfNeeded()
      }, completion: { finished in
        if finished {
          bannerView.removeFromSuperview()
        }
      })
    }
    
    
    static func showWithColor(_ text: String, _ backgroundColor:UIColor, _ textColor:UIColor) {
      let superView = UIApplication.shared.keyWindow!.rootViewController!.view!

      let height = CGFloat(40)
      let width = superView.bounds.size.width

      let bannerView = UIView(frame: CGRect(x: 0, y: 0-height, width: width, height: height))
      bannerView.layer.opacity = 1
      bannerView.backgroundColor = backgroundColor
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      
      let label = UILabel(frame: CGRect.zero)
      label.textColor = textColor
      label.numberOfLines = 0
      label.text = text
      label.translatesAutoresizingMaskIntoConstraints = false
      
      bannerView.addSubview(label)
      superView.addSubview(bannerView)
      
      let labelCenterYContstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: bannerView, attribute: .centerY, multiplier: 1, constant: 0)
      let labelCenterXConstraint = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: bannerView, attribute: .centerX, multiplier: 1, constant: 0)
      let labelWidthConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width - labelLeftMarging*2)
      let labelTopConstraint = NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: bannerView, attribute: .top, multiplier: 1, constant: labelTopMargin)
      
      let bannerWidthConstraint = NSLayoutConstraint(item: bannerView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width)
      let bannerCenterXConstraint = NSLayoutConstraint(item: bannerView, attribute: .leading, relatedBy: .equal, toItem: superView, attribute: .leading, multiplier: 1, constant: 0)
      let bannerTopConstraint = NSLayoutConstraint(item: bannerView, attribute: .top, relatedBy: .equal, toItem: superView, attribute: .top, multiplier: 1, constant: 0-height)
      
      NSLayoutConstraint.activate([labelCenterYContstraint, labelCenterXConstraint, labelWidthConstraint, labelTopConstraint, bannerWidthConstraint, bannerCenterXConstraint, bannerTopConstraint])
      
      UIView.animate(withDuration: animateDuration) {
        bannerTopConstraint.constant = 0
        superView.layoutIfNeeded()
      }
      
      //remove subview after time 2 sec
      UIView.animate(withDuration: animateDuration, delay: bannerAppearanceDuration, options: [], animations: {
        bannerTopConstraint.constant = 0 - bannerView.frame.height
        superView.layoutIfNeeded()
      }, completion: { finished in
        if finished {
          bannerView.removeFromSuperview()
        }
      })
    }
}
