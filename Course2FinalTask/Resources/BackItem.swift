//
//  BackItem.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 06.09.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

@IBDesignable
class BackItem: UIControl {
    
    private var buttonView: UIView!
    private var shadowView: UIView!
    private var buttonLabel: UILabel!
    
    @IBInspectable
    var buttonColor: UIColor? = .green {
        didSet {
            setUpView()
        }
    }
    
    @IBInspectable
    var textColor: UIColor? = .black {
        didSet {
            setUpView()
        }
    }
    
    @IBInspectable
    var title: String = "Back" {
        didSet {
            setUpView()
        }
    }
    
    var font = UIFont(name: "Futura-Bold", size: 13) {
        didSet {
            setUpView()
        }
    }
    
    var buttonBounds: CGRect? {
        return shadowView?.bounds
    }
    
    private func setUpView() {
        subviews.forEach({$0.removeFromSuperview()})
        shadowView?.subviews.forEach({$0.removeFromSuperview()})
        buttonLabel = UILabel(frame: CGRect(x: 1, y: 1, width: 1, height: 1))
        buttonLabel.isUserInteractionEnabled = false
        buttonLabel.text = title
        buttonLabel.font = font
        buttonLabel.textColor = textColor
        buttonLabel.sizeToFit()
        let trueCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        buttonLabel.center = trueCenter
        let shadowFrame = CGRect(x: 0, y: 0, width: buttonLabel.frame.size.width + 16, height: buttonLabel.frame.size.height + 8)
        shadowView = UIView(frame: shadowFrame)
        shadowView.isUserInteractionEnabled = false
        shadowView.center = trueCenter
        shadowView.backgroundColor = .clear
        buttonView = UIView(frame: shadowFrame)
        buttonView.isUserInteractionEnabled = false
        buttonView.backgroundColor = buttonColor
        buttonView.layer.cornerRadius = shadowFrame.size.height / 2
        shadowView.addSubview(buttonView)
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 2, height: 2)
        shadowView.layer.shadowOpacity = 0.6
        addSubview(shadowView)
        addSubview(buttonLabel)
        
    }
    
    
    func showAnimation(_ completion: @escaping() -> Void) {
        isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0, delay: 0, options: [], animations: {
            self.shadowView.transform = CGAffineTransform(translationX: 2, y: 2)
            self.buttonLabel.transform = CGAffineTransform(translationX: 2, y: 2)
            self.shadowView.layer.shadowOpacity = 0
            
        }, completion: {_ in
            UIView.animate(withDuration: 0.05, delay: 0, options: [], animations: {
                self.shadowView.transform = CGAffineTransform(translationX: 0, y: 0)
                self.buttonLabel.transform = CGAffineTransform(translationX: 0, y: 0)
                self.shadowView.layer.shadowOpacity = 0.6
            }, completion: {_ in
                self.isUserInteractionEnabled = true
                completion()
            })
        })
    }
}
