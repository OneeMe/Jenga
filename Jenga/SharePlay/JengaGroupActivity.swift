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

struct BlockPosition: Codable {
    let positions: [Pose3D]
}

class ShareModel: ObservableObject {
    let activity = JengaGroupActivity(position: 0)
    
    var groupSession: GroupSession<JengaGroupActivity>?
    @Published var blockPositions = [Pose3D]()
    
    var messenger: GroupSessionMessenger?
    
    init() {
        Task {
            for await session in JengaGroupActivity.sessions() {
                guard let systemCoordinator = await session.systemCoordinator else { continue }
                
                // TODO: find out what is the local mean
                let isLocal = systemCoordinator.localParticipantState.isSpatial
                
                var configuration = SystemCoordinator.Configuration()
                configuration.spatialTemplatePreference = .sideBySide
                configuration.supportsGroupImmersiveSpace = true
                systemCoordinator.configuration = configuration
                
                let messenger = GroupSessionMessenger(session: session)
                
                Task.detached { [weak self] in
                    for await (blockPosition, _)  in messenger.messages(of: BlockPosition.self) {
                        self?.handlePosition(position: blockPosition ) // custom func to handle the received message. See below.
                    }
                }

                session.join()
                
                self.messenger = messenger
                self.groupSession = session
            }
        }
    }
    
    func handlePosition(position: BlockPosition) {
        self.blockPositions = position.positions
    }
    
    func send(positions: [Pose3D]) {
        Task {
            do {
                try await self.messenger?.send(BlockPosition(positions: positions))
            } catch {
                print("send message error \(error)")
            }
        }
    }
    
    func prepareSession() async {
        // Await the result of the preparation call.
        switch await activity.prepareForActivation() {
        case .activationDisabled:
            break
        case .activationPreferred:
            do {
                _ = try await activity.activate()
            } catch {
                print("Unable to activate the activity: \(error)")
            }
        case .cancelled:
            break
        default: ()
        }
    }
}
