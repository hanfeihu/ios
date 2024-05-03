//
//  BLEUtils.swift
//  LightControl
//
//  Created by Joseph on 2021/3/7.
//

import Foundation
import SwiftyBluetooth
import Toast_Swift


class BLEUtils {
        
    static let timeout = TimeInterval(5)
    static let serviceWithUUID = "0000FFE0-0000-1000-8000-00805F9B34FB"
    static let characWithUUID = "00000FF4-0000-1000-8000-00805F9B34FB"
    
    static let share = BLEUtils()
    
    /// 已发现的目标设备
    var discoveryPeripherals = [Peripheral]()
    /// 已连接的设备
    var connectedPeripheral: Peripheral?
    
    /// 开始扫描设备
    func scanForPeripherals(scanStoppedHandler:@escaping ([Peripheral]?) -> Void) {
        // You can pass in nil if you want to discover all Peripherals
        
        clearPeripherals()
        SwiftyBluetooth.scanForPeripherals(withServiceUUIDs: nil, timeoutAfter: BLEUtils.timeout) {[weak self] scanResult in
            switch scanResult {
            case .scanStarted:
                // 开始扫描设备

                break
            case .scanResult(let peripheral, _, _):
                // 扫描到目标设备
                print(peripheral.name ?? "unkonw")
                if let name = peripheral.name, name.hasPrefix("Traffic-") {
                    if self?.discoveryPeripherals.contains(where: {$0.identifier == peripheral.identifier}) == false {
                        self?.discoveryPeripherals.append(peripheral)
                    }
                }
                break
            case .scanStopped(let error):
                // 扫描结束
                print(error?.localizedDescription ?? "unknow error")
                switch error {
                case .bluetoothUnavailable(let reason):
                    var style = ToastStyle()
                    style.messageColor = .white
                    UIApplication.shared.keyWindow?.makeToast(reason.localizedDescription, duration: 2.0, position: .center, style: style)
                    break
                default:
                    break
                }
                scanStoppedHandler(self?.discoveryPeripherals)
                break
            }
        }
        
    }
    
    /// 清空所有设备
    func clearPeripherals() {
        discoveryPeripherals.removeAll()
        connectedPeripheral = nil
    }
        
    /// 断开已连接设备
    static func disconnectPeripheral(success: (()->Void)? = nil) {
        BLEUtils.share.connectedPeripheral?.disconnect(completion: {(result) in
            switch result {
            case .success(_):
                if let handler = success {
                    handler()
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        })
    }
    
    /// 向已连接设备发送数据
    static func sendData(success: (() -> Void)? = nil) {
        let buffer = CommandUtils.buildCommand()
        let data = Data(buffer)

        BLEUtils.share.connectedPeripheral?.writeValue(ofCharacWithUUID: BLEUtils.characWithUUID,
                                                       fromServiceWithUUID: BLEUtils.serviceWithUUID,
                              value: data) { result in
            switch result {
            case .success:
                if let handler = success {
                    handler()
                }
                print("send success")
                break // The write was succesful.
            case .failure(let error):
                print(error)
                break // An error happened while writting the data.
            }
        }
    }
}
