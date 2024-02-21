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

        ImmersiveSpace(id: "JengaView") {
            JengaView()
        }
    }
}
