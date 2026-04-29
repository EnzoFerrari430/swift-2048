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

// 背景color - 经典2048风格配色，渐变到高阶数字
var back_color_dictionary: [Int: UIColor] = [
    2:UIColor(r: 238, g: 228, b: 219),      // 浅米色
    4:UIColor(r: 237, g: 224, b: 200),     // 米色
    8:UIColor(r: 242, g: 177, b: 121),     // 橙色
    16:UIColor(r: 245, g: 149, b: 99),     // 深橙色
    32:UIColor(r: 246, g: 124, b: 95),     // 珊瑚红
    64:UIColor(r: 246, g: 94, b: 59),       // 红色
    128:UIColor(r: 237, g: 207, b: 114),   // 金黄色
    256:UIColor(r: 237, g: 200, b: 80),    // 深金色
    512:UIColor(r: 237, g: 197, b: 63),    // 亮金色
    1024:UIColor(r: 237, g: 194, b: 46),   // 橙金色
    2048:UIColor(r: 237, g: 194, b: 46),   // 金色 (2048达成)
    4096:UIColor(r: 60, g: 58, b: 50),     // 深棕黑 (超级数字)
]

// 文字color - 小数字用深色，大数字用浅色
var text_color_dictionary: [Int: UIColor] = [
    2:UIColor(r: 119, g: 110, b: 101),     // 深灰
    4:UIColor(r: 119, g: 110, b: 101),     // 深灰
    8:UIColor(r: 249, g: 246, b: 242),     // 白色
    16:UIColor(r: 249, g: 246, b: 242),    // 白色
    32:UIColor(r: 249, g: 246, b: 242),    // 白色
    64:UIColor(r: 249, g: 246, b: 242),    // 白色
    128:UIColor(r: 249, g: 246, b: 242),   // 白色
    256:UIColor(r: 249, g: 246, b: 242),   // 白色
    512:UIColor(r: 249, g: 246, b: 242),   // 白色
    1024:UIColor(r: 249, g: 246, b: 242),  // 白色
    2048:UIColor(r: 249, g: 246, b: 242),  // 白色
    4096:UIColor(r: 249, g: 246, b: 242), // 白色
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
    let label: TileView
    private var bubbleView: UIView?
    
    var value: Int = 0 {
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
        label = TileView(frame: frame)
        super.init(frame: frame)
        self.frame = frame
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        set(value: value)
        label.onLongPress = { [weak self] in
            guard let self = self else { return }
            let row = (self.tag / 100) - 1
            let col = self.tag % 100
            print("长按了卡片，位置: row=\(row), col=\(col), 值=\(self.value)")
            
            // 这里可以添加消除逻辑或通知父视图
            NotificationCenter.default.post(
                name: .init("CardLongPressed"),
                object: nil,
                userInfo: ["position": (row, col), "value": self.value]
            )
        }
        
        // 初始化手势识别
        // setupGesture()
    }
    
    required init?(coder: NSCoder) {
        label = TileView(frame: .zero)
        super.init(coder: coder)
        
        // 让label跟随当前bounds
        label.frame = self.bounds
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
    
    // MARK: - 气泡效果
    
    private func showBubbleEffect() {
        if bubbleView == nil {
            bubbleView = label.addBubbleEffect()
            bubbleView?.animateBubbleAppear()
        }
    }
    
    private func hideBubbleEffect() {
        bubbleView?.alpha = 0
        bubbleView?.removeFromSuperview()
        bubbleView = nil
    }
    
    func breakBubbleEffect(completion: (() -> Void)? = nil) {
        // 创建玻璃破碎效果
        createGlassShatterEffect()
        
        // 隐藏卡片和气泡
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.bubbleView?.alpha = 0
        }) { _ in
            self.bubbleView?.removeFromSuperview()
            self.bubbleView = nil
            self.removeFromSuperview()  // 真正从父视图移除
            completion?()
        }
    }
    
    // MARK: - 玻璃破碎效果
    
    private func createGlassShatterEffect() {
        // 创建碎片数量
        let shardCount = 12
        
        for i in 0..<shardCount {
            let shard = createGlassShard(index: i)
            superview?.addSubview(shard)
            
            // 计算飞散方向
            let angle = CGFloat(i) * (2 * CGFloat.pi / CGFloat(shardCount)) + CGFloat.random(in: -0.3...0.3)
            let distance: CGFloat = CGFloat.random(in: 50...120)
            let dx = cos(angle) * distance
            let dy = sin(angle) * distance
            
            // 随机旋转角度
            let rotation = CGFloat.random(in: -2...2) * CGFloat.pi
            
            // 动画：飞散 + 旋转 + 消失
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
                shard.center = CGPoint(
                    x: shard.center.x + dx,
                    y: shard.center.y + dy
                )
                shard.transform = CGAffineTransform(rotationAngle: rotation)
                shard.alpha = 0
            } completion: { _ in
                shard.removeFromSuperview()
            }
        }
    }
    
    // 创建单个玻璃碎片
    private func createGlassShard(index: Int) -> UIView {
        let size = CGSize(
            width: CGFloat.random(in: 10...25),
            height: CGFloat.random(in: 10...25)
        )
        let shard = UIView(frame: CGRect(origin: .zero, size: size))
        shard.center = self.center
        shard.backgroundColor = self.backgroundColor?.withAlphaComponent(CGFloat.random(in: 0.6...0.9))
        shard.layer.cornerRadius = CGFloat.random(in: 2...5)
        shard.layer.shadowColor = UIColor.black.cgColor
        shard.layer.shadowOffset = CGSize(width: 1, height: 1)
        shard.layer.shadowOpacity = 0.3
        shard.layer.shadowRadius = 2
        return shard
    }
}
