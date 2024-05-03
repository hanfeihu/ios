//
//  SearchViewController.swift
//  LightControl
//
//  Created by Joseph on 2021/1/2.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var beeView: CVLayerView!
    @IBOutlet weak var beeIconView: UIImageView!
    @IBOutlet weak var lodingLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
        startAnimation()
        BLEUtils.share.scanForPeripherals {[weak self] _ in
            self?.finishSearch()
        }
        
        
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func startAnimation() {
        beeView.starAnimation()
        var count = 0
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) {[weak self] (timer) in
            let index = count % 3
            let attr = NSMutableAttributedString(string: "...", attributes: [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: .bold)])
            attr.addAttributes([NSAttributedString.Key.foregroundColor : UIColor.white], range: NSRange(location: index, length: 1))
            self?.lodingLabel.attributedText = attr;
            count += 1
        }

        
        
        let from = beeIconView.center
        let springAnimation = CASpringAnimation.init(keyPath: "position")
        springAnimation.damping = 0
        springAnimation.mass    = 0.1
        springAnimation.initialVelocity = 10
        springAnimation.stiffness = 10
        springAnimation.fromValue =  from
        springAnimation.toValue   =  CGPoint(x: from.x, y: from.y - 5)
        springAnimation.duration  =  1000
        beeIconView.layer.add(springAnimation, forKey:  springAnimation.keyPath)
    }
    
    func finishSearch() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "\(DeviceListViewController.self)") else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }

}
