//
// Jenga
// Created by: onee on 2024-02-19
//

import RealityKit
import SwiftUI

/// A modifier that adds gestures and positioning to a view.
struct PlacementGestureModifier: ViewModifier {
    @State private var startPosition: Point3D? = nil
    @State var position: Point3D = .zero
    @Binding var blocksMoving: [Bool]
    var index: Int

    func body(content: Content) -> some View {
        content
            .position(x: position.x, y: position.y)
            .offset(z: position.z)

            // Enable people to move the model anywhere in their space.
            .simultaneousGesture(DragGesture(minimumDistance: 0.1, coordinateSpace: .global)
                .onChanged { value in
                    blocksMoving[index] = true
                    if let startPosition {
                        let delta = value.location3D - value.startLocation3D
                        position = startPosition + delta
                    } else {
                        startPosition = position
                    }
                }
                .onEnded { _ in
                    blocksMoving[index] = false
                    startPosition = nil
                }
            )
    }
}
