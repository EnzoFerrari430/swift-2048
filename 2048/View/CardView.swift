//
//  CardView.swift
//  2048
//
//  Created by Flisk on 2024/12/16.
//

import UIKit

// ✅ 推荐做法：添加 UIColor 扩展
extension UIColor {
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        // 确保数值在 0-255 范围内
        let red = CGFloat(min(max(r, 0), 255)) / 255.0
        let green = CGFloat(min(max(g, 0), 255)) / 255.0
        let blue = CGFloat(min(max(b, 0), 255)) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: a)
    }
}

// 背景color
var back_color_dictionary: [Int: UIColor] = [
    2:UIColor(r: 238, g: 228, b: 219, a: 1.0),
    4:UIColor(r: 234, g: 224, b: 203, a: 1.0),
    8:UIColor(r: 231, g: 179, b: 129, a: 1.0),
    16:UIColor(r: 230, g: 153, b: 108, a: 1.0),
    32:UIColor(r: 230, g: 130, b: 102, a: 1.0),
    64:UIColor(r: 226, g: 103, b: 71, a: 1.0),
    128:UIColor(r: 231, g: 207, b: 126, a: 1.0)
]

// 添加文字color
var text_color_dictionary: [Int: UIColor] = [
    2:UIColor(r: 107, g: 110, b: 102, a: 1.0),
    4:UIColor(r: 107, g: 110, b: 102, a: 1.0),
    8:UIColor(r: 249, g: 246, b: 243, a: 1.0),
    16:UIColor(r: 249, g: 246, b: 243, a: 1.0),
    32:UIColor(r: 249, g: 246, b: 243, a: 1.0),
    64:UIColor(r: 249, g: 246, b: 243, a: 1.0),
    128:UIColor(r: 249, g: 246, b: 243, a: 1.0)
]

class CardView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // 用于显示数字的label
    private let label = UILabel()
    
    private var value: Int = 0 {
        // didSet 属性观察者 在属性更新之后调用
        didSet {
            if value == 0 {
                isHidden = true
            } else {
                isHidden = false
                // todo 背景色和文字颜色需要根据值进行变化
                //backgroundColor = UIColor(r: 238, g: 228, b: 219, a: 1.0)//.orange
                if let bgColor = back_color_dictionary[value] {
                    backgroundColor = bgColor
                } else {
                    backgroundColor = .orange
                }
                label.text = "\(value)"
                if let textColor = text_color_dictionary[value] {
                    label.textColor = textColor
                } else {
                    label.textColor = UIColor(r: 249, g: 246, b: 243, a: 1.0)//.white
                }
            }
        }
    }
    
    init(frame: CGRect, value: Int) {
        super.init(frame: frame)
        self.frame = frame
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        set(value: value)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func updateValue(to newValue: Int) {
        value = newValue
    }
    
    private func set(value: Int) {
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 36.0)
        // 设置字体大小自适应 使得label能显示全所有文字
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        self.addSubview(label)
        
        // 设置label的布局约束 需要先将自动布局约束设置为false
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        updateValue(to: value)
    }
    
    // 创建的动画
    func createAnimation() {
        transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.1,
            delay: 0.0,
            options: [],
            animations: {
                self.transform = .identity
            },
            completion: nil
        )
    }
    
    // 数字更新的时候需要一个动画效果
    func flash(withValue value: Int = 0) {
        transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
        updateValue(to: value)
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.08,
            delay: 0.0,
            options: [.repeat],
            animations: {
                self.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
            },
            completion: {
                position in
                self.transform = .identity
            }
        )
    }

}
