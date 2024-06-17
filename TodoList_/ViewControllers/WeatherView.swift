//
//  WeatherView.swift
//  todoList
//
//  Created by 박에스더 on 6/9/24.
//

import Foundation
import UIKit

class WeatherView: UIView {
    
    private let locationLabel = UILabel()
        private let conditionLabel = UILabel()
        private let temperatureLabel = UILabel()
        private let minMaxTemperatureLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
            let customBackgroundColor = UIColor(red: 106/255, green: 196/255, blue: 220/255, alpha: 1.0)
            backgroundColor = customBackgroundColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
                addGestureRecognizer(tapGesture)
            
            locationLabel.translatesAutoresizingMaskIntoConstraints = false
            conditionLabel.translatesAutoresizingMaskIntoConstraints = false
            temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
            minMaxTemperatureLabel.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(locationLabel)
            addSubview(conditionLabel)
            addSubview(temperatureLabel)
            addSubview(minMaxTemperatureLabel)
        
        NSLayoutConstraint.activate([
                    locationLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                    locationLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
                    
                    conditionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                    conditionLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 5),
                    
                    temperatureLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                    temperatureLabel.topAnchor.constraint(equalTo: conditionLabel.bottomAnchor, constant: 5),
                    
                    minMaxTemperatureLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                    minMaxTemperatureLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 5),
                    minMaxTemperatureLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
                ])
                locationLabel.font = UIFont.systemFont(ofSize: 35.0)
                locationLabel.textColor = .white
                conditionLabel.textColor = .white
                temperatureLabel.textColor = .white
                minMaxTemperatureLabel.textColor = .white
            }
    
    @objc private func handleTap() {
        if let parentViewController = self.parentViewController {
            let weatherListViewController = WeatherListViewController()
            let navigationController = UINavigationController(rootViewController: weatherListViewController)
            parentViewController.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func updateWeather(location: String, weatherStatus: String, temperature: String, minTemperature: String, maxTemperature: String) {
            locationLabel.text = location
            conditionLabel.text = translateWeatherStatus(weatherStatus)
            temperatureLabel.text = temperature
            minMaxTemperatureLabel.text = "최저: \(minTemperature)    최고: \(maxTemperature)"
        }
    private func translateWeatherStatus(_ status: String) -> String {
            let weatherTranslations: [String: (String, String)] = [
                "clear": ("맑음", "☀️"),
                "cloudy": ("흐림", "☁️"),
                "rain": ("비", "🌧"),
                "snow": ("눈", "❄️"),
                "thunderstorm": ("천둥", "⛈"),
                "mist": ("안개", "🌫"),
                "fog": ("짙은 안개", "🌫"),
                "drizzle": ("이슬비", "🌦")
            ]
            
            if let translation = weatherTranslations[status.lowercased()] {
                return "\(translation.1) \(translation.0)"
            } else {
                return status
            }
        }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            parentResponder = responder.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

