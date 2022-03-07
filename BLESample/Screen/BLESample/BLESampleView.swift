//
//  BLESampleView.swift
//  BLESample
//
//

import SwiftUI

struct BLESampleView: View {

    // MARK: - Property Wrappers
    @ObservedObject var ble = BluetoothManager()

    // MARK: - Body
    var body: some View {
        VStack {
            Text(ble.weightData)
        } //: VStack
    }
}
