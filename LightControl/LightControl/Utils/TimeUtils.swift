//
//  TimeUtils.swift
//  LightControl
//
//  Created by Joseph on 2021/3/7.
//

import Foundation
import SwifterSwift

enum TimeRange: Int {
    case AM = 0
    case PM = 1
}

struct Time {
    var h = 0
    var m = 0
    var s = 0
    var range = TimeRange.AM
}

/// 根据结束时间计算 时长
func calculateDuration(endtime: Time) -> Time? {
    // 转换成24小时制
    var duration = Time()
    var hour = endtime.h
    if endtime.range == .AM, hour == 12 {
        hour = 0
    }
    if endtime.range == .PM, hour != 12 {
        hour += 12
    }
    
    let minute = endtime.m
    let second = endtime.s
    
    guard var endDate = Date(hour: hour, minute: minute, second: second) else {
        return nil
    }
    
    let now = Date()
    if endDate < now {
        endDate.add(.day, value: 1)
    }
    
    var seconds = Int(endDate.secondsSince(now))
    let maxDuration = 16 * 3600 - 1
    seconds = seconds > maxDuration ? maxDuration : seconds
    let h = seconds / 3600
    let m = seconds % 3600 / 60
    let s = seconds % 3600 % 60
    duration.h = Int(h)
    duration.m = Int(m)
    duration.s = Int(s)    
    return duration
}


/// 根据时长计算 结束时间
func calculateEndTime(duration: Time) -> Time? {
    let sec = duration.h * 3600 + duration.m * 60 + duration.s
    let endDate = Date().addingTimeInterval(TimeInterval(sec))
    let endTime = endDate.convertToTime()
    return endTime
}

extension Date {
    func convertToTime() -> Time {
        var endTime = Time()
        if hour > 12 {
            endTime.h = hour - 12
            endTime.range = .PM
        }else if hour == 0 {
            endTime.h = 12
            endTime.range = .AM
        }else if hour == 12 {
            endTime.h = 12
            endTime.range = .PM
        }else {
            endTime.h = hour
            endTime.range = .AM
        }
        endTime.m = minute
        endTime.s = second
        return endTime
    }
}
