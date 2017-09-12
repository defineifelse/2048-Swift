//
//  TileView.swift
//  2048-Swift
//
//  Created by Pan on 02/09/2017.
//  Copyright © 2017 Yo. All rights reserved.
//

import UIKit

class TileView: UIView {
    
    var position: Position
    var value: Int = 0 {
        didSet {
            numberLabel.text = "\(value)"
            numberLabel.textColor = Theme.numberColor(value)
            backgroundColor = Theme.tileColor(value)
        }
    }
    
    private lazy var numberLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        label.textAlignment = NSTextAlignment.center
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.font = Theme.numberFont()
        label.textColor = Theme.numberColor(self.value)
        label.text = "\(self.value)"
        return label
    }()
    
    init(frame: CGRect, position p: Position, value: Int) {
        position = p
        super.init(frame: frame)
        self.value = value
        backgroundColor = Theme.tileColor(value)
        layer.cornerRadius = Theme.cornerRadius
        addSubview(numberLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
