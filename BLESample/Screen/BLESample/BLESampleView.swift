//
//  BLESampleView.swift
//  BLESample
//
//

import SwiftUI

struct BLESampleView: View {

    // MARK: - Property Wrappers
    @ObservedObject private var bleSampleViewModel = BLESampleViewModel()

    // MARK: - Body
    var body: some View {
        VStack {
            Text(bleSampleViewModel.weightData)
        } //: VStack
    }
}
