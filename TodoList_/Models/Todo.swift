//
//  Todo.swift
//  todoList
//
//  Created by 박에스더 on 6/9/24.
//

import Foundation
import UserNotifications

struct Todo: Codable {
    var id: UUID
    var title: String
    var date: String?
    var time: String?
    var description: String?
    var isCompleted: Bool = false
    var color: String?
    var notificationTime: NotificationTime = .atTime
    var imageData: Data?

    enum NotificationTime: Int, Codable {
        case atTime = 0
        case fiveMinutesBefore = 5
        case tenMinutesBefore = 10
    }
    
    static let empty = Todo(id: UUID(), title: "", date: nil, time: nil, description: nil, isCompleted: false, color: nil, notificationTime: .atTime, imageData: nil)
    
    func scheduleNotification() {
        guard let date = date, let time = time, !isCompleted else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd a h:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        let dateTimeString = "\(date) \(time)"
        guard let taskDate = dateFormatter.date(from: dateTimeString) else {
            print("Invalid date format for string: \(dateTimeString)")
            return
        }
        
        let notificationDate: Date
        switch notificationTime {
        case .atTime:
            notificationDate = taskDate
        case .fiveMinutesBefore:
            notificationDate = taskDate.addingTimeInterval(-5 * 60)
        case .tenMinutesBefore:
            notificationDate = taskDate.addingTimeInterval(-10 * 60)
        }
        
        print("Scheduling notification at \(notificationDate)")

        if notificationDate <= Date() {
            print("Notification date is in the past. Notification will not be scheduled.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = "Your task '\(title)' is due soon."
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if let error = error {
                print("Notification scheduling error: \(error)")
            } else {
                print("Notification scheduled successfully")
            }
        })
    }
}
