//
//  ViewController.swift
//  todoList
//
//  Created by 박에스더 on 6/9/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import CoreLocation

protocol SendDataDelegate {
    func sendData(oldTask: Todo?, newTask: Todo, indexPath: IndexPath?)
    func sendData(scheduledTasks: [String : [Todo]], newDate: Date)
}





class DailyTasksViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var tblTodo: UITableView!
    @IBOutlet weak var btnAdd: UIButton!
    @IBOutlet weak var btnEditTable: UIBarButtonItem!

    private var todoSections: BehaviorRelay<[Task]> = BehaviorRelay(value: [])
    private var dataSource: RxTableViewSectionedReloadDataSource<Task>!
    var viewModel = TodoListViewModel()
    var disposeBag = DisposeBag()
    var delegate: SendDataDelegate?

    // 날씨 뷰 관련 속성
    private let weatherView = WeatherView()
    private let locationManager = CLLocationManager()
    private let weatherService = WeatherService()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWeatherView()
        fetchWeather()

        let nibName = UINib(nibName: TodoTableViewCell.nibName, bundle: nil)
        tblTodo.register(nibName, forCellReuseIdentifier: TodoTableViewCell.identifier)
        tblTodo.rowHeight = UITableView.automaticDimension

        setupBindings()
    }

    func setupWeatherView() {
        weatherView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(weatherView)

        NSLayoutConstraint.activate([
            weatherView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            weatherView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            weatherView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            weatherView.heightAnchor.constraint(equalToConstant: 160)
        ])
        print("WeatherView added with frame: \(weatherView.frame)")
    }

    func fetchWeather() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
                if let error = error {
                    print("Reverse geocode error: \(error)")
                    return
                }
                guard let self = self else { return }
                if let placemark = placemarks?.first, let city = placemark.locality {
                    self.weatherService.fetchWeather(for: city) { (result: Result<(String, String, String, String, String, String), Error>) in
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let (cityName, condition, temperature, minTemperature, maxTemperature, description)):
                                self.weatherView.updateWeather(location: cityName, weatherStatus: condition, temperature: temperature, minTemperature: minTemperature, maxTemperature: maxTemperature)
                            case .failure(let error):
                                print("Error fetching weather: \(error)")
                            }
                        }
                    }
                }
            }
            locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager error: \(error)")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tblTodo.reloadData()
    }

    func setupBindings() {
        dataSource = RxTableViewSectionedReloadDataSource<Task>(configureCell: { (dataSource, tableView, indexPath, item: Todo) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: TodoTableViewCell.identifier, for: indexPath) as! TodoTableViewCell

            cell.bind(task: item)
            cell.btnCheckbox.indexPath = indexPath
            cell.btnCheckbox.addTarget(self, action: #selector(self.checkboxSelection(_:)), for: .touchUpInside)

            if let color = UIColor(hex: item.color ?? "") {
                cell.btnCheckbox.setColor(color)
                cell.backgroundColor = color
            } else {
                cell.btnCheckbox.setColor(.systemBlue)
                cell.backgroundColor = .white
            }

            return cell
        })

        Observable.zip(tblTodo.rx.modelSelected(Todo.self), tblTodo.rx.itemSelected)
            .bind { [weak self] (task: Todo, indexPath: IndexPath) in
                guard let addTaskVC = self?.storyboard?.instantiateViewController(identifier: AddTaskViewController.storyboardID) as? AddTaskViewController else { return }
                addTaskVC.editTask = task
                addTaskVC.indexPath = indexPath
                addTaskVC.delegate = self
                addTaskVC.currentDate = self?.viewModel.selectedDate.value

                self?.navigationController?.pushViewController(addTaskVC, animated: true)
            }
            .disposed(by: disposeBag)

        tblTodo.rx.itemDeleted
            .bind { indexPath in
                if indexPath.section == 0 {
                    _ = self.viewModel.remove(section: .scheduled, row: indexPath.row, date: nil)
                } else {
                    _ = self.viewModel.remove(section: .anytime, row: indexPath.row, date: nil)
                }
            }
            .disposed(by: disposeBag)

        tblTodo.rx.itemMoved
            .bind { [weak self] (srcIndexPath, dstIndexPath) in
                guard let self = self else { return }

                var movedTask: Todo?

                if srcIndexPath.section == 0 {
                    movedTask = self.viewModel.remove(section: .scheduled, row: srcIndexPath.row, date: nil)
                } else {
                    movedTask = self.viewModel.remove(section: .anytime, row: srcIndexPath.row, date: nil)
                }

                if let movedTask = movedTask {
                    if dstIndexPath.section == 0 {
                        self.viewModel.insert(task: movedTask, section: .scheduled, row: dstIndexPath.row, date: nil)
                    } else {
                        self.viewModel.insert(task: movedTask, section: .anytime, row: dstIndexPath.row, date: nil)
                    }
                }
            }
            .disposed(by: disposeBag)

        dataSource.titleForHeaderInSection = { ds, index in
            let date = ds.sectionModels[index].date
            return date.isEmpty ? Section.anytime.rawValue : "\(Section.scheduled.rawValue) \(date)"
        }

        todoSections.asDriver()
            .drive(tblTodo.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        Observable.combineLatest(viewModel.todoScheduled, viewModel.todoAnytime, viewModel.selectedDate)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] scheduled, anytime, date in
                let dateString = date.toString()
                self?.todoSections.accept([Task(date: dateString, items: scheduled[dateString] ?? []),
                                           Task(date: "", items: anytime)])
            })
            .disposed(by: disposeBag)
    }

    @IBAction func addTaskButtonPressed(_ sender: UIButton) {
        guard let addTaskVC = self.storyboard?.instantiateViewController(identifier: AddTaskViewController.storyboardID) as? AddTaskViewController else { return }
        addTaskVC.delegate = self
        addTaskVC.currentDate = viewModel.selectedDate.value

        self.navigationController?.pushViewController(addTaskVC, animated: true)
    }

    @IBAction func editTableButtonPressed(_ sender: UIBarButtonItem) {
        if tblTodo.isEditing {
            btnEditTable.title = "Edit"
            tblTodo.setEditing(false, animated: true)
        } else {
            btnEditTable.title = "Done"
            tblTodo.setEditing(true, animated: true)
        }
    }

    @IBAction func calendarButtonPressed(_ sender: UIBarButtonItem) {
        guard let calendarVC = self.storyboard?.instantiateViewController(identifier: CalendarViewController.storyboardID) as? CalendarViewController else { return }
        calendarVC.delegate = self
        calendarVC.todoScheduled = viewModel.todoScheduled.value
        calendarVC.selectedDate = viewModel.selectedDate.value

        let navController = UINavigationController(rootViewController: calendarVC)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: true, completion: nil)
    }

    @objc func checkboxSelection(_ sender: CheckUIButton) {
        guard let indexPath = sender.indexPath else { return }

        if indexPath.section == 0 {
            viewModel.changeComplete(section: .scheduled, row: indexPath.row)
            viewModel.moveTaskToBottom(section: .scheduled, row: indexPath.row, date: viewModel.selectedDate.value.toString())
        } else {
            viewModel.changeComplete(section: .anytime, row: indexPath.row)
            viewModel.moveTaskToBottom(section: .anytime, row: indexPath.row, date: nil)
        }

        tblTodo.reloadData()
    }
}

// MARK: - SendDataDelegate

extension DailyTasksViewController: SendDataDelegate {
    
    func sendData(scheduledTasks: [String : [Todo]], newDate: Date) {
        if !scheduledTasks.isEmpty {
            viewModel.todoScheduled.accept(scheduledTasks)
        }
        viewModel.selectedDate.accept(newDate)
    }
    
    func sendData(oldTask: Todo?, newTask: Todo, indexPath: IndexPath?) {
        let oldDate = oldTask?.date ?? ""
        let newDate = newTask.date ?? ""
        
        if let _ = oldTask, let index = indexPath {
            if oldDate.isEmpty {
                _ = viewModel.remove(section: .anytime, row: index.row, date: nil)
            } else {
                _ = viewModel.remove(section: .scheduled, row: index.row, date: oldTask?.date)
            }
        }
        
        if newDate.isEmpty {
            viewModel.insert(task: newTask, section: .anytime, row: indexPath?.row, date: nil)
        } else {
            viewModel.insert(task: newTask, section: .scheduled, row: indexPath?.row, date: newDate)
        }
        
        newTask.scheduleNotification() // 새로운 할 일에 대한 알림 설정
    }
}
