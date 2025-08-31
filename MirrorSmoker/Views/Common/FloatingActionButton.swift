//
//  FloatingActionButton.swift
//  Mirror Smoker
//
//  Created by Roberto D'Angelo on 27/08/24.
//

import SwiftUI

struct FloatingActionButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.red)
                .clipShape(Circle())
                .shadow(radius: 4)
        }
    }
}

#Preview {
    FloatingActionButton(action: {})
}