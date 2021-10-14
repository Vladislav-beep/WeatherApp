//
//  NetworkManager.swift
//  WeatherApp
//
//  Created by Владислав Сизонов on 14.10.2021.
//

import Foundation
import CoreLocation

struct NetworkManager {
    
    var onCoplition: ((CurrentWeather) -> Void)?
    
    enum RequestType {
        case cityName(city: String)
        case coordinate(latitude: CLLocationDegrees, longitude: CLLocationDegrees)
    }
    
    func fetchCurrentWeather(forRequestType requestType: RequestType) {
        var urlString = ""
        switch requestType {
        case .cityName(let city):
            urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&apikey=\(apiKey)&units=metric"
            
        case .coordinate(let latitude, let longitude):
            urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&apikey=\(apiKey)&units=metric"
        }
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { data, response, error in
            if let data = data {
                if let currentWeather = self.parseJSON(with: data) {
                    onCoplition?(currentWeather)
                }
            }
        }
        task.resume()
    }
    
    func parseJSON(with data: Data) -> CurrentWeather? {
        let decocder = JSONDecoder()
        
        do {
            let currentWeatherData = try decocder.decode(CurrentWeatherData.self, from: data)
            guard let currentWeather = CurrentWeather(currentWeatherData: currentWeatherData) else {
                return nil }
            return currentWeather
            
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return nil
    }
}

