//
//  	BubbleLabelViewController.swift
//  2048
//
//  Created by Flisk on 2025/10/1.
//

import UIKit


class PaddedLabel: UILabel {
    var padding: UIEdgeInsets = UIEdgeInsets(
        top: 0,
        left: 0,
        bottom: 0,
        right: 0
    ) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + padding.left + padding.right,
            height: size.height + padding.top + padding.bottom
        )
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let adjSize = CGSize(
            width: size.width - padding.left - padding.right,
            height: size.height - padding.top - padding.bottom
        )
        let superSize = super.sizeThatFits(adjSize)
        return CGSize(
            width: superSize.width + padding.left + padding.right,
            height: superSize.height + padding.top + padding.bottom
        )
    }
}



class BubbleLabelViewController : UIViewController {
    
    let animatedLabel: UILabel = {
        
        let label = PaddedLabel()
        label.text = "长按我试试"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .white
        label.backgroundColor = .systemBlue
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.padding = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        label.isUserInteractionEnabled = true // 启用用户交互
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLongPressGesture()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 添加标签到视图
        view.addSubview(animatedLabel)
        animatedLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // 居中布局
        NSLayoutConstraint.activate([
            animatedLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            animatedLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupLongPressGesture() {
        // 创建长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.1 // 长按触发时间
        animatedLabel.addGestureRecognizer(longPress)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            // 开始长按，执行膨胀动画
            startBubbleAnimation()
        case .ended, .cancelled, .failed:
            // 结束长按，执行收缩动画
            endBubbleAnimation()
        default:
            break;
        }
    }
    
    private func startBubbleAnimation() {
        // 膨胀动画
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseOut,
                       animations: {
            // 轻微放大
            self.animatedLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            // 增加圆角使气泡更明显
            self.animatedLabel.layer.cornerRadius = 16
            // 稍微改变背景色增加深度感
            self.animatedLabel.backgroundColor = .systemBlue.withAlphaComponent(0.9)
        }, completion: nil)
    }
    
    private func endBubbleAnimation() {
        // 收缩动画
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseIn,
                       animations: {
            // 恢复原始状态
            self.animatedLabel.transform = .identity
            self.animatedLabel.layer.cornerRadius = 12
            self.animatedLabel.backgroundColor = .systemBlue
        }, completion: nil)
    }
}

//// 扩展UILabel以支持内边距
//extension UILabel {
//    var padding: UIEdgeInsets {
//        get {
//            return UIEdgeInsets(
//                top: self.font.pointSize * 0.5,
//                left: self.font.pointSize,
//                bottom: self.font.pointSize * 0.5,
//                right: self.font.pointSize
//            )
//        }
//        set {
//            self.drawText(in: bounds.inset(by: newValue))
//        }
//    }
//    
//    override func drawText(in rect: CGRect) {
//        super.drawText(in: rect.inset(by: padding))
//    }
//    
//    override open var intrinsicContentSize: CGSize {
//        let size = super.intrinsicContentSize
//        return CGSize(
//            width: size.width + padding.left + padding.right,
//            height: size.height + padding.top + padding.bottom
//        )
//    }
//    
//    
//}
