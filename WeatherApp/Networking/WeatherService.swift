//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Hitarth Rathod on 26/04/25.
//

import Foundation

class WeatherService {
    static let shared = WeatherService()
    private let apiKey = "8dccf0ff89d1e02c2910871991b52244"

    func fetchCurrentWeather(for city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&units=metric&appid=\(apiKey)"
        performRequest(with: urlString, completion: completion)
    }

    func fetchForecast(for city: String, completion: @escaping (Result<ForecastResponse, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&units=metric&appid=\(apiKey)"
        performRequest(with: urlString, completion: completion)
    }

    private func performRequest<T: Decodable>(with urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
