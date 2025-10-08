//
//  Action.swift
//  2048
//
//  Created by Flisk on 2024/12/16.
//

import Foundation

//Swift的contains方法要求被比较的元素类型必须遵循 Equatable 协议。
enum Action: Equatable {
    case move(from: Position, to: Position)
    case upgrade(from: Position, to: Position, value: Int)
    case new(at: Position, value: Int)
    case success
    case failure
    case delete(at: Position) // 用于删除label
}
