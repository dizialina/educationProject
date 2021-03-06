//
//  GoodButton.swift
//  CheTamUHohlov
//
//  Created by Roman.Safin on 1/17/16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

import UIKit
@IBDesignable
class GoodButton: UIButton {
    
    @IBInspectable var borderWidth:CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor:UIColor = UIColor.clearColor() {
        didSet {
            layer.borderColor = borderColor.CGColor
            
        }
    }
    
    @IBInspectable var highlightedBackgroundColor :UIColor?
    @IBInspectable var nonHighlightedBackgroundColor :UIColor?
    override var highlighted :Bool {
        get {
            return super.highlighted
        }
        set {
            if newValue {
                self.backgroundColor = highlightedBackgroundColor
            }
            else {
                self.backgroundColor = nonHighlightedBackgroundColor
            }
            super.highlighted = newValue
        }
    }
    
}
