//
//  ExplodingLabel.swift
//  2048
//
//  Created by Flisk on 2025/9/24.
//

import UIKit

class ExplodingLabel: UILabel {
    
    // 粒子数量
    private let particleCount: Int = 50
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // 启用用户交互
        isUserInteractionEnabled = true
        
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func labelTapped() {
        explode()
    }
    
    private func explode() {
        // 确保label有父视图
        guard let superview = superview else { return }
        
        // 捕获当前label图像
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let image = renderer.image { _ in
            self.drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        
        // 隐藏原有label
        isHidden = true
        
        for _ in 0..<particleCount {
            // 随机生成粒子在label范围内
            let randomPoint = CGPoint(
                x: CGFloat.random(in: 0...bounds.width),
                y: CGFloat.random(in: 0...bounds.height)
            )
            
            let pixelColor = image.getPixelColor(at: randomPoint)
            
            // 创建粒子视图
            let particle = UIView(frame: CGRect(x: 0, y: 0, width: 3, height: 3))
            particle.center = convert(randomPoint, to: superview)
            particle.backgroundColor = pixelColor
            particle.layer.cornerRadius = 1.5 // 圆形粒子
            superview.addSubview(particle)
            
            // 随机生成粒子爆炸的方向和距离
            let angle = CGFloat.random(in: 0...2*CGFloat.pi)
            let distance = CGFloat.random(in: 50...150)
            let destination = CGPoint(
                x: particle.center.x + cos(angle) * distance,
                y: particle.center.y + sin(angle) * distance
            )
            
            // 添加粒子动画
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options:[], animations: {
                particle.center = destination
                particle.alpha = 0}) { _ in
                    //动画结束后移出粒子
                    particle.removeFromSuperview()
                }
        }
        
        // 1秒后恢复label显示 (可选)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isHidden = false
        }
    }
    
    
}


// 扩展UIImage 获取指定点的颜色
extension UIImage {
    func getPixelColor(at point: CGPoint) -> UIColor? {
        guard let cgImage = cgImage,
              let data = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else {
            return nil
        }
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let bytesPerRow = cgImage.bytesPerRow
        
        let x = min(max(0, point.x), width - 1)
        let y = min(max(0, point.y), height - 1)
        
        let pixelInfo = Int(y) * bytesPerRow + Int(x) * bytesPerPixel
        
        let r = CGFloat(bytes[pixelInfo]) / 255.0
        let g = CGFloat(bytes[pixelInfo + 1]) / 255.0
        let b = CGFloat(bytes[pixelInfo + 2]) / 255.0
        let a = CGFloat(bytes[pixelInfo + 3]) / 255.0
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
