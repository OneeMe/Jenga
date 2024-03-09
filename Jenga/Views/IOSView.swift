//
// Jenga-iOS
// Created by: onee on 2024-02-25
//

import SwiftUI

struct IOSView: View {
    @StateObject var shareModel: ShareModel = .init()
    @State var text: String = ""
    @State var values: [[BlockPosition]] = []

    var body: some View {
        VStack {
            Button("Dump") {
                // print values as json string
                do {
                    let data = try JSONSerialization.data(withJSONObject: values, options: .prettyPrinted)
                    let jsonString = String(data: data, encoding: .utf8)
                    print(jsonString ?? "nil")
                } catch {
                    print("error")
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
            values.append(newValue)
            shareModel.positionsToUpdate.removeAll()
        }
    }
}

#Preview {
    IOSView()
        .previewDevice(PreviewDevice(rawValue: "iPhone 15"))
}
