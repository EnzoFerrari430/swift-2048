//
//  TileView.swift
//  2048
//
//  Created by Flisk on 2025/10/8.
//

import UIKit

class TileView: UILabel {
    
    var onLongPress: (() -> Void)?
    
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
    
}
