//
// Jenga-iOS
// Created by: onee on 2024-02-25
//

import SwiftUI

struct IOSView: View {
    @EnvironmentObject var shareModel: ShareModel
    @State var text: String = ""
    @State var values: [BlockPosition] = []

    var body: some View {
        VStack {
            Button("Start SharePlay") {
                Task {
                    await shareModel.prepareSession()
                }
            }
            Button("Callback") {
                // get first of values
                if let first = values.first {
                    shareModel.send(position: first)
                    values.removeFirst()
                }
            }
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Jenga Positions are: \n\(text)")
        }
        .padding()
        .onChange(of: shareModel.positionsToUpdate) { _, newValue in
            if newValue.isEmpty {
                return
            }
            // convert new value to json string
            text = newValue.map { "index: \($0.index), position: \($0.position.description)" }.joined(separator: "\n\n")
            values.append(contentsOf: newValue)
            shareModel.positionsToUpdate.removeAll()
        }
    }
}

#Preview {
    IOSView()
        .previewDevice(PreviewDevice(rawValue: "iPhone 15"))
        .environmentObject(ShareModel())
}
