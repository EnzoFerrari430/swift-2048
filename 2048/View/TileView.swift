//
//  TileView.swift
//  2048
//
//  Created by Flisk on 2025/10/8.
//

import UIKit

class TileView: UILabel {
    
    var onLongPress: (() -> Void)?
    
    // 气泡功能
    private var bubbleView: UIView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLongPressGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLongPressGesture()
    }
    
    private func setupLongPressGesture() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5 // 长按0.5秒
        self.addGestureRecognizer(longPress)
        self.isUserInteractionEnabled = true
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            onLongPress?()
        }
    }
    
    // MARK: - 气泡效果
    
    func hideBubbleEffect() {
        bubbleView?.animateBubbleDisappear {
            self.bubbleView = nil
        }
    }
    
}


// 创建UIView扩展来处理气泡效果
extension UIView {
    func addBubbleEffect() -> UIView {
        let bubbleView = UIView(frame: self.bounds.insetBy(dx: -15, dy: -15))
        bubbleView.center = self.center
        bubbleView.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        bubbleView.layer.cornerRadius = bubbleView.bounds.width / 2
        bubbleView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        if let superview = self.superview {
            superview.insertSubview(bubbleView, belowSubview: self)
        }
        
        return bubbleView
    }
    
    func animateBubbleAppear() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: []) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
    
    func animateBubbleDisappear(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }
}
