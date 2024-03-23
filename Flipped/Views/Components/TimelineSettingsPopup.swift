//
//  TimelineSettingsPopup.swift
//  Flipped
//
//  Created by Zoe Olson on 3/21/24.
//

import SwiftUI

struct TimelineSettingsPopup: View {
    
    @Binding var onionSkinModeIsOn: Bool
    @Binding var framesPerSecond: Int
    
    var body: some View {
        
        VStack {
            Stepper("\(framesPerSecond) frames/second", value: $framesPerSecond)
                .padding()
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 0.5)
                .foregroundColor(Color.black.opacity(0.1))
            Toggle(isOn: $onionSkinModeIsOn) { Text("Onion Skin Mode") }
                .padding()
        }
        
    }
}

#Preview {
    TimelineSettingsPopup(onionSkinModeIsOn: .constant(true), framesPerSecond: .constant(50))
}
