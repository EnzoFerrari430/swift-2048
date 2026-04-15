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
    
    private func setupGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.3
        self.addGestureRecognizer(longPress)
        self.isUserInteractionEnabled = true
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            showBubbleEffect()
            provideHapticFeedback()
        case .ended, .cancelled:
            if let bubbleView = bubbleView {
                // 检查是否应该触发消除
                let location = gesture.location(in: self)
                if bounds.contains(location) {
                    // 触发消除
                    breakBubbleEffect()
                } else {
                    // 只是取消
                    hideBubbleEffect()
                }
            }
        default:
            break
        }
    }
    
    private func showBubbleEffect() {
        hideBubbleEffect()
        bubbleView = label.addBubbleEffect()
        bubbleView?.animateBubbleAppear()
    }
    
    private func hideBubbleEffect() {
        bubbleView?.animateBubbleDisappear {
            self.bubbleView = nil
        }
    }
    
    func breakBubbleEffect(completion: (() -> Void)? = nil) {
        // 创建粒子效果
        createParticleEffect()
        
        // 隐藏卡片和气泡
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            self.bubbleView?.alpha = 0
        }) { _ in
            self.bubbleView?.removeFromSuperview()
            self.bubbleView = nil
            completion?()
        }
    }
    
    private func createParticleEffect() {
        let particleEmitter = CAEmitterLayer()
        particleEmitter.emitterPosition = CGPoint(x: bounds.midX, y: bounds.midY)
        particleEmitter.emitterSize = CGSize(width: bounds.width, height: bounds.height)
        particleEmitter.emitterShape = .circle
        particleEmitter.renderMode = .additive
        
        let cell = CAEmitterCell()
        cell.birthRate = 20
        cell.lifetime = 1.0
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionRange = .pi * 2
        cell.scale = 0.1
        cell.scaleRange = 0.05
        cell.alphaSpeed = -1.0
        cell.contents = createBubbleParticleImage().cgImage
        
        particleEmitter.emitterCells = [cell]
        layer.addSublayer(particleEmitter)
        
        // 自动移除粒子层
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            particleEmitter.removeFromSuperlayer()
        }
    }
    
    private func createBubbleParticleImage() -> UIImage {
        let size = CGSize(width: 8, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            UIColor.white.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
    }
    
    private func provideHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

}
