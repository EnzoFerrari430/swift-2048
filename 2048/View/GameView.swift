//
//  GameView.swift
//  2048
//
//  Created by Flisk on 2024/12/18.
//
//  游戏界面相关代码
import UIKit

// 手势相关 在ViewController中实现
protocol GameViewDelegate: AnyObject {
    func slideEnded(offset: CGPoint)
    func updateScore(_ score: Int)
    func resetScore()
    func playMergeSound()
    func playDeleteSound()
}

class GameView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    var size = 0
    var delegate: GameViewDelegate? = nil
    
    private var startLocation = CGPoint()
    private var touchingDetectable = true
    
    private let margin: CGFloat = 5.0
    
    // 只读计算属性
    private var drawBound: CGRect {
        // self.bounds
        // The bounds rectangle, which describes the view’s location and size in its own coordinate system.
        var bound = self.bounds
        bound.origin.x += margin; bound.origin.y += margin
        bound.size.width -= margin * 2; bound.size.height -= margin * 2
        return bound
    }
    
    // 获取每个单元格的大小
    private var boundSize: CGFloat {
        let viewWidth = drawBound.size.width
        return viewWidth / CGFloat(size)
    }
    
    // 获取每个卡片的大小
    private var cardSize: CGSize {
        return CGSize(width: boundSize - margin * 2, height: boundSize - margin * 2)
    }
    
    // 获取每个卡片的rect
    private func getRectOf(row: Int, col: Int) -> CGRect {
        var location = CGPoint(x: CGFloat(col) * boundSize, y: CGFloat(row) * boundSize)
        location.x += margin + drawBound.origin.x
        location.y += margin + drawBound.origin.y
        return CGRect(origin: location, size: cardSize)
    }
    
    override func draw(_ rect: CGRect) {
        UIColor(displayP3Red: 0.8, green: 0.75, blue: 0.71, alpha: 1).setFill()
        for row in 0..<size {
            for col in 0..<size {
                let rect = UIBezierPath(
                    roundedRect: getRectOf(row: row, col: col),
                    cornerRadius: 10.0
                )
                rect.fill()
            }
        }
    }
    
    // 计算当前分数并通知delegate
    private func notifyScoreUpdate() {
        var total = 0
        for subview in subviews {
            if let cardView = subview as? CardView {
                total += cardView.value
            }
        }
        delegate?.updateScore(total)
    }
    
    func performActions(_ actions: [Action]) {
        var hasMerge = false
        var hasDelete = false
        
        for action in actions {
            switch action {
            case .new(let position, let newValue):
                newCard(at: position, withValue: newValue)
            case .move(let from, let to):
                moveCard(from: from, to: to)
            case .upgrade(let from, let to, let newValue):
                upgrade(from: from, to: to, newValue: newValue)
                hasMerge = true
            case .delete(let position):
                delete(at: position)
                hasDelete = true
            default:
                break
            }
        }
        
        // 播放音效
        if hasMerge {
            delegate?.playMergeSound()
        }
        if hasDelete {
            delegate?.playDeleteSound()
        }
        
        notifyScoreUpdate()
    }
    
    func reset() {
        clearAllTiles()
        delegate?.resetScore()
    }
    
    // 清除所有卡片视图
    private func clearAllTiles() {
        // 方法1：遍历所有子视图，移除CardView类型的视图
        
//        for subview in subviews {
//            if subview is CardView {
//                // 添加淡出动画，使卡片消失更平滑
//                UIView.animate(withDuration: 0.2, animations: {
//                    subview.alpha = 0
//                }) { _ in
//                    subview.removeFromSuperview()
//                }
//            }
//        }
        
        
        // 方法2（替代方案）：直接移除所有子视图
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    // 获取当前位置上的CardView
    // as? 	向下转换
    private func getCardView(at position: Position) -> CardView? {
        return viewWithTag(tag(at: position)) as? CardView
    }
    
    private func tag(at position: Position) -> Int {
        return (1 + position.row) * 100 + position.col
    }
    
    private func newCard(at position: Position, withValue value: Int) {
        if let cardView = getCardView(at: position) {
            cardView.flash(withValue: value)
        } else {
            let newCardView = CardView(
                frame: getRectOf(row: position.row, col: position.col),
                value: value
            )
            newCardView.tag = tag(at: position)
            addSubview(newCardView)
            newCardView.createAnimation()
        }
    }
    
    private func moveCard(from: Position, to: Position, completion: (() -> Void)? = nil) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.06 * Double(max(abs(from.row - to.row), abs(from.col - to.col))),
            delay: 0.0,
            options: [],
            animations: {
                if let cardView = self.getCardView(at: from) {
                    cardView.frame = self.getRectOf(row: to.row, col: to.col)
                    cardView.tag = self.tag(at: to)
                }
            }){
                position in
                completion?()
            }
    }
    
    private func upgrade(from: Position, to: Position, newValue: Int) {
        // 1.移动卡片
        moveCard(from: from, to: to) {
            if let cardView = self.getCardView(at: to) {
                cardView.removeFromSuperview()
            }
            self.newCard(at: to, withValue: newValue)
        }
    }
    
    // 删除卡片
    private func delete(at position: Position) {
        if let cardView = getCardView(at: position) {
            // 如果卡片已经在删除动画中，不再重复触发
            cardView.breakBubbleEffect { [weak self] in
                // 动画完成后更新分数
                self?.notifyScoreUpdate()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            startLocation = touch.preciseLocation(in: self)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !touchingDetectable {
            return
        }
        
        if let touch = touches.first {
            let endLocation = touch.preciseLocation(in: self)
            if distance(between: endLocation, and: startLocation) > 50 {
                touchingDetectable = false
                let offset = endLocation - startLocation
                delegate?.slideEnded(offset: offset)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 如果释放的时候还能touchingDetectable
        // 则说明滑动的距离很小
        if touchingDetectable {
            if let touch = touches.first {
                let endLocation = touch.preciseLocation(in: self)
                let offset = endLocation - startLocation
                delegate?.slideEnded(offset: offset)
            }
        } else {
            touchingDetectable = true
        }
    }
    
    private func distance(between pointA: CGPoint, and pointB: CGPoint) -> Double {
        return sqrt(Double((pointA.x - pointB.x) * (pointA.x - pointB.x) + (pointA.y - pointB.y) * (pointA.y - pointB.y)))
    }

}

// 重载运算符
extension CGPoint {
    public static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}
