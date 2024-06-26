//
// Jenga
// Created by: onee on 2024-02-19
//
#if os(visionOS)
import RealityKit
import SwiftUI

/// A modifier that adds gestures and positioning to a view.
struct PlacementGestureModifier: ViewModifier {
    @State private var startPosition: Point3D? = nil
    @State var position: Point3D = .zero
    @Binding var movingBlocks: [BlockPosition?]
    var index: Int
    
    @EnvironmentObject var shareModel: ShareModel

    func body(content: Content) -> some View {
        content
            .position(x: position.x, y: position.y)
            .offset(z: position.z)
            .onChange(of: movingBlocks, { oldValue, newValue in
                if let newPosition = newValue[index], newPosition.position != position {
                    position = newPosition.position
                }
            })
            // Enable people to move the model anywhere in their space.
            .simultaneousGesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .global)
                .targetedToAnyEntity()
                .onChanged { value in
                    if let startPosition {
                        let delta = value.location3D - value.startLocation3D
                        position = startPosition + delta
                        let blockPosition = BlockPosition(position: position, index: index, startLocation: startPosition)
                        movingBlocks[index] = blockPosition
                        shareModel.send(position: blockPosition)
                    } else {
                        startPosition = position
                    }
                }
                .onEnded { _ in
                    let blockPosition = BlockPosition(position: .zero, index: index, startLocation: .zero)
                    movingBlocks[index] = nil
                    shareModel.send(position: blockPosition)
                    startPosition = nil
                }
            )
    }
}
#endif
