//
// Jenga
// Created by: onee on 2024-02-19
//
#if os(visionOS)
import RealityKit
import SwiftUI

struct MainMenu: View {
    @EnvironmentObject var windowModel: WindowModel

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
                    if !windowModel.isJengaShown {
                        openWindow(id: "JengaView")
                    } else {
                        dismissWindow(id: "JengaView")
                    }
                    windowModel.isJengaShown = !windowModel.isJengaShown
                }, label: {
                    if windowModel.isJengaShown {
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
#endif
