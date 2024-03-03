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
                .modifier(PlacementGestureModifier(movingBlocks: $jengaModel.movingBlockPositions, index: index))
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
        .onChange(of: shareModel.blockPositions, { oldValue, newValue in
            jengaModel.movingBlockPositions = newValue
        })
        .onAppear {
            jengaModel.blocks.append(contentsOf: createTower(jengaModel))
            jengaModel.movingBlockPositions.append(contentsOf: Array(repeating: nil, count: 18 * 3))
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
