//
//  CodableColor.swift
//  USGS
//
//  Created by Jonathan Melitski on 9/27/25.
//

import SwiftUI

public struct CodableColor: Codable, Hashable, Equatable {
    public let red: CGFloat
    public let green: CGFloat
    public let blue: CGFloat
    public let alpha: CGFloat
    
    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    public init(from color: Color) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 1
        if UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        } else {
            self.red = 0
            self.green = 0
            self.blue = 0
            self.alpha = 1
        }
    }
    
    public var toSwiftUIColor: Color {
        return Color(red: self.red, green: self.green, blue: self.blue, opacity: self.alpha)
    }
}
