import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var navigationBtn: UIImageView!
    @IBOutlet weak var searchBtn: UIImageView!
    @IBOutlet weak var dataView: UITableView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var CitiesButton: UIButton!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var weatherInfo: UILabel!
    @IBOutlet weak var temperatureSegmentedControl: UISegmentedControl!
    
    let weatherService = WeatherService()
    let locationManager = CLLocationManager()
    var weatherDetails: [String] = []
    var allWeatherDetails: [[String]] = []
    var currentWeather: Weather?
    var isFahrenheit: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isFahrenheit")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isFahrenheit")
        }
    }
    var weatherDescription: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

        let searchTap = UITapGestureRecognizer(target: self, action: #selector(searchWeather))
        searchBtn.isUserInteractionEnabled = true
        searchBtn.addGestureRecognizer(searchTap)

        let locationTap = UITapGestureRecognizer(target: self, action: #selector(getCurrentLocation))
        navigationBtn.isUserInteractionEnabled = true
        navigationBtn.addGestureRecognizer(locationTap)

        dataView.dataSource = self
        dataView.register(UITableViewCell.self, forCellReuseIdentifier: "WeatherDetailCell")

        dataView.backgroundColor = UIColor.clear
        dataView.separatorStyle = .none

        setGradientBackground()

        // Set initial segmented control state based on UserDefaults
        temperatureSegmentedControl.selectedSegmentIndex = isFahrenheit ? 1 : 0
    }

    @objc func searchWeather() {
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            showAlert(title: "Input Required", message: "Please enter a location.")
            return
        }
        fetchWeather(for: searchText)
    }

    @objc func getCurrentLocation() {
        locationManager.startUpdatingLocation()
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    func fetchWeather(for city: String) {
        weatherService.fetchWeather(city: city) { [weak self] weather in
            guard let weather = weather else {
                print("Failed to fetch weather data")
                return
            }
            self?.currentWeather = weather
            self?.allWeatherDetails.append([
                "Location: \(weather.location.name)",
                "Temperature: \(weather.current.temp_c)°C",
                "Description: \(weather.current.condition.text)"
            ])
            self?.weatherDescription = weather.current.condition.text
            DispatchQueue.main.async {
                self?.refreshWeatherUI()
            }
        }
    }

    func refreshWeatherUI() {
        guard let weather = currentWeather else { return }
        updateUI(with: weather)
    }

    func updateUI(with weather: Weather) {
        let temperature = isFahrenheit ? weather.current.temp_f : weather.current.temp_c
        let temperatureUnit = isFahrenheit ? "°F" : "°C"

        weatherDetails = [
            "Location: \(weather.location.name), \(weather.location.region), \(weather.location.country)",
            "Temperature: \(temperature)\(temperatureUnit)",
            "Description: \(weather.current.condition.text)",
            "Wind Speed: \(weather.current.wind_kph) kph (\(weather.current.wind_mph) mph)",
            "Humidity: \(weather.current.humidity)%"
        ]

        weatherInfo.text = " \(weather.current.condition.text)"

        DispatchQueue.main.async {
            self.dataView.reloadData()
            self.animateTableView()

            var imageName = "defaultWeather"
            let description = weather.current.condition.text.lowercased()
            let windSpeed = weather.current.wind_kph
            let humidity = weather.current.humidity

            if description.contains("rain") || description.contains("storm") || description.contains("shower") || windSpeed > 20 || humidity < 80 {
                imageName = "rainy"
            } else if description.contains("clear") || description.contains("sunny") {
                imageName = "sunny"
            } else {
                imageName = self.getWeatherImageName(fromCode: weather.current.condition.code)
            }

            self.weatherImage.image = UIImage(named: imageName)

            self.updateBackgroundImage(for: weather)
        }
    }

    func updateBackgroundImage(for weather: Weather) {
        let timeComponents = weather.location.localtime.split(separator: " ")
        if timeComponents.count == 2 {
            let hourString = timeComponents[1].split(separator: ":")[0]
            if let hour = Int(hourString) {
                var imageName = "background2"
                if hour >= 6 && hour < 18 {
                    imageName = "background"
                }

                DispatchQueue.main.async {
                    self.backgroundImage.image = UIImage(named: imageName)
                }
            }
        }
    }

    func getWeatherImageName(fromCode code: Int) -> String {
        switch code {
        case 1000: return "sunny"
        case 1003, 1006: return "cloudy"
        case 1183, 1186, 1189: return "rainy"
        default: return "defaultWeather"
        }
    }


    func animateTableView() {
        let cells = dataView.visibleCells
        let tableViewHeight = dataView.bounds.size.height

        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }

        var delayCounter = 0
        for cell in cells {
            UIView.animate(withDuration: 1.75, delay: Double(delayCounter) * 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDetails.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherDetailCell", for: indexPath)
        cell.textLabel?.text = weatherDetails[indexPath.row]

        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)

        cell.textLabel?.shadowColor = UIColor.gray.withAlphaComponent(0.5)
        cell.textLabel?.shadowOffset = CGSize(width: 1, height: 1)
        cell.textLabel?.numberOfLines = 0

        return cell
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("Got location: \(location)")
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            fetchWeatherForLocation(latitude: lat, longitude: lon)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }

    func fetchWeatherForLocation(latitude: Double, longitude: Double) {
        let locationString = "\(latitude),\(longitude)"
        fetchWeather(for: locationString)
    }

    func setGradientBackground() {
        self.view.layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1.0).cgColor, // Light blue
            UIColor(red: 135/255, green: 206/255, blue: 250/255, alpha: 1.0).cgColor  // Light sky blue
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = self.view.bounds

        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }

    @IBAction func citiesButtonTapped(_ sender: UIButton) {
        if self.allWeatherDetails.isEmpty {
            print("Data is not ready.")
        } else {
            performSegue(withIdentifier: "ShowWeatherDetail", sender: self)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowWeatherDetail" {
            if let weatherHistoryVC = segue.destination as? CityDetailsViewController {
                print("Passing data: \(self.allWeatherDetails.count) items")
                weatherHistoryVC.allWeatherDetails = self.allWeatherDetails
            }
        }
    }

    // Handle segmented control value changed
    @IBAction func temperatureUnitChanged(_ sender: UISegmentedControl) {
        isFahrenheit = sender.selectedSegmentIndex == 1 // 1 for Fahrenheit, 0 for Celsius
        UserDefaults.standard.set(isFahrenheit, forKey: "isFahrenheit")

        if let weather = currentWeather {
            updateUI(with: weather)
        }
    }

}
