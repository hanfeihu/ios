//
//  SettingViewController.swift
//  LightControl
//
//  Created by Joseph on 2021/1/2.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet weak var alertSwitch: UISwitch!
    
    @IBOutlet weak var musicSwitch: UISwitch!
    
    @IBOutlet weak var countDownSwitch: UISwitch!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(hex: MainColorValue)
        // Do any additional setup after loading the view.
        alertSwitch.isOn = CommandUtils.shareCommand.alarm == 1
        musicSwitch.isOn = CommandUtils.shareCommand.openSoundNo == 1
        countDownSwitch.isOn = CommandUtils.shareCommand.trafficLightUpdateSet == 1
        
    }
    

    @IBAction func backButtonAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true);
    }

    
    @IBAction func AlarmSwitchAction(_ sender: UISwitch) {
        CommandUtils.updateCommand(cmd: 2, suspendAndContinue: 0, alarm: sender.isOn ? 1 : 0)
        BLEUtils.sendData()
    }
    
    @IBAction func musicSwitchAction(_ sender: UISwitch) {
        CommandUtils.updateCommand(cmd: 2, suspendAndContinue: 0, openSoundNo: sender.isOn ? 1 : 0)
        BLEUtils.sendData()
    }
    
    @IBAction func countdownToGreenSwitchAction(_ sender: UISwitch) {
        CommandUtils.updateCommand(cmd: 2, suspendAndContinue: 0, trafficLightUpdateSet: sender.isOn ? 1 : 0)
        BLEUtils.sendData()
    }
}
