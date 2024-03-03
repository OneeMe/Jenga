//
// Jenga
// Created by: onee on 2024-02-19
//

import SwiftUI

class WindowModel: ObservableObject {
    @Published var isJengaShown = false
}

@main
struct JengaApp: App {
    @StateObject var windowModel: WindowModel = .init()
    
    var body: some Scene {
        WindowGroup {
            MainMenu()
        }
        .defaultSize(.init(width: 500, height: 400))
        .environmentObject(windowModel)

        WindowGroup(id: "JengaView") {
            JengaView()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1000, height: 1000, depth: 1000)
        .environmentObject(windowModel)
    }
}
