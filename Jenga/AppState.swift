//
// Jenga
// Created by: onee on 2024-02-21
//

import ARKit
import AVKit
import Combine
import Foundation
import OSLog
import RealityKit
import SwiftUI
import UIKit

/// Application logger for reporting errors, warnings, and useful information.
let logger = Logger(subsystem: "zone.xreality.Jenga", category: "general")

enum AppPhase {
    case startingUp
    case gaming
    case end
}

/// An object that maintains app-wide state.
@Observable
@MainActor
public class AppState {
    var phase: AppPhase = .startingUp
            
    /// The app's AR session.
    var session: ARKitSession = .init()
        
    /// The app uses this to retrieve the location and orientation of the device.
    var worldInfo = WorldTrackingProvider()
        
    var meshEntities = [UUID: ModelEntity]()
    var startAttachment: ViewAttachmentEntity?
    var editAttachment: ViewAttachmentEntity?
    var isImmersiveViewShown = false
        
    /// A Boolean that indicates whether the ride is currently running.
    var isRideRunning = false
        
    /// The time the current ride run started or 0 if the ride isn't running.
    var rideStartTime: TimeInterval = 0
        
    var rideDuration: TimeInterval = 0.0
        
    /// Stores the track piece that's currently selected and in edit mode. Only one track can be in edit mode at a time, but any number
    /// of additional pieces can be selected and any edit actions apply to them all. There doesn't have to be a  piece in edit mode, but
    /// if no piece is in edit mode, there should be no additional selected track pieces.
    var trackPieceBeingEdited: Entity?

    var isVolumeMuted = false {
        didSet {
            SoundEffect.isMuted = isVolumeMuted
            if isVolumeMuted {
                [buildMusic, menuMusic, rideMusic].forEach { $0.volume = 0 }
                SoundEffect.stopLoops()
            } else {
                [buildMusic, menuMusic, rideMusic].filter { $0.isPlaying }.forEach {
                    $0.volume = 1.0
                }
                    
                switch phase {
                case .buildingTrack:
                    ()
                case .rideRunning:
                    ()
                default:
                    ()
                }
            }
        }
    }
        
    let connectableQuery = EntityQuery(where: .has(ConnectableComponent.self))
        
    /// Stores any additional selected pieces. Any action taken to the piece being edited applies to these as well.
    var additionalSelectedTrackPieces = [Entity]()
        
    init() {
        root.name = "Root"
        Task.detached(priority: .high) {
            do {
                try await self.session.run([self.worldInfo])
            } catch {
                logger.error("Error running World Tracking Provider: \(error.localizedDescription)")
            }
        }
    }
        
    // Background music.
    public var buildMusic = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "swiftSplash_BuildMode", withExtension: "wav")!)
    public var menuMusic = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "swiftSplash_Menu", withExtension: "wav")!)
    public var rideMusic = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "swiftSplash_RideMode", withExtension: "m4a")!)
}
