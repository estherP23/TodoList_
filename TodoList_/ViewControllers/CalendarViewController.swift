//
//  CalendarViewController.swift
//  todoList
//
//  Created by 박에스더 on 6/9/24.
//

import UIKit
import FSCalendar
import RxSwift
import RxCocoa

class CalendarViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var tblTasks: UITableView!
    @IBOutlet weak var btnScope: UIBarButtonItem!
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Instance Properties
    
    static let storyboardID = "calendarTask"
    
    var delegate: SendDataDelegate?
    var todoScheduled: [String : [Todo]] = [:]
    var selectedDate = Date()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell 등록
        let nibName = UINib(nibName: TodoTableViewCell.nibName, bundle: nil)
        tblTasks.register(nibName, forCellReuseIdentifier: TodoTableViewCell.identifier)
        tblTasks.rowHeight = UITableView.automaticDimension
        
        // 이전에 선택한 날짜 표시
        calendar.select(selectedDate)
        
        // 달력 높이를 전체 뷰의 1/2로 초기화
        calendarHeightConstraint.constant = self.view.bounds.height / 2
        
        // 달력의 년월 글자 바꾸기
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        calendar.locale = Locale(identifier: "ko_KR")
       
        // 달력의 맨 위의 년도, 월의 색깔
        calendar.appearance.headerTitleColor = .systemPink
        // 달력의 요일 글자 색깔
        calendar.appearance.weekdayTextColor = .orange
        
        // 토,일 색상 변경
        calendar.calendarWeekdayView.weekdayLabels[0].textColor = UIColor(red: 255/255, green: 126/255, blue: 121/255, alpha: 1.0)
        calendar.calendarWeekdayView.weekdayLabels[6].textColor = calendar.calendarWeekdayView.weekdayLabels[0].textColor
    }
    
    // MARK: - Tableview DataSource
    
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoScheduled[selectedDate.toString()]?.count ?? 0
    }
    
   
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return selectedDate.toString()
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TodoTableViewCell.identifier, for: indexPath) as! TodoTableViewCell
        guard let task = todoScheduled[selectedDate.toString()]?[indexPath.row] else { return cell }
        
        
        cell.bind(task: task)
        
       
        cell.btnCheckbox.indexPath = indexPath
        cell.btnCheckbox.addTarget(self, action: #selector(checkboxSelection(_:)), for: .touchUpInside)
        
        return cell
    }
    
    // MARK: - Actions
    
 
    @objc func checkboxSelection(_ sender: CheckUIButton) {
        guard let indexPath = sender.indexPath else { return }
        
      
        todoScheduled[selectedDate.toString()]?[indexPath.row].isCompleted.toggle()
        
        tblTasks.reloadData()
        calendar.reloadData()
    }
    
    /* Done 버튼 클릭 */
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        // DailyTasks 화면으로 돌아가기
        /*delegate?.sendData(scheduledTasks: todoScheduled, newDate: selectedDate)
        dismiss(animated: true, completion: nil)*/
        
        
      
            delegate?.sendData(scheduledTasks: todoScheduled, newDate: selectedDate)
        self.dismiss(animated: true, completion: nil)
        
        
        /*guard let dailyTasksVC = self.storyboard?.instantiateViewController(identifier: "DailyTasksViewController") as? DailyTasksViewController else { return }
            dailyTasksVC.delegate = self.delegate
            dailyTasksVC.viewModel.todoScheduled.accept(todoScheduled)
            dailyTasksVC.viewModel.selectedDate.accept(selectedDate)
            
        let navController = UINavigationController(rootViewController: dailyTasksVC)
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)*/
    }
    
    
    @IBAction func changeScopeButtonPressed(_ sender: UIBarButtonItem) {
        if calendar.scope == .month {
            calendar.scope = .week
            btnScope.title = "Month"
        } else {
            calendar.scope = .month
            btnScope.title = "Week"
        }
    }
}

// MARK: - Calendar Delegate

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
   
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        tblTasks.reloadData()
    }
    
   
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
  
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if let tasks = todoScheduled[date.toString()], tasks.count > 0 { return 1 }
        return 0
    }
    
   
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if let tasks = todoScheduled[date.toString()] {
            //  빨간색 표시
            if tasks.filter({ $0.isCompleted == false }).count > 0 { return [UIColor.systemRed] }
            //  회색으로 표시
            return [UIColor.systemGray2]
        }
        return nil
    }
    
   
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        if let tasks = todoScheduled[date.toString()] {
          
            if tasks.filter({ $0.isCompleted == false }).count > 0 { return [UIColor.systemRed] }
           
            return [UIColor.systemGray2]
        }
        return nil
    }
}
