//
//  WidgetSettings.swift
//  USGS
//
//  Created by Jonathan Melitski on 1/12/26.
//
import SwiftUI

public struct WidgetSettings: Codable, Hashable {
    public var titleOverride: String? = nil
    public var topColor: CodableColor = .init(from: Color("TopGradient"))
    public var bottomColor: CodableColor = .init(from: Color("BottomGradient"))
}
