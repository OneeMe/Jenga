//
// Jenga
// Created by: onee on 2024-02-21
//

import Foundation
import RealityKit
import ARKit
import SwiftUI

private let blockSize: SIMD3<Float> = [0.075, 0.015, 0.025]

func setupBlock(position: SIMD3<Float>, color: UIColor, isOddFloor: Bool) -> ModelEntity {
    let width = isOddFloor ? blockSize.z : blockSize.x
    let height = blockSize.y
    let depth = isOddFloor ? blockSize.x : blockSize.z
    var material = SimpleMaterial()
    material.color = SimpleMaterial.BaseColor(tint: color)
    let block = ModelEntity(
        mesh: MeshResource.generateBox(width: width, height: height, depth: depth),
        materials: [material]
    )
    block.components.set(InputTargetComponent())
    block.collision = CollisionComponent(shapes: [.generateBox(width: width, height: height, depth: depth)], mode: .colliding)
    block.physicsBody = PhysicsBodyComponent(massProperties: PhysicsMassProperties(mass: 0.1), mode: .dynamic)
    block.setPosition(position, relativeTo: nil)
    return block
}

func setupTable() -> ModelEntity {
    var material = SimpleMaterial()
    material.color = SimpleMaterial.BaseColor(tint: UIColor(red: 0, green: 0, blue: 0, alpha: 0))

    let table = ModelEntity(
        mesh: MeshResource.generateBox(width: 2, height: 0.01, depth: 2),
        materials: [material]
    )
    table.collision = CollisionComponent(shapes: [.generateBox(width: 2, height: 0.01, depth: 2)], mode: .trigger, filter: .sensor)
    table.setPosition(SIMD3(x: 0, y: 1, z: -2), relativeTo: nil)
    return table
}

func setupPlate() -> ModelEntity {
    let plate = ModelEntity(
        mesh: MeshResource.generateBox(width: 0.2, height: 0.01, depth: 0.2, cornerRadius: 10),
        materials: [SimpleMaterial(color: .systemGray, isMetallic: false)]
    )
    plate.collision = CollisionComponent(shapes: [.generateBox(width: 0.2, height: 0.01, depth: 0.2)], mode: .colliding)
    plate.physicsBody = PhysicsBodyComponent(mode: .static)
    plate.setPosition(SIMD3(x: 0, y: 1.02, z: -2), relativeTo: nil)
    return plate
}

func setupDepositArea() -> ModelEntity {
    var material = SimpleMaterial()
    material.color = SimpleMaterial.BaseColor(tint: UIColor(red: 1, green: 0, blue: 0, alpha: 1))

    let depositArea = ModelEntity(
        mesh: MeshResource.generatePlane(width: 0.5, depth: 0.5, cornerRadius: 50),
        materials: [material]
    )
    depositArea.collision = CollisionComponent(shapes: [.generateBox(width: 0.5, height: 0.01, depth: 0.5)], mode: .trigger, filter: .sensor)
    depositArea.setPosition(SIMD3(x: 1, y: 1.02, z: -2), relativeTo: nil)
    return depositArea
}

func updateBlockGravity(block: Entity, isBlockMoving: Bool) {
    block.components.remove(PhysicsBodyComponent.self)
    block.components.set(
        PhysicsBodyComponent(
            massProperties: PhysicsMassProperties(mass: 0.1),
            material: .default,
            mode: isBlockMoving ? .kinematic : .dynamic
        )
    )
}
