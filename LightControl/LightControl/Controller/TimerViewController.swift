//
//  TimerViewController.swift
//  LightControl
//
//  Created by Joseph on 2021/1/2.
//

import UIKit
import Toast_Swift

class TimerViewController: UIViewController {
    /// 倒计时总时间
    var totalTime: UInt16 = 0
    /// 定时器
    var timer: Timer?
    /// 倒计时Label
    @IBOutlet weak var remainLabel: UILabel!
    
    /// 进入页面调用函数
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(hex: MainColorValue)
        resumn()
    }

    /// Back按钮点击事件
    @IBAction func backButtonAction(_ sender: UIButton) {
        invalidateTimer()
        navigationController?.popViewController(animated: true)
    }
    
    /// Pause按钮点击事件
    @IBAction func pauseButtonAction(_ sender: UIButton) {
        invalidateTimer()
        CommandUtils.updateCommand(cmd: 02, suspendAndContinue: 0)
        BLEUtils.sendData()
    }
    
    /// Resumn按钮点击事件
    @IBAction func resumnButtonAction(_ sender: UIButton) {
        resumn()
    }
    
    /// Cancel按钮点击事件
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        showAlert(title: NSLocalizedString("ToStop", comment: ""), message: nil, buttonTitles: [NSLocalizedString("Sure", comment: ""), NSLocalizedString("Cancel", comment: "")], highlightedButtonIndex: 0) {[weak self] (index) in
            if index == 0 {
                self?.closeDevice()
            }
        }
    }
    
    /// Cancel
    func closeDevice() {
        invalidateTimer()
        CommandUtils.updateCommand(cmd: 01)
        BLEUtils.sendData {
            [weak self] in
            var style = ToastStyle()
            style.messageColor = .white
            UIApplication.shared.keyWindow?.makeToast(NSLocalizedString("Shutdown", comment: ""), duration: 1.0, position: .center, style: style)
            self?.disconnect();
            
        }
    }
    
    /// 断开蓝牙并返回 + 号页面
    func disconnect() {
        BLEUtils.disconnectPeripheral {
            [weak self] in
            self?.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    /// 启动倒计时定时器
    func resumn() {
        let isValid = timer?.isValid ?? false
        if !isValid {
            countDown()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        }
       
    }
    
    /// 倒计时
    @objc func countDown() {
        if totalTime > 0 {
            CommandUtils.updateCommand(cmd: 02, suspendAndContinue: 01, timeRemaining: totalTime)
            BLEUtils.sendData()
            updateRemainTime()
            totalTime -= 1
        }else {
            // 倒计时为0的时候，发送暂停指令
            CommandUtils.updateCommand(cmd: 02, suspendAndContinue: 0, timeRemaining: 0)
            BLEUtils.sendData()
            updateRemainTime()
            invalidateTimer()
        }
    }
    
    /// 取消定时器
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// 更新剩余时间UI
    func updateRemainTime() {
        let h = totalTime / 3600
        let m = totalTime % 3600 / 60
        let s = totalTime % 3600 % 60
        remainLabel.text = String(format: "%02d:%02d:%02d", h, m, s)
    }
}
