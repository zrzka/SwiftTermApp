//
//  TerminalButton.swift
//  SwiftTermApp
//
//  Created by Miguel de Icaza on 5/1/20.
//  Copyright © 2020 Miguel de Icaza. All rights reserved.
//

import Foundation
import SwiftUI

struct STButton: View {
    var text: String
    let icon: String

    var body: some View {
        HStack {
            Spacer()
            Image (systemName: icon)
                .foregroundColor(ButtonColors.highColor)
                .font(Font.title.weight(.semibold))
            Text (self.text)
                .foregroundColor(ButtonColors.highColor)
                .fontWeight(.bold)
            Spacer()
        }
        .padding ()
        .background(ButtonColors.backgroundColor)
        .cornerRadius(10)
        .foregroundColor(ButtonColors.highColor)
        .padding()
    }
}

