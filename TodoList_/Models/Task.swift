//
//  Task.swift
//  TodoList_
//
//  Created by 박에스더 on 6/17/24.
//

import Foundation
//
//  Task.swift
//  todoList
//
//  Created by 박에스더 on 6/9/24.
//

import Foundation
import RxDataSources

struct Task {
    var date: String
    var items: [Todo]
}

extension Task: SectionModelType {
    typealias Item = Todo
    
    init(original: Task, items: [Item]) {
        self = original
        self.items = items
    }
}
