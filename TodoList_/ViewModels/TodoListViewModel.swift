//
//  TodoListViewModel.swift
//  todoList
//
//  Created by 박에스더 on 6/9/24.
//

import Foundation
import RxSwift
import RxCocoa

enum Section: String {
    case scheduled = "Scheduled"
    case anytime = "Anytime"
}

enum DefaultsKey {
    static let isFirstLaunch = "isFirstLaunch"
}

class TodoListViewModel: NSObject {
    var todoScheduled = BehaviorRelay<[String : [Todo]]>(value: [:])    // e.g. "2024-06-17" : [Todo]
    var todoAnytime = BehaviorRelay<[Todo]>(value: [])
    var selectedDate = BehaviorRelay<Date>(value: Date())
    
    var disposeBag = DisposeBag()
    
    override init() {
        super.init()
        
        
        if nil != UserDefaults.standard.value(forKey: DefaultsKey.isFirstLaunch) {
            loadAllData()
        } else {
            loadFirstData()
        }
        
        
        _ = todoScheduled
            .subscribe(onNext: { [weak self] in
                self?.saveData(data: $0, key: Section.scheduled.rawValue)
            })
            .disposed(by: disposeBag)
        
        _ = todoAnytime
            .subscribe(onNext: { [weak self] in
                self?.saveData(data: $0, key: Section.anytime.rawValue)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Data Processing
    
    
    func saveData<T: Encodable>(data: T, key: String) {
        let userDefaults = UserDefaults.standard
        let encoder = JSONEncoder()
        
        if let jsonData = try? encoder.encode(data) {
            if let jsonString = String(data: jsonData, encoding: .utf8){
                userDefaults.set(jsonString, forKey: key)
            }
        }
        
        userDefaults.synchronize()
    }
    
  
    func loadAllData() {
        let userDefaults = UserDefaults.standard
        let decoder = JSONDecoder()
        
        // Scheduled
        if let jsonString = userDefaults.value(forKey: Section.scheduled.rawValue) as? String {
            if let jsonData = jsonString.data(using: .utf8),
               let scheduledData = try? decoder.decode([String : [Todo]].self, from: jsonData) {
                todoScheduled.accept(scheduledData)
            }
        }
        
        // Anytime
        if let jsonString = userDefaults.value(forKey: Section.anytime.rawValue) as? String {
            if let jsonData = jsonString.data(using: .utf8),
               let anytimeData = try? decoder.decode([Todo].self, from: jsonData) {
                todoAnytime.accept(anytimeData)
            }
        }
    }
    
    
    func loadFirstData() {
        let userDefaults = UserDefaults.standard
        let date = selectedDate.value.toString()
        
        userDefaults.setValue(false, forKey: DefaultsKey.isFirstLaunch)
        self.todoScheduled.accept([date : [Todo(id: UUID(), // 여기에서 id를 추가합니다.
                                                title: "Create new task",
                                                date: date,
                                                time: "8:00 PM",
                                                description: "Click the plus button to add a scheduled task.")]])
        self.todoAnytime.accept([Todo(id: UUID(), // 여기에서 id를 추가합니다.
                                      title: "Update your task",
                                      date: "",
                                      time: "",
                                      description: "This task has not yet been scheduled.")])
        userDefaults.synchronize()
    }
    
    // MARK: - Tasks
    
    /* 체크박스 변경 */
    func changeComplete(section: Section, row: Int) {
        if section == .scheduled {
            var tasks = todoScheduled.value
            let date = selectedDate.value.toString()
            tasks[date]?[row].isCompleted.toggle()
            todoScheduled.accept(tasks)
        } else if section == .anytime {
            var tasks = todoAnytime.value
            tasks[row].isCompleted.toggle()
            todoAnytime.accept(tasks)
        }
    }
    
    /* Todo 추가 */
    func insert(task:Todo, section: Section, row: Int?, date: String?) {
        var task = task
        
        if section == .scheduled {
            var scheduled = todoScheduled.value
            let date = date ?? selectedDate.value.toString()
            var newTasks = todoScheduled.value[date] ?? []
            
            task.date = date
            if let row = row { newTasks.insert(task, at: row) }
            else { newTasks.append(task) }
            
            scheduled[date] = newTasks
            todoScheduled.accept(scheduled)
        } else if section == .anytime {
            var anytime = todoAnytime.value
            
            task.date = ""
            task.time = ""
            if let row = row { anytime.insert(task, at: row) }
            else { anytime.append(task) }
            
            todoAnytime.accept(anytime)
        }
    }
    
    /* Todo 제거 */
    func remove(section: Section, row: Int, date: String?) -> Todo? {
        var removedTask: Todo?
        
        if section == .scheduled {
            var scheduled = todoScheduled.value
            let date = date ?? selectedDate.value.toString()
            
            removedTask = scheduled[date]?.remove(at: row)
            todoScheduled.accept(scheduled)
        } else if section == .anytime {
            var anytime = todoAnytime.value
            
            removedTask = anytime.remove(at: row)
            todoAnytime.accept(anytime)
        }
        
        return removedTask
    }
    
    func moveTaskToBottom(section: Section, row: Int, date: String?) {
            switch section {
            case .scheduled:
                guard var tasks = todoScheduled.value[date ?? ""] else { return }
                let task = tasks.remove(at: row)
                tasks.append(task)
                todoScheduled.accept([date ?? "": tasks])
            case .anytime:
                var tasks = todoAnytime.value
                let task = tasks.remove(at: row)
                tasks.append(task)
                todoAnytime.accept(tasks)
            }
        }
}
