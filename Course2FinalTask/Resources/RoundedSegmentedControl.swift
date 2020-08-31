//
//  RoundedSegmentedControl.swift
//  Course2FinalTask
//
//  Created by Андрей Гедзюра on 30.08.2020.
//  Copyright © 2020 e-Legion. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedSegmentedControl: UIControl {
    
    var buttons = [UIButton]()
    
    var selector: UIView!
    private var backgroundView: UIView!
    
    @IBInspectable
    var segments: String = "" {
        didSet {
            setUpView()
        }
    }
    
    @IBInspectable
    var isCornered: Bool = false {
        didSet {
            setUpView()
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            setUpView()
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = .black {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var verticalSegmentInsets: CGPoint = .zero {
        didSet {
            setUpView()
        }
    }
    
    var distribution: UIStackView.Distribution = .fillProportionally {
        didSet {
            setUpView()
        }
    }
    
    var alignement: UIStackView.Alignment = .fill {
        didSet {
            setUpView()
        }
    }
    
    var axis: NSLayoutConstraint.Axis = .horizontal {
        didSet {
            setUpView()
        }
    }
    
    @IBInspectable
    var horizontalSegmentInsets: CGPoint = .zero {
        didSet {
            setUpView()
        }
    }
    
    @IBInspectable
    var textColor: UIColor = .black {
        didSet {
            setUpView()
        }
    }
    
    
    @IBInspectable
    var font = UIFont(name: "Futura-Bold", size: 18) {
        didSet {
            setUpView()
        }
    }
    
    @IBInspectable
    var segmentColor: UIColor = .darkGray {
        didSet {
            setUpView()
        }
    }
    
    @IBInspectable
    var selectedTextColor: UIColor = .white {
        didSet {
            setUpView()
        }
    }
    
    @IBInspectable
    var mainImageColor: UIColor = .white {
        didSet {
            setUpView()
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize = CGSize(width: 5, height: 5) {
        didSet {
            setUpView()
        }
    }
    
    
    
    var selectedIndex: Int {
        return Int(index < buttons.count ? index : UInt(buttons.count) - 1)
    }
    
    
    @IBInspectable
    private var index: UInt = 0 
    
    func setUpView() {
        buttons.removeAll()
        subviews.forEach{$0.removeFromSuperview()}
        let buttonTitles = segments.components(separatedBy: ",")
        buttonTitles.forEach({
            let button = UIButton(type: .system)
            button.setTitle($0, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.backgroundColor = .clear
            button.titleLabel?.font = font
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttons.append(button)
        })
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = axis
        stackView.alignment = alignement
        stackView.distribution = distribution
        stackView.layoutMargins = UIEdgeInsets(top: verticalSegmentInsets.y, left: horizontalSegmentInsets.x, bottom: verticalSegmentInsets.x, right: horizontalSegmentInsets.y)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.frame = bounds
        stackView.backgroundColor = mainImageColor
        stackView.layoutSubviews()
        if buttons.isEmpty {
            selector = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        } else {
            buttons[selectedIndex].setTitleColor(selectedTextColor, for: .normal)
            selector = UIView(frame: CGRect(x: stackView.arrangedSubviews[selectedIndex].frame.origin.x, y: stackView.arrangedSubviews[selectedIndex].frame.origin.y, width: stackView.arrangedSubviews[selectedIndex].frame.width, height: stackView.arrangedSubviews[selectedIndex].frame.height))
        }
        selector.layer.cornerRadius = cornerRadius
        selector.backgroundColor = segmentColor
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        backgroundView.backgroundColor = mainImageColor
        addSubview(backgroundView)
        addSubview(selector)
        addSubview(stackView)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        for (index, button) in buttons.enumerated() {
            button.setTitleColor(textColor, for: .normal)
            if sender == button {
                self.index = UInt(index)
                UIView.animate(withDuration: 0.3, animations: {
                    self.selector.frame = button.frame
                    button.setTitleColor(self.selectedTextColor, for: .normal)
                })
            }
        }
        
        sendActions(for: .valueChanged)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if isCornered {
            switch cornerRadius == 0 {
            case true:
                layer.cornerRadius = min(frame.width, frame.height) / 2
                selector.layer.cornerRadius = min(selector.frame.width, selector.frame.height) / 2
            default:
                layer.cornerRadius = cornerRadius
                selector.layer.cornerRadius = cornerRadius
            }
        }
        selector.layer.shadowColor = UIColor.black.cgColor
        selector.layer.shadowOpacity = 0.6
        selector.layer.shadowOffset = shadowOffset
    }
}
