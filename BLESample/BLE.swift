//
//  BLE.swift
//  BLESample
//
//

import SwiftUI
import CoreBluetooth

final class BLE: NSObject, ObservableObject {
    // MARK: - Property Wrappers
    @Published var weightData: String = ""

    // MARK: - Properties
    private let serviceUUIDString = "d746652e-9557-11ec-b909-0242ac120002"
    private let characteristicUUIDString = "d746688a-9557-11ec-b909-0242ac120002"

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral!
    private var serviceUUID : CBUUID!
    private var characteristic: CBCharacteristic?
    private var charcteristicUUIDs: [CBUUID]!

    // MARK: - Initialize
    override init() {
        super.init()
        setup()
    }
    
    private func setup() {
        print("setup...\n")
        centralManager = CBCentralManager()
        centralManager.delegate = self as CBCentralManagerDelegate
        serviceUUID = CBUUID(string: serviceUUIDString)
        charcteristicUUIDs = [CBUUID(string: characteristicUUIDString)]
   }
}

// MARK: - CBCentralManagerDelegate
extension BLE: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case CBManagerState.poweredOn:
            let services: [CBUUID] = [serviceUUID]
            centralManager?.scanForPeripherals(withServices: services, options: nil)
        default:
            break
        }
    }
    
    /// ペリフェラルを発見すると呼ばれる
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        centralManager?.stopScan()
        central.connect(peripheral, options: nil)
    }
    
    /// 接続されると呼ばれる
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
    
    /// 切断されると呼ばれる
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if error != nil {
            print(error.debugDescription)
            setup()
            return
        }
    }
}

// MARK: - CBPeripheralDelegate
extension BLE: CBPeripheralDelegate {
    
    /// サービス発見時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print(error.debugDescription)
            return
        }
        
        //キャリアクタリスティク探索開始
        if let service = peripheral.services?.first {
            print("Searching characteristic...\n")
            peripheral.discoverCharacteristics(charcteristicUUIDs, for: service)
        }
    }
    
    /// キャリアクタリスティク発見時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil { return }
        print("service.characteristics.count: \(service.characteristics!.count)\n")
        for characteristics in service.characteristics! {
            if(characteristics.uuid == CBUUID(string: characteristicUUIDString)) {
                self.characteristic = characteristics
            }
        }
        if(self.characteristic != nil) { startReciving() }
    }

    /// データ送信時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print(#function)
        if error != nil { return }
    }

    /// データ更新時に呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil { return }
        updateWithData(data: characteristic.value!)
    }
    
    private func updateWithData(data : Data) {
        if let dataString = String(data: data, encoding: String.Encoding.utf8) {
            weightData = dataString
            debugPrint(weightData)
        }
    }

    private func startReciving() {
        guard let characteristic = characteristic else { return }
        peripheral.setNotifyValue(true, for: characteristic)
        print("Start monitoring the message from M5.\n\n")
    }
}
