//
//  SetTimerViewController.swift
//  LightControl
//
//  Created by Joseph on 2021/1/2.
//

import UIKit
import SwifterSwift
import AutoInch
import Toast_Swift


class SetTimerViewController: UIViewController {

    
    @IBOutlet weak var durationHPickerView: UIPickerView!
    @IBOutlet weak var durationMPickerView: UIPickerView!
    @IBOutlet weak var durationSPickerView: UIPickerView!
    
    @IBOutlet weak var endHPickerView: UIPickerView!
    @IBOutlet weak var endMPickerView: UIPickerView!
    @IBOutlet weak var endSPickerView: UIPickerView!
    @IBOutlet weak var timeRangePickerView: UIPickerView!
    
    var endTime = Time()
    var duration = Time()
    
    var endTimeHRange = 1...12
    var durationHRange = 0...15
    var minRange = 0...59
    var secRange = 0...59
    var timeRange = [TimeRange.AM, TimeRange.PM]
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(hex: MainColorValue)
        endTime = Date().convertToTime()
        adjustEndTime()
    }

    func disconnectPeripheral() {
        BLEUtils.disconnectPeripheral {
            [weak self] in
            self?.navigationController?.popViewController(animated: true);
            var style = ToastStyle()
            style.messageColor = .white
            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("Disconnect", comment: ""), duration: 1.0, position: .center, style: style)
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        showAlert(title: NSLocalizedString("ToDisconnect", comment: ""), message: nil, buttonTitles: [NSLocalizedString("Sure", comment: ""), NSLocalizedString("Cancel", comment: "")], highlightedButtonIndex: 0) {[weak self] (index) in
            if index == 0 {
                self?.disconnectPeripheral()
            }
        }
        
    }
    
    
    
    @IBAction func startAction(_ sender: UIButton) {
        let totleTime = UInt16(duration.h * 3600 + duration.m * 60 + duration.s)
        guard totleTime > 0 else {
            var style = ToastStyle()
            style.messageColor = .white
            self.view.makeToast(NSLocalizedString("ChooseTime", comment: ""), duration: 1.0, position: .center, style: style)
            return
        }
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "TimerViewController") as? TimerViewController {
            vc.totalTime = totleTime
            navigationController?.pushViewController(vc)
        }
    }
    
    @IBAction func setttingAction(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "SettingViewController") {
            navigationController?.pushViewController(vc)
        }
    }

    @IBAction func shopAction(_ sender: UIButton) {
        if let url = URL(string: "http://stoplightgolight.com/product/stoplight-golight/") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func rateAction(_ sender: UIButton) {
        if let url = URL(string: "http://stoplightgolight.com/product/stoplight-golight/") {
            UIApplication.shared.open(url)
        }
    }
}

extension SetTimerViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.isEqual(endHPickerView) {
            return endTimeHRange.count
        }else if pickerView.isEqual(endMPickerView) {
            return minRange.count
        }else if pickerView.isEqual(endSPickerView) {
            return secRange.count
        }else if pickerView.isEqual(durationHPickerView) {
            return durationHRange.count
        }else if pickerView.isEqual(durationMPickerView) {
            return minRange.count
        }else if pickerView.isEqual(durationSPickerView) {
            return secRange.count
        }else if pickerView.isEqual(timeRangePickerView) {
            return timeRange.count
        }else {
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var title = ""
        if pickerView.isEqual(endHPickerView) {
            title = String(format: "%02d", endTimeHRange[offset: row])
        }else if pickerView.isEqual(endMPickerView) {
            title = String(format: "%02d", minRange[offset: row])
        }else if pickerView.isEqual(endSPickerView) {
            title = String(format: "%02d", secRange[offset: row])
        }else if pickerView.isEqual(durationHPickerView) {
            title = String(format: "%02d", durationHRange[offset: row])
        }else if pickerView.isEqual(durationMPickerView) {
            title = String(format: "%02d", minRange[offset: row])
        }else if pickerView.isEqual(durationSPickerView) {
            title = String(format: "%02d", secRange[offset: row])
        }else if pickerView.isEqual(timeRangePickerView) {
            switch timeRange[offset: row] {
            case .AM:
                title = "AM"
                break
            default:
                title = "PM"
                break
            }
        }
        if let label = view as? UILabel {
            label.text = title
            return label
        }else {
            let label = UILabel(text: title, style: .title1)
            label.textColor = .white
            label.textAlignment = .center
            label.font = UIFont(name: "LittleOrion-PersonalUse-Regular", size: 25.auto())
            return label
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView.isEqual(endHPickerView) {
            endTime.h = endTimeHRange[offset: row]
            adjustDuration()
        }else if pickerView.isEqual(endMPickerView) {
            endTime.m = minRange[offset: row]
            adjustDuration()
        }else if pickerView.isEqual(endSPickerView) {
            endTime.s = secRange[offset: row]
            adjustDuration()
        }else if pickerView.isEqual(timeRangePickerView), let range = TimeRange(rawValue: row) {
            endTime.range = range
            adjustDuration()
        }else if pickerView.isEqual(durationHPickerView) {
            duration.h = durationHRange[offset: row]
            adjustEndTime()
        }else if pickerView.isEqual(durationMPickerView) {
            duration.m = minRange[offset: row]
            adjustEndTime()
        }else if pickerView.isEqual(durationSPickerView) {
            duration.s = secRange[offset: row]
            adjustEndTime()
        }
    }
    
    func adjustDuration() {
        if let duration = calculateDuration(endtime: endTime) {
            self.duration = duration
            durationHPickerView.selectRow(duration.h, inComponent: 0, animated: true)
            durationMPickerView.selectRow(duration.m, inComponent: 0, animated: true)
            durationSPickerView.selectRow(duration.s, inComponent: 0, animated: true)

        }
    }
    
    func adjustEndTime() {
        if let endTime = calculateEndTime(duration: duration) {
            endHPickerView.selectRow(endTime.h-1, inComponent: 0, animated: true)
            
            endMPickerView.selectRow(endTime.m, inComponent: 0, animated: true)
            endSPickerView.selectRow(endTime.s, inComponent: 0, animated: true)
            timeRangePickerView.selectRow(endTime.range.rawValue, inComponent: 0, animated: true)

        }
    }
    

    
}
