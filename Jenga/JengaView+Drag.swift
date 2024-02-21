//
// Jenga
// Created by: onee on 2024-02-21
//

import Foundation

/// When someone is dragging one or more track pieces using a gesture, this is `true`.
var isDragging = false

extension JengaView {
    /// The logic to handle the `.onChanged` event from a rotation gesture.
    @MainActor
    func handleDrag(_ value: EntityTargetValue<DragGesture.Value>, ended: Bool = false) {
        defer {
            if ended {
                handleDragEnd(value)
                isDragging = false
            }
        }

        appState.editAttachment?.removeFromParent()
        
        lastTouchDownTime = Date.timeIntervalSinceReferenceDate
        // Gestures might hit a child entity. This traverses up to the connectable ancestor, if needed.
        let tappedEntity = value.entity
        if let entity = tappedEntity.connectableAncestor {
            if appState.phase == .placingStartPiece {
                appState.startedDraggingStartPiece()
            }
            
            // Disallow dragging the end-of-track marker.
            if entity.name == SwiftSplashTrackPieces.placePieceMarkerName {
                return
            }
            draggedEntity = entity
            isDragging = true
            
            if appState.trackPieceBeingEdited != entity && !appState.additionalSelectedTrackPieces.contains(entity) {
                selectDraggedPiece(draggedEntity: draggedEntity)
            }
            
            if appState.trackPieceBeingEdited != nil && entity != appState.trackPieceBeingEdited
                && !appState.additionalSelectedTrackPieces.contains(entity)
            {
                appState.clearSelection(keepPrimary: false)
            }
            
            var allDragged = handleEntityStateUpdates(for: entity)
            
            draggedPiece = entity
            
            let translation3D = value.convert(value.gestureValue.translation3D, from: .local, to: .scene)
            
            let offset = SIMD3<Float>(x: Float(translation3D.x),
                                      y: Float(translation3D.y),
                                      z: Float(translation3D.z))
            
            updateDraggedPositions(&allDragged, offset: offset)
            
            // Handle snapping.
            if ended {
                let snapInfo = DragSnapInfo(entity: entity,
                                            otherSelectedEntities: Array(allDragged))
                guard let others = entity.scene?.performQuery(Self.connectableQuery) else {
                    logger.info("No entities to snap to, returning.")
                    isDragging = false
                    return
                }
                handleSnap(snapInfo,
                           allConnectableEntities: others)
                isDragging = false
            }
            if appState.phase != .draggingStartPiece {
                updateDraggedPieceConnections(entity: entity)
            }
        }
    }
    
    /// At the end of the drag, this function resets the dragged entities' state components.
    @MainActor
    func handleDragEnd(_ value: EntityTargetValue<DragGesture.Value>) {
        defer {
            isDragging = false
            draggedEntity = nil
            dragStartTime = nil
            appState.updateConnections()
            appState.updateSelection()
        }
        
        if appState.phase == .draggingStartPiece {
            openWindow(id: "SwiftSplash")
            appState.finishedDraggingStartPiece()
        }
        
        func resetPiece(_ entity: Entity) {
            if var state = entity.connectableStateComponent {
                state.nextPiece = nil
                state.previousPiece = nil
                state.lastMoved = NSDate.timeIntervalSinceReferenceDate
                state.dragOffset = SIMD3<Float>.zero
                state.dragStart = nil
                entity.connectableStateComponent = state
                appState.findClosestPieces(for: entity)
                SoundEffect.placePiece.play(on: entity)
                if entity == appState.trackPieceBeingEdited {
                    if let attachmentPoint = appState.trackPieceBeingEdited?.uiAnchor,
                       let editAttachment = appState.editAttachment
                    {
                        attachmentPoint.addChild(editAttachment)
                    }
                }
            }
        }
        if let dragged = appState.trackPieceBeingEdited {
            resetPiece(dragged)
        }
        for dragged in appState.additionalSelectedTrackPieces {
            resetPiece(dragged)
        }
        
        if let attachmentPoint = appState.trackPieceBeingEdited?.uiAnchor,
           let editAttachment = appState.editAttachment
        {
            attachmentPoint.addChild(editAttachment)
        }
    }
}
