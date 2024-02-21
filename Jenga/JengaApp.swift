//
// Jenga
// Created by: onee on 2024-02-19
//

import SwiftUI

@main
@MainActor
struct JengaApp: App {
    @State var appState: AppState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainMenu()
        }
        .environment(appState)
        .defaultSize(.init(width: 500, height: 400))

        ImmersiveSpace(id: "JengaView") {
            JengaView()
        }.environment(appState)
    }
}
