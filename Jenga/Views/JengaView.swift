//
// Jenga
// Created by: onee on 2024-02-19
//
#if os(visionOS)
import RealityKit
import RealityKitContent
import SwiftUI

struct JengaView: View {
    @StateObject var jengaModel: JengaViewModel = .init()
    @EnvironmentObject var shareModel: ShareModel
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
        // get position from share play
        .onChange(of: shareModel.positionsToUpdate, { oldValue, newValue in
            if newValue.isEmpty {
                return
            }
            for position in newValue {
                if position.position == .zero {
                    jengaModel.movingBlockPositions[position.index] = nil
                } else {
                    jengaModel.movingBlockPositions[position.index] = position
                }
            }
            shareModel.positionsToUpdate.removeAll()
        })
        .onAppear {
            jengaModel.blocks.append(contentsOf: createTower(jengaModel))
            jengaModel.movingBlockPositions.append(contentsOf: Array(repeating: nil, count: 18 * 3))
        }
        .onDisappear {
            windowModel.isJengaShown = false
            shareModel.endSession()
        }
        .environmentObject(shareModel)
    }
}

#Preview("Volume", windowStyle: .volumetric) {
    JengaView()
}
#endif
