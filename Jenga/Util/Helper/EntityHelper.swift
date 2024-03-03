//
// Jenga
// Created by: onee on 2024-02-21
//

import ARKit
import Foundation
import RealityKit
import SwiftUI

private let blockSize: SIMD3<Float> = [0.075, 0.015, 0.025]

private let yBase: Float = -0.35

@MainActor func createTower(_ model: JengaViewModel) -> [Entity] {
    var tower: [Entity] = []
    let x: Float = 0
    let y: Float = yBase + 0.02
    let z: Float = 0
    for i in 1...18 {
        let yi = y+(Float(i) * 0.015)
        let colorL: UIColor = getBlocColor(red: Int.random(in: 200...230))
        let colorM: UIColor = getBlocColor(red: Int.random(in: 200...230))
        let colorR: UIColor = getBlocColor(red: Int.random(in: 200...230))
        if i % 2 == 0 {
            tower.append(setupBlock(position: SIMD3(x: x, y: yi, z: z+0.025), color: colorL, isOddFloor: false))
            tower.append(setupBlock(position: SIMD3(x: x, y: yi, z: z), color: colorM, isOddFloor: false))
            tower.append(setupBlock(position: SIMD3(x: x, y: yi, z: z - 0.025), color: colorR, isOddFloor: false))
        } else {
            tower.append(setupBlock(position: SIMD3(x: x - 0.025, y: yi, z: z), color: colorR, isOddFloor: true))
            tower.append(setupBlock(position: SIMD3(x: x, y: yi, z: z), color: colorM, isOddFloor: true))
            tower.append(setupBlock(position: SIMD3(x: x+0.025, y: yi, z: z), color: colorL, isOddFloor: true))
        }
    }
    return tower
}

func convertDouble4x4ToFloat4x4(_ matrix: simd_double4x4) -> float4x4 {
    return float4x4(
        float4(Float(matrix[0, 0]), Float(matrix[0, 1]), Float(matrix[0, 2]), Float(matrix[0, 3])),
        float4(Float(matrix[1, 0]), Float(matrix[1, 1]), Float(matrix[1, 2]), Float(matrix[1, 3])),
        float4(Float(matrix[2, 0]), Float(matrix[2, 1]), Float(matrix[2, 2]), Float(matrix[2, 3])),
        float4(Float(matrix[3, 0]), Float(matrix[3, 1]), Float(matrix[3, 2]), Float(matrix[3, 3]))
    )
}

private func getBlocColor(red: Int) -> UIColor {
    var green = 0
    var blue = 0
    switch red {
    case 200..<210:
        green = red - Int.random(in: 30..<35)
        blue = green - Int.random(in: 40..<46)
    case 210..<217:
        green = red - Int.random(in: 25..<30)
        blue = green - Int.random(in: 34..<40)
    case 217..<224:
        green = red - Int.random(in: 20..<25)
        blue = green - Int.random(in: 28..<34)
    default:
        green = red - Int.random(in: 15..<20)
        blue = green - Int.random(in: 22..<28)
    }
    return UIColor(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: 1)
}

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
    block.components.set(BlockComponent())
    block.collision = CollisionComponent(shapes: [.generateBox(width: width, height: height, depth: depth)], mode: .colliding)
    block.physicsBody = PhysicsBodyComponent(massProperties: PhysicsMassProperties(mass: 0.1), mode: .dynamic)
    block.physicsBody?.isAffectedByGravity = true
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
    table.setPosition(SIMD3(x: 0, y: yBase, z: 0), relativeTo: nil)
    return table
}

func setupPlate() -> ModelEntity {
    let plate = ModelEntity(
        mesh: MeshResource.generateBox(width: 0.2, height: 0.01, depth: 0.2, cornerRadius: 10),
        materials: [SimpleMaterial(color: .systemGray, isMetallic: false)]
    )
    plate.collision = CollisionComponent(shapes: [.generateBox(width: 0.2, height: 0.01, depth: 0.2)], mode: .colliding)
    plate.physicsBody = PhysicsBodyComponent(mode: .static)
    plate.setPosition(SIMD3(x: 0, y: yBase + 0.02, z: 0), relativeTo: nil)
    return plate
}

func setupDepositArea() -> ModelEntity {
    var material = SimpleMaterial()
    material.color = SimpleMaterial.BaseColor(tint: UIColor(red: 1, green: 0, blue: 0, alpha: 0))

    let depositArea = ModelEntity(
        mesh: MeshResource.generatePlane(width: 0.5, depth: 0.5, cornerRadius: 50),
        materials: [material]
    )
    depositArea.collision = CollisionComponent(shapes: [.generateBox(width: 0.5, height: 0.01, depth: 0.5)], mode: .trigger, filter: .sensor)
    depositArea.setPosition(SIMD3(x: 0, y: yBase + 0.02, z: 0), relativeTo: nil)
    return depositArea
}

func updateBlockGravity(block: Entity, isBlockMoving: Bool) {
    let targetMode = isBlockMoving ? PhysicsBodyMode.kinematic : PhysicsBodyMode.dynamic
    guard let physics =  block.components[PhysicsBodyComponent.self], physics.mode != targetMode else {
        return
    }
    block.components.remove(PhysicsBodyComponent.self)
    block.components.set(
        PhysicsBodyComponent(
            massProperties: PhysicsMassProperties(mass: 0.1),
            material: .default,
            mode: targetMode
        )
    )
}
