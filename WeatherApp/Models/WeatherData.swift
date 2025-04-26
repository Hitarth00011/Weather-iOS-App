//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Hitarth Rathod on 26/04/25.
//

import Foundation

struct WeatherResponse: Codable {
    let name: String
    let weather: [Weather]
    let main: Main
}

struct Weather: Codable {
    let main: String 
    let description: String
    let icon: String
}

struct Main: Codable {
    let temp: Double
}

struct ForecastResponse: Codable {
    let list: [Forecast]
}

struct Forecast: Codable {
    let dt: Double
    let main: Main
    let weather: [Weather]
}
