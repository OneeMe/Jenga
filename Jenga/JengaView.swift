//
// Jenga
// Created by: onee on 2024-02-19
//

import RealityKit
import RealityKitContent
import SwiftUI

struct JengaView: View {
    @StateObject var jengaModel: JengaViewModel = .init()
    @StateObject var shareModel: ShareModel = .init()

    @EnvironmentObject var windowModel: WindowModel

    var body: some View {
        VStack(spacing: 0) {
            // Blocks
            ForEach(Array(jengaModel.blocks.enumerated()), id: \.offset) { index, element in
                RealityView { content in
                    content.add(element)
                }
                .modifier(PlacementGestureModifier(blocksMoving: $jengaModel.blocksMoving, index: index))
                .onChange(of: jengaModel.blocksMoving, initial: false) { value, newValue in
                    let indices = zip(value, newValue).enumerated().filter { $1.0 != $1.1 }.map { $0.offset }
                    if let index = indices.first {
                        updateBlockGravity(block: jengaModel.blocks[index], isBlockMoving: jengaModel.blocksMoving[index])
                    }
                }
                .frame(width: 0, height: 0)
            }
            // tables
            RealityView { content in
                // Table
                let table = setupTable()
                content.add(table)

                // Plate
                content.add(setupPlate())

                // Deposite Area
                let depositArea = setupDepositArea()
                content.add(depositArea)
            }
            .frame(width: 0, height: 0)
        }
        .onAppear {
            jengaModel.blocks.append(contentsOf: createTower(jengaModel))
            jengaModel.blocksMoving.append(contentsOf: Array(repeating: false, count: 18 * 3))
        }
        .onDisappear {
            windowModel.isJengaShown = false
        }
        .task {
            await shareModel.prepareSession()
        }
    }
}

#Preview("Volume", windowStyle: .volumetric) {
    JengaView()
}
