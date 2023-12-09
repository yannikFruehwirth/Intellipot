//
//  AppState.swift
//  Prototyp_IntelliPot_v.0.9
//
//  Created by Yannik Fruehwirth on 10.10.23.
//

import Foundation

class AppState: ObservableObject {
    @Published var isCameraPresented: Bool = false
    @Published var photoCount: Int = 0
    @Published var detectedWords1: [String] = []
    @Published var detectedWords2: [String] = []
    @Published var detectedMachineNumber : String = "error"
    @Published var detectedCableNumber : String = "error"
    @Published var parsedCSVData: [[String]] = []
    @Published var currentPhotoSession: String = "machine"
    @Published var amountOfConnectionsInDb: Int = 0
}

