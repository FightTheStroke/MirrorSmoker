//
//  Tag+Extensions.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import SwiftUI

extension Tag {
    var swiftUIColor: Color {
        // Usa l'helper presente in Hex.swift
        Color.fromHex(color) ?? .red
    }
}
