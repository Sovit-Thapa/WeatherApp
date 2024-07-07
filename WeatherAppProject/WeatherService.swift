//
//  WeatherService.swift
//  WeatherAppProject
//
//  Created by AJ on 2024-07-08.
//

import Foundation

class WeatherService {
    private let apiKey = "b21198709e144f86a06203221240707"
    
    func fetchWeather(city: String, completion: @escaping (Weather?) -> Void) {
        let baseUrl = "https://api.weatherapi.com/v1"
        let apiMethod = "/current.json"
        let queryString = "?key=\(apiKey)&q=\(city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        let urlString = baseUrl + apiMethod + queryString
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                let weather = try JSONDecoder().decode(Weather.self, from: data)
                completion(weather)
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}
