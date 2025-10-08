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
        /*
        game.start()
        game.debugPrint()
        game.move(.up)
        game.debugPrint()
        game.move(.down)
        game.debugPrint()
        game.move(.left)
        game.debugPrint()
        game.move(.right)
        game.debugPrint()
        */
        
        // 延迟加载, 不写execute 直接添加延时任务
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.startGame()
            // self.showSimpleAlert()
        }
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

}

