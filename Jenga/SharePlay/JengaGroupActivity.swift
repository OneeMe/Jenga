//
// Jenga
// Created by: onee on 2024-02-25
//

import Combine
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
        metaData.sceneAssociationBehavior = .content(JengaGroupActivity.activityIdentifier)
        return metaData
    }
    
    static var activityIdentifier: String {
        "zone.xreality.jenga.play.together"
    }
}

struct BlockPosition: Codable, Equatable {
    let position: Point3D
    let index: Int
    let startLocation: Point3D
}

@MainActor
class ShareModel: ObservableObject {
    let activity = JengaGroupActivity(position: 0)
    
    var groupSession: GroupSession<JengaGroupActivity>?
    private let groupStateObserver = GroupStateObserver()
    private var cancellable: AnyCancellable?
    @Published var positionsToUpdate = [BlockPosition]()
    @Published var canStartSharePlay: Bool = true
    @Published var enableSharePlay: Bool = true
    
    var messenger: GroupSessionMessenger?
    private var tasks = Set<Task<Void, Never>>()
    
    init() {
        cancellable = groupStateObserver.$isEligibleForGroupSession.sink { [weak self] value in
            self?.enableSharePlay = value
        }
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
                
                let task = Task.detached { [weak self] in
                    for await (blockPosition, _) in messenger.messages(of: BlockPosition.self) {
                        await self?.handlePosition(position: blockPosition) // custom func to handle the received message. See below.
                    }
                }
                tasks.insert(task)

                session.join()
                
                self.messenger = messenger
                self.groupSession = session
                canStartSharePlay = false
            }
        }
    }
    
    func handlePosition(position: BlockPosition) {
        positionsToUpdate.append(position)
    }
    
    func send(position: BlockPosition) {
        guard let messenger = messenger else {
            return
        }
        let task = Task {
            do {
                try await messenger.send(position)
            } catch {
                print("send message error \(error)")
            }
        }
        tasks.insert(task)
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
    
    func endSession() {
        tasks.forEach { task in
            task.cancel()
        }
        tasks.removeAll()
        messenger = nil
        groupSession?.end()
        groupSession = nil
        positionsToUpdate.removeAll()
        canStartSharePlay = true
    }
}
