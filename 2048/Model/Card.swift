//
//  Card.swift
//  2048
//
//  Created by Flisk on 2024/12/14.
//

import Foundation

// 每张卡片有一个数值信息
// 有两个操作 获取数值和数值加倍
class Card {
    
    private var value = 0
    
    init(value: Int = 0) {
        self.value = value
    }
    
    func getValue() -> Int {
        return value
    }
    
    func upgrade() -> Int {
        value *= 2
        return value
    }
    
}
