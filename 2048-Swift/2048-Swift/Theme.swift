//
//  Theme.swift
//  2048-Swift
//
//  Created by Pan on 03/09/2017.
//  Copyright © 2017 Yo. All rights reserved.
//

import UIKit

class Theme: NSObject {
    
    static let cornerRadius: CGFloat = 4.0
    static let boldFontName: String = "AvenirNext-DemiBold"
    static let regularFontName: String =  "AvenirNext-Regular"
    
    class func numberFont() -> UIFont {
        if let font = UIFont(name: boldFontName, size: 38) {
            return font
        }
        return UIFont.systemFont(ofSize: 38)
    }
    
    class func tileColor(_ value: Int) -> UIColor {
        switch (levelForValue(value: value)) {
        case 1:
            return Color(rgb: (238, 228, 218));
        case 2:
            return Color(rgb: (237, 224, 200));
        case 3:
            return Color(rgb: (242, 177, 121));
        case 4:
            return Color(rgb: (245, 149, 99));
        case 5:
            return Color(rgb: (246, 124, 95));
        case 6:
            return Color(rgb: (246, 94, 59));
        case 7:
            return Color(rgb: (237, 207, 114));
        case 8:
            return Color(rgb: (237, 204, 97));
        case 9:
            return Color(rgb: (237, 200, 80));
        case 10:
            return Color(rgb: (237, 197, 63));
        case 11:
            return Color(rgb: (237, 194, 46));
        case 12:
            return Color(rgb: (173, 183, 119));
        case 13:
            return Color(rgb: (170, 183, 102));
        case 14:
            return Color(rgb: (164, 183, 79));
        default:
            return Color(rgb: (161, 183, 63));
        }
    }
    
    class func numberColor(_ value: Int) -> UIColor {
        switch (levelForValue(value: value)) {
        case 1, 2:
            return Color(rgb: (118, 109, 100));
        default:
            return UIColor.white;
        }
    }
    
    class func backgroundColor() -> UIColor {
        return Color(rgb: (250, 248, 239));
    }
    
    class func gridColor() -> UIColor {
        return Color(rgb: (187, 173, 160));
    }
    
    class func boardColor() -> UIColor {
        return Color(rgb: (204, 192, 179));
    }
    
    class func scoreBoardColor() -> UIColor {
        return Color(rgb: (187, 173, 160));
    }
    
    class func buttonColor() -> UIColor {
        return Color(rgb: (119, 110, 101));
    }
}


extension Theme {
    class func Color(rgb:(CGFloat, CGFloat, CGFloat)) -> UIColor {
        let (r, g, b) = rgb
        return UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
}

extension Theme {
    class func levelForValue(value: Int) -> Int {
        let gameType = Global.gameType()
        switch gameType {
        case .powerOf2, .powerOf3:
            let base = gameType == .powerOf2 ? 2 : 3
            var num = base
            for i in 1...15 {
                if num == value { return i }
                num *= base
            }
        case .fibonacci:
            var num1 = 1; var num2 = 2; var num3 = 0;
            for i in 1...15 {
                if num2 == value { return i }
                num3 = num1 + num2
                num1 = num2
                num2 = num3
            }
        }
        return 1
    }
}
