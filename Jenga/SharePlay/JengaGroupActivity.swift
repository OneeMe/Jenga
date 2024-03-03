//
// Jenga
// Created by: onee on 2024-02-25
//

import Foundation
import GroupActivities
import RealityKit
import Spatial

struct JengaGroupActivity: GroupActivity {
    let position: Int
    
    var metadata: GroupActivityMetadata {
        var metaData = GroupActivityMetadata()
        metaData.type = .generic
        metaData.title = "PlayToghter"
        return metaData
    }
}

struct BlockPosition: Codable, Equatable {
    let position: Point3D
    let index: Int
    let startLocation: Point3D
}

class ShareModel: ObservableObject {
    let activity = JengaGroupActivity(position: 0)
    
    var groupSession: GroupSession<JengaGroupActivity>?
    @Published var blockPositions = [BlockPosition?]()
    
    var messenger: GroupSessionMessenger?
    
    init() {
        Task {
            for await session in JengaGroupActivity.sessions() {
                #if os(visionOS)
                guard let systemCoordinator = await session.systemCoordinator else { continue }
                let isLocal = systemCoordinator.localParticipantState.isSpatial
                if isLocal {
                    var configuration = SystemCoordinator.Configuration()
                    configuration.spatialTemplatePreference = .sideBySide
                    configuration.supportsGroupImmersiveSpace = true
                    systemCoordinator.configuration = configuration
                }
                #endif
                
                let messenger = GroupSessionMessenger(session: session)
                
                Task.detached { [weak self] in
                    for await (blockPosition, _) in messenger.messages(of: [BlockPosition?].self) {
                        self?.handlePosition(positions: blockPosition) // custom func to handle the received message. See below.
                    }
                }

                session.join()
                
                self.messenger = messenger
                self.groupSession = session
            }
        }
    }
    
    func handlePosition(positions: [BlockPosition?]) {
        blockPositions = positions
    }
    
    func send(positions: [BlockPosition?]) {
        guard let messenger = messenger else {
            return
        }
        Task {
            do {
                try await messenger.send(positions)
            } catch {
                print("send message error \(error)")
            }
        }
    }
    
    func prepareSession() async {
        // Await the result of the preparation call.
        switch await activity.prepareForActivation() {
        case .activationDisabled:
            print("Activation is disabled")
        case .activationPreferred:
            do {
                _ = try await activity.activate()
            } catch {
                print("Unable to activate the activity: \(error)")
            }
        case .cancelled:
            print("Cancelled")
        default: ()
        }
    }
}
