//
// Jenga
// Created by: onee on 2024-02-25
//

import Combine
import Foundation
import GroupActivities
import RealityKit
import Spatial
import CoreTransferable

struct JengaGroupActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metaData = GroupActivityMetadata()
        metaData.type = .generic
        metaData.title = "PlayToghter"
        metaData.sceneAssociationBehavior = .content(JengaGroupActivity.activityIdentifier)
        return metaData
    }
}

struct JengaTransferable : Transferable {
    static var transferRepresentation: some TransferRepresentation {
        // Specify the associated SharePlay activity.
        GroupActivityTransferRepresentation { _ in
            JengaGroupActivity()
        }
    }
}

struct BlockPosition: Codable, Equatable {
    let position: Point3D
    let index: Int
    let startLocation: Point3D
}

let preferenceOptions = [
    "SideBySide",
    "None",
    "Conversational"
]

@MainActor
class ShareModel: ObservableObject {
    let activity = JengaGroupActivity()
    
    var groupSession: GroupSession<JengaGroupActivity>?
    #if os(visionOS)
        var systemCoordinatorConfig: SystemCoordinator.Configuration?
    #endif
    private let groupStateObserver = GroupStateObserver()
    private var subs: Set<AnyCancellable> = []
    @Published var positionsToUpdate = [BlockPosition]()
    @Published var canStartSharePlay: Bool = true
    @Published var enableSharePlay: Bool = true
    @Published var preference: String = "SideBySide"
    
    var messenger: GroupSessionMessenger?
    private var tasks = Set<Task<Void, Never>>()
    
    init() {
        print("hey, we have created the share model")
        groupStateObserver.$isEligibleForGroupSession.sink { [weak self] value in
            self?.enableSharePlay = value
        }.store(in: &subs)
        #if os(visionOS)
            $preference.sink { [weak self] newValue in
                self?.updateTemplateReference(newValue: newValue)
            }.store(in: &subs)
        #endif
        
        Task {
            for await session in JengaGroupActivity.sessions() {
                #if os(visionOS)
                    guard let systemCoordinator = await session.systemCoordinator else { continue }
                    let isSpatial = systemCoordinator.localParticipantState.isSpatial
                    if isSpatial {
                        var configuration = SystemCoordinator.Configuration()
                        switch preference {
                        case "SideBySide":
                            configuration.spatialTemplatePreference = .sideBySide
                        case "None":
                            configuration.spatialTemplatePreference = .none
                        case "Conversational":
                            configuration.spatialTemplatePreference = .conversational
                        default:
                            print("not right")
                        }
                        configuration.supportsGroupImmersiveSpace = true
                        systemCoordinator.configuration = configuration
                        systemCoordinatorConfig = configuration
                    }
                #endif
                
                
                let messenger = GroupSessionMessenger(session: session)
                print("hey, we have created the messenger")
                
                let task = Task.detached { [weak self] in
                    for await (blockPosition, _) in messenger.messages(of: BlockPosition.self) {
                        print("hey, we have received the message")
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

    #if os(visionOS)
        func updateTemplateReference(newValue: String) {
            switch newValue {
            case "SideBySide":
                systemCoordinatorConfig?.spatialTemplatePreference = .sideBySide
            case "None":
                systemCoordinatorConfig?.spatialTemplatePreference = .none
            case "Conversational":
                systemCoordinatorConfig?.spatialTemplatePreference = .conversational
            default:
                // do nothing
                print("not right")
            }
        }
    #endif
    
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
                print("Activation is preferred")
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
        subs.removeAll()
    }
}
