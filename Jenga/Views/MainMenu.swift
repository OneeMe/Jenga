//
// Jenga
// Created by: onee on 2024-02-19
//
#if os(visionOS)
import GroupActivities
import RealityKit
import SwiftUI

struct MainMenu: View {
    @EnvironmentObject var windowModel: WindowModel
    @EnvironmentObject var shareModel: ShareModel

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
                if shareModel.enableSharePlay && windowModel.isJengaShown {
                    Button(action: {
                        if shareModel.canStartSharePlay {
                            Task {
                                await shareModel.prepareSession()
                            }
                        } else {
                            shareModel.endSession()
                        }
                    }, label: {
                        if shareModel.canStartSharePlay {
                            Label("Start Share Play", systemImage: "person.2.fill")
                        } else {
                            Label("Stop Share Play", systemImage: "xmark")
                        }
                    })
                }
                Picker("Choose an option", selection: $shareModel.preference) {
                    ForEach(preferenceOptions, id: \.self) { option in
                        Text(option)
                    }
                }
                .pickerStyle(.segmented)
            }
            .frame(width: 360)
            .padding(36)
        }
    }
}

#Preview("Window", windowStyle: .plain) {
    MainMenu()
        .environmentObject(ShareModel())
        .environmentObject(WindowModel())
}
#endif
