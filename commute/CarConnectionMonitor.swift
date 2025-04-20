//
//  CarConnectionMonitor.swift
//  commute
//
//  Created by Drew Goldstein on 4/20/25.
//

import CoreBluetooth
import Combine

@MainActor
final class CarConnectionMonitor: NSObject, ObservableObject, CBCentralManagerDelegate {

    @Published private(set) var inCar = false
    private var central: CBCentralManager!

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil,
                                   options: [CBCentralManagerOptionShowPowerAlertKey : false])
    }

    func centralManagerDidUpdateState(_ cm: CBCentralManager) {
        guard cm.state == .poweredOn else { inCar = false; return }

        let peripherals = cm.retrieveConnectedPeripherals(withServices: [])
        inCar = peripherals.contains { p in
            guard let n = p.name?.lowercased() else { return false }
            return n.contains("carplay") || n.contains("my‑car") // tweak names
        }
    }
}
