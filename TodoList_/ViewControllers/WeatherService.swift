//
//  WeatherService.swift
//  todoList
//
//  Created by 박에스더 on 6/9/24.
//

import Foundation

class WeatherService {
    private let apiKey = "45a8410e0d64f53a22407b9862db3c8b"
    //OpenWeatherMap API 키
    private let weatherDescriptions: [String: String] = [
        "clear sky": "맑음☀️",
        "few clouds": "약간 흐림🌤️",
        "scattered clouds": "흐림 🌥️",
        "broken clouds": "구름 많음 ☁️",
        "shower rain": "소나기 🌦️",
        "rain": "비 🌧️",
        "thunderstorm": "뇌우 🌩️",
        "snow": "눈 ❄️",
        "mist": "안개 🌫️",
        // 추가 가능한 상태들
        "overcast clouds": "흐림 ☁️",
        "light rain": "가벼운 비 🌦️",
        "moderate rain": "적당한 비 🌧️",
        "heavy intensity rain": "강한 비 🌧️",
        "very heavy rain": "매우 강한 비 🌧️",
        "extreme rain": "극심한 비 🌧️",
        "light intensity shower rain": "가벼운 소나기 🌦️",
        "heavy intensity shower rain": "강한 소나기 🌧️",
        "ragged shower rain": "불규칙한 소나기 🌦️",
        "light snow": "가벼운 눈 ❄️",
        "heavy snow": "폭설 ❄️",
        "sleet": "진눈깨비 🌨️",
        "shower sleet": "소나기 진눈깨비 🌨️",
        "light rain and snow": "비와 눈 ❄️",
        "rain and snow": "비와 눈 ❄️",
        "light shower snow": "가벼운 소나기 눈 ❄️",
        "shower snow": "소나기 눈 ❄️",
        "heavy shower snow": "폭설 소나기 ❄️",
        "smoke": "연기 🌫️",
        "haze": "연무 🌫️",
        "sand/ dust whirls": "모래/먼지 소용돌이 🌪️",
        "fog": "안개 🌫️",
        "sand": "모래 🌪️",
        "dust": "먼지 🌪️",
        "volcanic ash": "화산재 🌋",
        "squalls": "돌풍 🌪️",
        "tornado": "토네이도 🌪️"
    ]
    
    func fetchWeather(for cityName: String, completion: @escaping (Result<(String, String, String, String, String, String), Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "WeatherService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "WeatherService", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                let message = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any]
                let errorMessage = message?["message"] as? String ?? "Unknown error"
                completion(.failure(NSError(domain: "WeatherService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                return
            }
            
            // JSON 데이터를 로깅하여 응답 구조를 확인합니다.
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON Response: \(jsonString)")
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let json = json,
                   let name = json["name"] as? String,
                   let weatherArray = json["weather"] as? [[String: Any]],
                   let weather = weatherArray.first,
                   let description = weather["description"] as? String,
                   let main = json["main"] as? [String: Any],
                   let temp = main["temp"] as? Double,
                   let tempMin = main["temp_min"] as? Double,
                   let tempMax = main["temp_max"] as? Double {
                    
                    let descriptionKR = self.weatherDescriptions[description.lowercased()] ?? description
                    completion(.success((name, descriptionKR, "\(temp)°C", "\(tempMin)°C", "\(tempMax)°C", description)))
                } else {
                    completion(.failure(NSError(domain: "WeatherService", code: 2, userInfo: [NSLocalizedDescriptionKey: "JSON parsing error"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
