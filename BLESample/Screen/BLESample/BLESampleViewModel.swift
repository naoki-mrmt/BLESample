//
//  BLESampleViewModel.swift
//  BLESample
//
//

import SwiftUI

class BLESampleViewModel: ObservableObject {

    // MARK: - Property Wrappers
    @Published var ble = BLE()

    // MARK: - Properties
    var weightData: String {
        return ble.weightData
    }
}
