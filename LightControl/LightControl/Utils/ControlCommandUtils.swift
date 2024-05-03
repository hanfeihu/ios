//
//  Test.swift
//  Test
//
//  Created by caijie on 2021/3/9.
//

import Foundation

struct ControlCommand {
    /**
    * 固定头 1字节
    */
    var begin: UInt8 = 0x24
    
   /**
    * 长度 1字节
    */
    var length: UInt8 = 0x11
    
   /**
    *  协议编号 01：关机协议 02：暂停于继续协议 1字节
    */
    var cmd: UInt8 = 0
    
   /**
    * 手机时间 yyMMddHHssmm 6个字节
    */
    var phoneTime: [UInt8] = [0]
    
   /**
    * 暂停继续   0：暂停 1：继续 1字节
    */
    var suspendAndContinue: UInt8 = 0
    
   /**
    * 剩余时间（小端） 秒为单位 2字节
    */
    var timeRemaining: UInt16 = 0
    
   /**
    * 亮度调节 0-100 1字节
    */
    var brightness: UInt8 = 0

   /**
    * 开机声音编号 1-20 1字节
    */
    var openSoundNo: UInt8 = 0

   /**
    * 关机声音编号 1-20 1字节
    */
    var closeSoundNo: UInt8 = 0

   /**
    * 红绿灯变更方式 0： 由绿变红 1：由红变黄  1字节
    */
    var trafficLightUpdateSet: UInt8 = 0

   /**
    * 警报开关 0：关 1：开 1字节
    */
    var alarm: UInt8 = 1

    var key: UInt8 = 0
}


class CommandUtils {
    
    static var shareCommand = ControlCommand()
    
    static func updateCommand(cmd: UInt8 = shareCommand.cmd,
                              suspendAndContinue: UInt8 = shareCommand.cmd,
                              timeRemaining: UInt16 = shareCommand.timeRemaining,
                              brightness: UInt8 = shareCommand.brightness,
                              openSoundNo: UInt8 = shareCommand.openSoundNo,
                              closeSoundNo: UInt8 = shareCommand.closeSoundNo,
                              trafficLightUpdateSet: UInt8 = shareCommand.trafficLightUpdateSet,
                              alarm: UInt8 = shareCommand.alarm) {
                

        shareCommand.suspendAndContinue = suspendAndContinue
        print(timeRemaining)
        shareCommand.timeRemaining = timeRemaining//ByteArray(from: timeRemaining)
        shareCommand.brightness = brightness
        shareCommand.openSoundNo = openSoundNo
        shareCommand.closeSoundNo = closeSoundNo
        shareCommand.trafficLightUpdateSet = trafficLightUpdateSet
        shareCommand.alarm = alarm
        shareCommand.cmd = cmd
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMddHHmmss"
        // 210310232452
        let dateString = formatter.string(from: Date())
        if  let bytes = dateString.asHex() {
            shareCommand.phoneTime = bytes
        }

        // key
        if  let bytes = dateString.asHex() {
            let bo1 = bytes[0] &+ bytes[3]
            let bo2 = bytes[1] ^ bytes[4]
            let bo3 = bytes[2] &+ bytes[5]
            let key = bo1 ^ bo2 &+ bo3
            shareCommand.key = key;
        }
    }
    

    static func buildCommand() -> [UInt8] {
        //数据要加密的
        //协议总长度 是17个自己 因此定义 byte 17
        var resData = [UInt8].init(repeating: 0, count: 17)
        //第一个字节 固定头
        resData[0] = shareCommand.begin
        //第二个节=协议长度
        resData[1] = shareCommand.length
        //第三个节=协议编号 从这里开始 往下每个字节都需要加密  手机时间字节不需要 加密方式就是 将数据加上刚计算出来的KEY 所以是  this.cmd+this.key
        resData[2] = shareCommand.cmd+shareCommand.key

        //拼装 手机时间
        if shareCommand.phoneTime.count != 6 {
            getPhoneTimer()
        }
        
        resData[3] = shareCommand.phoneTime[0];//1 不需要加密
        resData[4] = shareCommand.phoneTime[1];//2 不需要加密
        resData[5] = shareCommand.phoneTime[2];//3 不需要加密
        resData[6] = shareCommand.phoneTime[3];//4 不需要加密
        resData[7] = shareCommand.phoneTime[4];//5 不需要急吗
        resData[8] = shareCommand.phoneTime[5];//6 不需要加密

        //暂停与继续 +this.key
        resData[9] = shareCommand.suspendAndContinue &+ shareCommand.key
        //剩余时间 第一个字节 KEY
        resData[10] = ByteArray(from: shareCommand.timeRemaining)[0] &+ shareCommand.key
        //剩余时间 第二个字节 KEY
        resData[11] = ByteArray(from: shareCommand.timeRemaining)[1] &+ shareCommand.key
        resData[12] = shareCommand.brightness &+ shareCommand.key
        resData[13] = shareCommand.openSoundNo &+ shareCommand.key
        resData[14] = shareCommand.closeSoundNo &+ shareCommand.key
        resData[15] = shareCommand.trafficLightUpdateSet &+ shareCommand.key
        //报警开关
        resData[16] = shareCommand.alarm &+ shareCommand.key
        return resData;
    }
    
    static func getPhoneTimer() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyMMddHHmmss"
        // 210310232452
        let dateString = formatter.string(from: Date())
        if  let bytes = dateString.asHex() {
            shareCommand.phoneTime = bytes
        }
    }
}

extension String {

    func asHex() -> [UInt8]? {
        var hexStr = self
        if hexStr.hasPrefix("0x") {
            hexStr = String(hexStr.dropFirst(2))
        }
        guard hexStr.count >= 2, hexStr.count % 2 == 0 else {
            return nil
        }
        let size = hexStr.count / 2
        var buffer = [UInt8].init(repeating: 0, count: size)
        var value: UInt64 = 0;
        
        for i in 0..<size {
            let start = i * 2
            let sub = hexStr.subString(range: start..<start + 2)
            let scanner = Scanner(string: sub)
            if scanner.scanHexInt64(&value) {
                buffer[i] = ByteArray(from: value)[0]
            }
        }
        return buffer
    }
    
    
    func index(at offset: Int) -> Index {
        return self.index(startIndex, offsetBy: offset)
    }
    
    func subString(range: Range<Int>) -> String {
        let start = self.index(at: range.lowerBound)
        let end = self.index(at: range.upperBound)
        let sub = self[start..<end];
        return String(sub)
    }
}

func ByteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
    withUnsafeBytes(of: value.littleEndian, Array.init)
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
