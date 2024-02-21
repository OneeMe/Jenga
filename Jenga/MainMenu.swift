//
// Jenga
// Created by: onee on 2024-02-19
//

import RealityKit
import RealityKitContent
import SwiftUI

struct MainMenu: View {
    @State private var immersiveSpaceIsShown = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    var body: some View {
        VStack {
            VStack(spacing: 12) {
                Text("Jenga!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Button(action: {
                    if !immersiveSpaceIsShown {
                        Task {
                            switch await openImmersiveSpace(id: "JengaView") {
                            case .opened:
                                immersiveSpaceIsShown = true
                            case .error, .userCancelled:
                                fallthrough
                            @unknown default:
                                immersiveSpaceIsShown = false
                            }
                        }
                    }
                }, label: {
                    if immersiveSpaceIsShown {
                        Label("Reset", systemImage: "play.fill")
                    } else {
                        Label("Start", systemImage: "play.fill")
                    }
                })
                if immersiveSpaceIsShown {
                    Button(action: {
                        Task {
                            await dismissImmersiveSpace()
                            immersiveSpaceIsShown = false
                        }
                    }, label: {
                        Label("Quit", systemImage: "xmark.circle.fill")
                    })
                }
            }
            .frame(width: 360)
            .padding(36)
        }
    }
}

#Preview() {
    MainMenu()
}
