//
// Jenga
// Created by: onee on 2024-02-19
//

import RealityKit
import RealityKitContent
import SwiftUI

struct MainMenu: View {
    @State private var isJengaShown = false

    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow

    var body: some View {
        VStack {
            VStack(spacing: 12) {
                Text("Jenga!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Button(action: {
                    if !isJengaShown {
                        openWindow(id: "JengaView")
                    } else {
                        dismissWindow(id: "JengaView")
                    }
                    isJengaShown = !isJengaShown
                }, label: {
                    if isJengaShown {
                        Label("Quit", systemImage: "xmark")
                    } else {
                        Label("Start", systemImage: "play.fill")
                    }
                })
            }
            .frame(width: 360)
            .padding(36)
        }
    }
}

#Preview() {
    MainMenu()
}
