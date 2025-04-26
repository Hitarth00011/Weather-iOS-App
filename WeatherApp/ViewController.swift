

import UIKit
import CoreLocation

class ViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate {
    
    let locationManager = CLLocationManager()
    var isFetchingWeather = false

    // UI Elements
    let searchBar = UISearchBar()
    let cityLabel = UILabel()
    let tempLabel = UILabel()
    let descLabel = UILabel()
    let weatherIcon = UIImageView()
    let activityIndicator = UIActivityIndicatorView(style: .large)

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: 100, height: 150)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    var forecastData: [Forecast] = []
    var dailyForecastData: [Forecast] = []  // Store the 5-day forecast

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupViews()
        setupConstraints()

        collectionView.dataSource = self
        collectionView.register(WeatherCell.self, forCellWithReuseIdentifier: WeatherCell.identifier)

        searchBar.delegate = self

        setupLocationUpdates()
    }

    func setupLocationUpdates() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func setupViews() {
        [searchBar, cityLabel, tempLabel, descLabel, weatherIcon, collectionView, activityIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()

        cityLabel.font = .boldSystemFont(ofSize: 24)
        tempLabel.font = .systemFont(ofSize: 48, weight: .semibold)
        descLabel.font = .systemFont(ofSize: 18)
        descLabel.textColor = .secondaryLabel
        weatherIcon.contentMode = .scaleAspectFit

        let refreshButton = UIButton(type: .system)
        refreshButton.setTitle("Refresh", for: .normal)
        refreshButton.addTarget(self, action: #selector(refreshLocation), for: .touchUpInside)
        refreshButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(refreshButton)

        NSLayoutConstraint.activate([
            refreshButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            refreshButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc func refreshLocation() {
        locationManager.startUpdatingLocation()
    }

    func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            cityLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tempLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 8),
            tempLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            descLabel.topAnchor.constraint(equalTo: tempLabel.bottomAnchor, constant: 4),
            descLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            weatherIcon.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 12),
            weatherIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherIcon.heightAnchor.constraint(equalToConstant: 80),
            weatherIcon.widthAnchor.constraint(equalToConstant: 80),

            collectionView.topAnchor.constraint(equalTo: weatherIcon.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.heightAnchor.constraint(equalToConstant: 200),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func updateWeather(for city: String) {
        isFetchingWeather = true
        activityIndicator.startAnimating()

        // Fetch current weather
        WeatherService.shared.fetchCurrentWeather(for: city) { result in
            DispatchQueue.main.async {
                self.isFetchingWeather = false
                self.activityIndicator.stopAnimating()
                switch result {
                case .success(let data):
                    self.cityLabel.text = data.name
                    self.tempLabel.text = "\(Int(data.main.temp))°C"
                    self.descLabel.text = data.weather.first?.description.capitalized
                    if let iconName = data.weather.first?.icon {
                        let urlString = "https://openweathermap.org/img/wn/\(iconName)@2x.png"
                        if let url = URL(string: urlString) {
                            DispatchQueue.global().async {
                                if let data = try? Data(contentsOf: url) {
                                    DispatchQueue.main.async {
                                        self.weatherIcon.image = UIImage(data: data)
                                    }
                                }
                            }
                        }
                    }
                case .failure(let error):
                    self.showError(error)
                }
            }
        }

        // Fetch 5-day forecast
        WeatherService.shared.fetchForecast(for: city) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.forecastData = data.list
                    self.dailyForecastData = self.extractOnePerDayForecast(from: self.forecastData)
                    self.collectionView.reloadData()
                case .failure(let error):
                    self.showError(error)
                }
            }
        }
    }

    func extractOnePerDayForecast(from forecasts: [Forecast]) -> [Forecast] {
        var daily: [String: Forecast] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for forecast in forecasts {
            let date = Date(timeIntervalSince1970: forecast.dt)
            let dayKey = formatter.string(from: date)

            if daily[dayKey] == nil {
                daily[dayKey] = forecast
            }
        }

        let sorted = daily.values.sorted { $0.dt < $1.dt }
        return Array(sorted.prefix(5))  // limit to 5 days
    }

    func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - UICollectionViewDataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dailyForecastData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherCell.identifier, for: indexPath) as? WeatherCell else {
            return UICollectionViewCell()
        }

        let forecast = dailyForecastData[indexPath.row]
        cell.tempLabel.text = "\(Int(forecast.main.temp))°"

        let date = Date(timeIntervalSince1970: forecast.dt)
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        cell.timeLabel.text = formatter.string(from: date)

        return cell
    }

    // MARK: - Search Bar Delegate Methods
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let city = searchBar.text, !city.isEmpty else { return }
        updateWeather(for: city)
        searchBar.resignFirstResponder()
    }
}

// MARK: - Location Manager Delegate
extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let city = placemarks?.first?.locality {
                self.updateWeather(for: city)
            }
        }

        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showError(error)
    }
}
