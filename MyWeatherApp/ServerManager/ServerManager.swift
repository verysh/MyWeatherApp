//
//  ServerManager.swift
//  MyWeatherApp
//
//  Created by VLAD on 17/11/2017.
//  Copyright © 2017 Vlad. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import CoreLocation

var stringURL: String = "http://api.openweathermap.org/data/2.5/weather?"
var stringForecastURL: String = "http://api.openweathermap.org/data/2.5/forecast?"
var stringOpenWeatherMapHistory =  "http://history.openweathermap.org/data/2.5/history/city?" // платное
var appID: String = "53a690256a86a24b2a24d7d10aaccd1b" //  37bf77fd2230b3edb5dc9c1b7df083dc  OpenWeatherMap
var appKeyWeatherstackKey: String = "85e8fe61e96a1c110fd5c7935ea9ae5c" // weatherstack,  APIXU Weather API
var stringForecastURLWeatherstack: String = "http://api.weatherstack.com/forecast?"


class ServerManager {
    
    static let sharedManager = ServerManager()
    
    
    func getOpenWeatherMapRequestWithCityName(cityName:String,
                                               onSuccess:@escaping(_ weatherObject:Weather) -> (),
                                               onFailure:@escaping(_ error: Error?) -> ()) {
        
        let params = ["q" : cityName,
                      "APPID" : appID]
        
        Alamofire.request(stringURL, method: .get,parameters: params)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let weatherObject = Weather(response: json)
                    weatherObject.setWeatherProperties()
                    onSuccess(weatherObject)
                    
                case .failure(let error):
                    onFailure(error)
                }
        }
    }
    
    func getOpenWeatherMapRequestWithCoordinate(coordinate:CLLocationCoordinate2D,
                                                 onSuccess:@escaping(_ weatherObject:Weather) -> (),
                                                 onFailure:@escaping(_ error: Error?) -> ()) {
        let params = ["lat" : coordinate.latitude,
                      "lon" : coordinate.longitude,
                      "APPID" : appID] as [String : Any]
        
        Alamofire.request(stringURL, method: .get,parameters: params)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let weatherObject = Weather(response:json)
                    weatherObject.setWeatherProperties()
                    onSuccess(weatherObject)
                case .failure(let error):
                    onFailure(error)
                }
        }
    }
    
    func getOpenWeatherMapRequestForecastWithCityID(cityID:Int,
                                                    country:String,
                                                     onSuccess:@escaping(_ weatherObject:Weather) -> (),
                                                     onFailure:@escaping(_ error: Error?) -> ()) {
        
        let params = ["id" : cityID,
                      "APPID" : appID] as [String : Any]
        
        Alamofire.request(stringForecastURL, method: .get,parameters: params)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let weatherObject = ForecastWeather(response:json)
                    weatherObject.setWeatherProperties()
                    onSuccess(weatherObject)
                case .failure(let error):
                    onFailure(error)
                }
        }
    }

    func getWeatherFromServer(onSuccess:@escaping(_ weatherObject:Weather) -> (),
                              onFailure:@escaping(_ error: Error?) -> ())
    {
        let url: URL = URL.init(string: stringURL)!
        let urlRequest = URLRequest.init(url: url)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest,
                                    completionHandler: {
                                        (location, response,error) in
                                        guard error == nil else {
                                            return
                                        }
                                        guard let responseData = location else {
                                            return
                                        }
                                        do {
                                            guard let weatherJSON = try JSONSerialization.jsonObject(with:responseData, options:[]) as? JSON
                                                else {
                                                    return
                                            }
                                            let weatherObject = Weather.init(response: weatherJSON)
                                            weatherObject.setWeatherProperties()
                                            onSuccess(weatherObject)
                                            guard weatherJSON["title"].string != nil else {
                                                return
                                            }
                                        } catch  {
                                            onFailure(error)
                                            return
                                        }
        })
        task.resume()
    }
    
    func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    func getWeatherFromOpenWeatherMapServerWithCityID(cityID: Int, onSuccess:@escaping(_ weatherObject:[DaysForeCast]) -> (),
                                                          onFailure:@escaping(_ error: Error?) -> ()) {
        
        let params = ["id" : cityID,
                      "APPID" : appID] as [String : Any]
        
        Alamofire.request(stringForecastURL, method:.get,parameters: params)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    var weathersWeeks = [DaysForeCast]()
                    
                    if let count = json["cnt"].int {
                        for indx in 0..<count {
                            let weatherWeek = DaysForeCast(response: json, indx: indx)
                            weathersWeeks.append(weatherWeek)
                        }
                    }
                    
                    onSuccess(weathersWeeks)
                    print("json:\n\(json)")
                case .failure(let error):
                    onFailure(error)
                }
            }
    }
    
  
    
    
}




