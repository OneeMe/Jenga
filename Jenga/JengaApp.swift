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
    @StateObject var shareModel: ShareModel = .init()

    var body: some Scene {
        #if os(iOS)
        WindowGroup {
            IOSView()
                .handlesExternalEvents(
                    preferring: [JengaGroupActivity.activityIdentifier],
                    allowing: [JengaGroupActivity.activityIdentifier]
                )
        }
        .environmentObject(shareModel)
        #endif
        #if os(visionOS)
        WindowGroup {
            MainMenu()
        }
        .defaultSize(.init(width: 500, height: 400))
        .environmentObject(windowModel)
        .environmentObject(shareModel)

        WindowGroup(id: "JengaView") {
            JengaView()
                .handlesExternalEvents(
                    preferring: [JengaGroupActivity.activityIdentifier],
                    allowing: [JengaGroupActivity.activityIdentifier]
                )
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1000, height: 1000, depth: 1000)
        .environmentObject(windowModel)
        .environmentObject(shareModel)
        #endif
    }
}
