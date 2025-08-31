//
//  Tag+Extensions.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI

extension Tag {
    var color: Color {
        Color.fromHex(colorHex) ?? .red
    }
}