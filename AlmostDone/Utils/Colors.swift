//
//  Colors.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import SwiftUI

extension Color {
    // Custom "Cursor Dark" background color (slightly lighter than pure black)
    static let cursorDark = Color(red: 0.05, green: 0.05, blue: 0.05) // #1C1C1C approximately
    
    static var appBackground: Color {
        Color("AppBackground")
    }
}

extension UIColor {
    static let cursorDark = UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1.0)
}

