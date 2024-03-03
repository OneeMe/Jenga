//
// Jenga-iOS
// Created by: onee on 2024-02-25
//

import SwiftUI

struct IOSView: View {
    @StateObject var shareModel: ShareModel = .init()
    @State var text: String = ""

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!\n\(text)")
        }
        .padding()
        
        .onChange(of: shareModel.positionsToUpdate) { _, newValue in
            if newValue.isEmpty {
                return
            }
            // convert new value to json string
            text = newValue.map { "index: \($0.index), position: \($0.position.description)" }.joined(separator: "\n\n")
            shareModel.positionsToUpdate.removeAll()
        }
    }
}

#Preview {
    IOSView()
}
