//
//  ViewController.swift
//  WeatherApp
//
//  Created by Владислав Сизонов on 13.10.2021.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    var networkManager = NetworkManager()
    
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyBest
        lm.requestWhenInUseAuthorization()
        return lm
    }()

    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkManager.onCoplition = { [weak self] weather in
            self?.updateUI(weather: weather)
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestLocation()
        }
    }
    
    func updateUI(weather: CurrentWeather) {
        DispatchQueue.main.async {
            self.cityNameLabel.text = weather.cityName
            self.feelsLikeLabel.text = weather.feelsLikeTemperatureString
            self.temperatureLabel.text = weather.temperatureString
            self.weatherImage.image = UIImage(systemName: weather.systemIconNameString)
        }
       
    }

    @IBAction func searcCity(_ sender: UIButton) {
        showAlert(title: "Enter city", message: nil) { [unowned self] city in
            self.networkManager.fetchCurrentWeather(forRequestType: .cityName(city: city))
        }
    }
}

extension ViewController {
    func showAlert(title: String?, message: String?, completion: @escaping (String) -> (Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { textField in
            let cities = ["London", "Stambul"]
            textField.placeholder = cities.randomElement()
        }
        
        let search = UIAlertAction(title: "Search", style: .default) { action in
            let textField = alert.textFields?.first
            guard let city = textField?.text else { return }
            
            if city != "" {
                let city = city.split(separator: " ").joined(separator: "%20")
                completion(city)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(search)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let longitude = location.coordinate.longitude
        let latitude = location.coordinate.latitude
        
        networkManager.fetchCurrentWeather(forRequestType: .coordinate(latitude: latitude, longitude: longitude))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
}

