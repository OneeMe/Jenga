//
// Jenga
// Created by: onee on 2024-02-19
//

import SwiftUI

@main
struct JengaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowStyle(.volumetric)

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }
    }
}
