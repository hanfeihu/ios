//
//  DeviceListViewController.swift
//  LightControl
//
//  Created by Joseph on 2021/1/2.
//

import UIKit

class DeviceListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var notFoundLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        tableView.register(UINib.init(nibName: "DeviceCell", bundle: nil), forCellReuseIdentifier: "DeviceCell")

    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        if let homeVC = navigationController?.children.filter({ $0.isKind(of: HomeViewController.self)}).first {
            navigationController?.popToViewController(homeVC, animated: true)
        }
    }
    
}


extension DeviceListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = BLEUtils.share.discoveryPeripherals.count
        notFoundLabel.isHidden = count > 0
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! DeviceCell
        let name = BLEUtils.share.discoveryPeripherals[indexPath.row].name?.replacingOccurrences(of: "Traffic", with: "Timer")
        cell.titleLabel.text = name
        return cell;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        BLEUtils.share.discoveryPeripherals[indexPath.row].connect(withTimeout: 5) {[weak self] result in
            switch result {
            case .success:
                BLEUtils.share.connectedPeripheral =  BLEUtils.share.discoveryPeripherals[indexPath.row]
                // You are now connected to the peripheral
                guard let vc = self?.storyboard?.instantiateViewController(withIdentifier: "\(SetTimerViewController.self)") else {
                    return
                }
                self?.navigationController?.pushViewController(vc, animated: true)
                break
            case .failure(let error):
                // An error happened while connecting
                print(error.localizedDescription)
                break
            }
        }
        
    }
    
    
    
}


