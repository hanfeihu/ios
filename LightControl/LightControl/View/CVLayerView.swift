//
//  CVLayerView.swift
//  LightControl
//
//  Created by Joseph on 2021/3/11.
//

import UIKit

class CVLayerView: UIView {
    var pulseLayer : CAShapeLayer!  //定义图层

    override func awakeFromNib() {
        super.awakeFromNib()
        initiliziton()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initiliziton()
    }
    
    func initiliziton() {
        let width = UIScreen.main.bounds.width - 40

        // 动画图层
        pulseLayer = CAShapeLayer()
        pulseLayer.bounds = CGRect(x: 0, y: 0, width: width, height: width)
        pulseLayer.position = CGPoint(x: width/2, y: width/2)
        pulseLayer.backgroundColor = UIColor.clear.cgColor
        // 用BezierPath画一个原型
        pulseLayer.path = UIBezierPath(ovalIn: pulseLayer.bounds).cgPath
        // 脉冲效果的颜色  (注释*1)
        pulseLayer.fillColor = UIColor(red: 255, green: 193, blue: 22)?.cgColor
        pulseLayer.opacity = 0.0
        
        // 关键代码
        let replicatorLayer = CAReplicatorLayer()
        replicatorLayer.bounds = CGRect(x: 0, y: 0, width: width, height: width)
        replicatorLayer.position = CGPoint(x: width/2, y: width/2)
        replicatorLayer.instanceCount = 3  // 三个复制图层
        replicatorLayer.instanceDelay = 0.5  // 频率
        replicatorLayer.addSublayer(pulseLayer)
        self.layer.addSublayer(replicatorLayer)
        self.layer.insertSublayer(replicatorLayer, at: 0)
    }
    
    func starAnimation() {
       // 透明
       let opacityAnimation = CABasicAnimation(keyPath: "opacity")
       opacityAnimation.fromValue = 1.0  // 起始值
        opacityAnimation.toValue = 0     // 结束值

       // 扩散动画
       let scaleAnimation = CABasicAnimation(keyPath: "transform")
       let t = CATransform3DIdentity
        scaleAnimation.fromValue = NSValue(caTransform3D: CATransform3DScale(t, 0.5, 0.5, 0.0))
       scaleAnimation.toValue = NSValue(caTransform3D: CATransform3DScale(t, 1.0, 1.0, 0.0))

       // 给CAShapeLayer添加组合动画
       let groupAnimation = CAAnimationGroup()
       groupAnimation.animations = [opacityAnimation,scaleAnimation]
        groupAnimation.duration = 1   //持续时间
       groupAnimation.autoreverses = false //循环效果
       groupAnimation.repeatCount = HUGE
       pulseLayer.add(groupAnimation, forKey: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
