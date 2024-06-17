//
//  WeatherListViewController.swift
//  todoList
//
//  Created by 박에스더 on 6/17/24.
//

import Foundation
import UIKit

class WeatherListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView()
    private let weatherService = WeatherService()
    
    private var cities: [String] = [
        "Seoul",
        "New York",
        "London",
        "Paris",
        "Tokyo"
    ]
    
    private var weatherData: [(String, String, String, String, String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Weather"
        
        setupTableView()
        fetchWeatherData()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WeatherCell")
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func fetchWeatherData() {
        weatherData = []  // 초기화
        let dispatchGroup = DispatchGroup()
        
        for city in cities {
            dispatchGroup.enter()
            weatherService.fetchWeather(for: city) { [weak self] result in
                guard let self = self else {
                    dispatchGroup.leave()
                    return
                }
                switch result {
                case .success(let weather):
                    self.weatherData.append((city, weather.1, weather.2, weather.3, weather.4, weather.5))
                case .failure(let error):
                    print("Failed to fetch weather for \(city): \(error)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCell", for: indexPath)
        let weather = weatherData[indexPath.row]
        cell.textLabel?.text = "\(weather.0): \(weather.1) \(weather.2)"
        return cell
    }
}
