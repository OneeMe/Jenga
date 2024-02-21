//
// Jenga
// Created by: onee on 2024-02-19
//

import RealityKit
import RealityKitContent
import SwiftUI

struct JengaView: View {
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openWindow) private var openWindow
    @Environment(AppState.self) var appState

    @State private var subs: [EventSubscription] = []
    @State private var blocks: [Entity] = []
    @State private var blocksMoving: [Bool] = []
    @State private var isEndGame: Bool = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @StateObject var model: JengaViewModel = .init()

    var body: some View {
        VStack(spacing: 0) {
            RealityView { content in
                // Table
                let table = setupTable()
                content.add(table)

                // Plate
                content.add(setupPlate())

                // Deposite Area
                let depositArea = setupDepositArea()
                content.add(depositArea)

                // Events
                let eventTable = content.subscribe(to: CollisionEvents.Began.self, on: table) { _ in
                    isEndGame = true
                }
                let eventDepositArea = content.subscribe(to: CollisionEvents.Began.self, on: depositArea) { event in
                    event.entityB.removeFromParent()
                    model.score += 1
                    if model.score == 17*2 {
                        isEndGame = true
                    }
                }
                Task {
                    subs.append(eventTable)
                    subs.append(eventDepositArea)
                }
            }
            .onAppear {
                blocks.append(contentsOf: createTower(model))
                blocksMoving.append(contentsOf: Array(repeating: false, count: 18*3))
            }
            .onDisappear {}
            .onChange(of: isEndGame, initial: false) {
            }
            .onReceive(timer) { _ in
                model.time += 1
            }
            .frame(width: 0, height: 0)

            // Blocks
            ForEach(Array(blocks.enumerated()), id: \.offset) { index, element in
                RealityView { content in
                    content.add(element)
                }
                .modifier(PlacementGestureModifier(blocksMoving: $blocksMoving, index: index))
                .onChange(of: blocksMoving, initial: false) { value, newValue in
                    let indices = zip(value, newValue).enumerated().filter { $1.0 != $1.1 }.map { $0.offset }
                    if let index = indices.first {
                        updateBlockGravity(block: blocks[index], isBlockMoving: blocksMoving[index])
                    }
                }
                .frame(width: 0, height: 0)
            }
        }
        .gesture(DragGesture(minimumDistance: 1)
            .targetedToAnyEntity()
            .onChanged { value in
                guard appState.phase == .buildingTrack || appState.phase == .placingStartPiece
                        || appState.phase == .draggingStartPiece else { return }
                handleDrag(value, ended: false)
            }
            .onEnded { value in
                guard appState.phase == .buildingTrack || appState.phase == .placingStartPiece
                        || appState.phase == .draggingStartPiece else { return }
                handleDrag(value, ended: true)
            })
    }
}

@MainActor func createTower(_ model: JengaViewModel) -> [ModelEntity] {
    var tower: [ModelEntity] = []
    let x: Float = 0
    let y: Float = 1.02
    let z: Float = -2
    for i in 1...18 {
        let yi = y+(Float(i)*0.015)
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

#Preview {
    JengaView()
        .previewLayout(.sizeThatFits)
}
