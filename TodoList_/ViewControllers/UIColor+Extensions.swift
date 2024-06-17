//
//  UIColor+Extensions.swift
//  todoList
//
//  Created by 박에스더 on 6/11/24.
//

import Foundation
import UIKit



extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgba: Int = (Int)(r*255)<<24 | (Int)(g*255)<<16 | (Int)(b*255)<<8 | (Int)(a*255)<<0
        
        return String(format: "#%08x", rgba)
    }
    
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let red = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
        let green = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
        let blue = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
        let alpha = CGFloat(rgb & 0x000000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}



