//
// Jenga
// Created by: onee on 2024-02-19
//

import SwiftUI

@main
struct JengaApp: App {
    var body: some Scene {
        WindowGroup {
            MainMenu()
        }
        .defaultSize(.init(width: 500, height: 400))

        WindowGroup(id: "JengaView") {
            JengaView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1000, height: 1000, depth: 1000)
    }
}
