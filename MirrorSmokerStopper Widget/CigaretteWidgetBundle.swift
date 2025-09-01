//
//  CigaretteWidgetBundle.swift
//  mirrorsmokerwidget
//
//  Created by Roberto D'Angelo on 31/08/25.
//

import WidgetKit
import SwiftUI

// Not the main widget bundle because mirrorsmokerwidgetBundle.swift already has @main
struct CigaretteWidgetBundle: WidgetBundle {
    var body: some Widget {
        CigaretteWidget()
    }
}
