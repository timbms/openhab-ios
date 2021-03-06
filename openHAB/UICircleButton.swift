//
//  UICircleButton.swift
//  openHAB
//
//  Created by Victor Belov on 03/04/14.
//  Copyright (c) 2014 Victor Belov. All rights reserved.
//
//  Converted to Swift 4 by Tim Müller-Seydlitz and Swiftify on 06/01/18
//

import UIKit

var normalBackgroundColor: UIColor?
var normalTextColor: UIColor?

class UICircleButton: UIButton {
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        if let font = UIFont(name: "HelveticaNeue-Light", size: 20) {
            titleLabel?.font = font
        }
        layer.cornerRadius = bounds.size.width / 2.0
        layer.borderWidth = 1.0
        layer.borderColor = titleLabel?.textColor.cgColor
        addTarget(self, action: #selector(UICircleButton.buttonActionReleased), for: .touchUpInside)
        addTarget(self, action: #selector(UICircleButton.buttonActionTouched), for: .touchDown)
        normalBackgroundColor = backgroundColor

    }

    @objc func buttonActionReleased() {
    }

    @objc func buttonActionTouched() {
        backgroundColor = normalTextColor
        //    [self setTitleColor:normalBackgroundColor forState:UIControlStateNormal];
        normalTextColor = titleLabel?.textColor
        setTitleColor(UIColor.white, for: .normal)
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(UICircleButton.timerTicked(_:)), userInfo: nil, repeats: false)
    }

    @objc func timerTicked(_ timer: Timer?) {
        backgroundColor = normalBackgroundColor
        setTitleColor(normalTextColor, for: .normal)
        timer?.invalidate()
    }
}
