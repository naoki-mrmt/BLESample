//
//  BLESampleView.swift
//  BLESample
//
//

import SwiftUI

struct BLESampleView: View {

    // MARK: - Property Wrappers
    @ObservedObject private var bleSampleViewModel = BLESampleViewModel()
    @ObservedObject private var bluetooth = BLE()

    // MARK: - Body
    var body: some View {
        VStack {
            // TODO: - BLEで取得した値を表示する
            Text("value")
        } //: VStack
    }
}
