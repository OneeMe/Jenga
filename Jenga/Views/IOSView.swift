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
        //        .task {
        //            await shareModel.prepareSession()
        //        }
        .onChange(of: shareModel.blockPositions) { _, newValue in
            // convert new value to json string
            text = newValue.map { $0?.position.description ?? "null" }.joined(separator: ", ")
        }
    }
}

#Preview {
    IOSView()
}
