//
//  ViewController.swift
//  2048
//
//  Created by Flisk on 2024/12/14.
//

import UIKit

class ViewController: UIViewController, GameViewDelegate {

    private let size = 4
    private lazy var game = Game(size: size)
    
    // 计分label
    private let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = UIColor(r: 119, g: 110, b: 101)
        label.textAlignment = .left
        label.text = "Score: 0"
        return label
    }()
    
    // 在IB（storyboard）文件选中控件按住ctrl键进行拖拽
    @IBOutlet weak var gameView: GameView! {
        didSet {
            gameView.size = size
        }
    }
    
    @IBOutlet weak var resetButton: UIButton!
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        self.gameView.reset()
        self.game.start { (startCards) in
            self.gameView.performActions(startCards)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        gameView.delegate = self
        
        // 设置scoreLabel位置在gameView上方，左对齐
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        
        // 移除gameView原有的top约束，替换为新的约束
        if let existingTopConstraint = gameView.constraints.first(where: { $0.firstAttribute == .top }) {
            existingTopConstraint.isActive = false
        }
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scoreLabel.heightAnchor.constraint(equalToConstant: 30),
            gameView.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 10)
        ])
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCardLongPress(_:)),
            name: Notification.Name("CardLongPressed"),
            object: nil
        )
        
        // 延迟加载, 不写execute 直接添加延时任务
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.startGame()
        }
    }
    
    @objc private func handleCardLongPress(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let positionTuple = userInfo["position"] as? (Int, Int),
              let value = userInfo["value"] as? Int else {
            return
        }
        
        print("收到长按事件 - 位置: \(positionTuple), 值: \(value)")
        
        let position = Position(row: positionTuple.0, col: positionTuple.1)
        
        game.cleanCard(at: position)
        // 创建删除 action
        let deleteAction = Action.delete(at: position)
        // 在这里实现消除逻辑
        gameView.performActions([deleteAction])
    }
    
    private func startGame() {
        self.game.start { (startCards) in
            self.gameView.performActions(startCards)
        }
    }
    
    func slideEnded(offset: CGPoint) {
        let direction: Direction
        if offset.y > offset.x {
            if offset.y > -offset.x {
                direction = .down
            } else {
                direction = .left
            }
        } else {
            if offset.y > -offset.x {
                direction = .right
            } else {
                direction = .up
            }
        }
        
        game.move(direction) { (actions) in
            gameView.performActions(actions)
            
            // 检查 actions 数组中是否存在 failure 状态
            if actions.contains(.failure) {
                // 创建失败提示对话框
                let alert = UIAlertController(
                    title: "移动失败",
                    message: "该方向无法移动，请选择其他方向",
                    preferredStyle: .alert
                )
                
                // 添加重置游戏按钮
                alert.addAction(UIAlertAction(title: "确定", style: .destructive) { [weak self] _ in
                    self?.resetGame() // 调用重置游戏的方法
                })
                
                // 显示对话框
                self.present(alert, animated: true)
            }
        }
    }
    
    // 重置游戏的方法
    // TODO: 重置游戏界面
    func resetGame() {
        gameView.reset()
        game.reset()
        startGame()
    }

    
    // 欢迎提示
    func showWelcomeAlert() {
        let alert = UIAlertController(
            title: "欢迎来到2048",
            message: "滑动屏幕合并相同数字，创造出2048吧！",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: "开始游戏",
            style: .default,
            handler: nil
        ))
        
        present(alert, animated: true)
    }
    
    // 弹框
    func showSimpleAlert() {
        // 创建 AlertController，设置标题、消息和样式
        let alert = UIAlertController(
            title: "提示",
            message: "这是一个简单的 Alert 对话框",
            preferredStyle: .alert
        )
        
        // 添加按钮（Action）
        alert.addAction(UIAlertAction(
            title: "确定",
            style: .default,
            handler: { _ in
                print("用户点击了确定")
            }
        ))
        
        // 显示对话框
        present(alert, animated: true)
    }
    
    // MARK: - GameViewDelegate
    
    func updateScore(_ score: Int) {
        scoreLabel.text = "Score: \(score)"
    }
    
    func resetScore() {
        scoreLabel.text = "Score: 0"
    }

}

