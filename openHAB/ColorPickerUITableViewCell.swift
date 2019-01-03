//  Converted to Swift 4 by Swiftify v4.2.28993 - https://objectivec2swift.com/
//
//  ColorPickerUITableViewCell.swift
//  openHAB
//
//  Created by Victor Belov on 16/04/14.
//  Copyright (c) 2014 Victor Belov. All rights reserved.
//

@objc protocol ColorPickerUITableViewCellDelegate: NSObjectProtocol {
    func didPressColorButton(_ cell: ColorPickerUITableViewCell?)
}

class ColorPickerUITableViewCell: GenericUITableViewCell {
    var upButton: UICircleButton?
    var colorButton: UICircleButton?
    var downButton: UICircleButton?
    @objc weak var delegate: ColorPickerUITableViewCellDelegate?

    required init?(coder: NSCoder) {
        print("RollershutterUITableViewCell initWithCoder")
        super.init(coder: coder)
        
        upButton = viewWithTag(701) as? UICircleButton
        colorButton = viewWithTag(702) as? UICircleButton
        downButton = viewWithTag(703) as? UICircleButton
        
        upButton?.setTitle("▲", for: .normal)
        downButton?.setTitle("▼", for: .normal)
        
        upButton?.addTarget(self, action: #selector(ColorPickerUITableViewCell.upButtonPressed), for: .touchUpInside)
        colorButton?.addTarget(self, action: #selector(ColorPickerUITableViewCell.colorButtonPressed), for: .touchUpInside)
        downButton?.addTarget(self, action: #selector(ColorPickerUITableViewCell.downButtonPressed), for: .touchUpInside)
        selectionStyle = UITableViewCell.SelectionStyle.none
        separatorInset = UIEdgeInsets.zero
    
    }

    override func displayWidget() {
        textLabel?.text = widget?.labelText()
        colorButton?.backgroundColor = widget?.item.stateAsUIColor()
    }

    @objc func upButtonPressed() {
        widget?.sendCommand("ON")
    }

    @objc func colorButtonPressed() {
        if delegate != nil {
            delegate?.didPressColorButton(self)
        }
    }

    @objc func downButtonPressed() {
        widget?.sendCommand("OFF")
    }
}
