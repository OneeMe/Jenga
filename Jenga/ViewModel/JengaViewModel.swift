//
// Jenga
// Created by: onee on 2024-02-21
//

import ARKit
import RealityKit
import SwiftUI

@MainActor class JengaViewModel: ObservableObject {
    @Published var score: Int = 0
    @Published var time: UInt16 = 0
    
    let blocks = [String: Entity]()
    
    
}
