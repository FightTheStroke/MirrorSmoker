//
//  AppColors.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI
import UIKit

enum AppColors {
    static var primary: Color {
        #if os(iOS)
        return Color(UIColor.systemRed)
        #else
        return Color.red
        #endif
    }
    
    static var systemBackground: Color {
        #if os(iOS)
        return Color(UIColor.systemBackground)
        #else
        return Color.white
        #endif
    }
    
    static var secondarySystemBackground: Color {
        #if os(iOS)
        return Color(UIColor.secondarySystemBackground)
        #else
        return Color(.sRGB, red: 0.95, green: 0.95, blue: 0.97)
        #endif
    }
    
    static var systemGray6: Color {
        #if os(iOS)
        return Color(UIColor.systemGray6)
        #else
        return Color(.sRGB, red: 0.85, green: 0.85, blue: 0.87)
        #endif
    }
}