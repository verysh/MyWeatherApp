//
//  ForecastController.swift
//  MyWeatherApp
//
//  Created by VLAD on 17/12/2017.
//  Copyright © 2017 Vlad. All rights reserved.
//

import UIKit


public enum WeatherAPIResult { // calls can succeed or fail!
    case success(Dictionary<String,Any>)
    case error(Error)
}

public protocol WeatherAPIRequests { // calls supported
    func getForecast(completion: @escaping (WeatherAPIResult) -> Void )
    func download(image fromUrl : URL, completion: @escaping (UIImage?) -> Void)
}

class NetworkController : WeatherAPIRequests {
    
    var foregroundSession : URLSession
    
    init() {
        foregroundSession = URLSession(configuration: URLSessionConfiguration.default)
    }
    
    private func restCall(url : URL,completion: @escaping (WeatherAPIResult) -> Void ) {
        let task = foregroundSession.dataTask(with: url, completionHandler: { (data : Data?, response : URLResponse?, error : Error?) -> Void in
            if let error = error {
                completion(.error(error))
            } else if let data = data {
                do {
                    let decoded = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String,Any>
                    completion(.success(decoded))
                } catch let e {
                    let string = String(data: data, encoding: String.Encoding.utf8)
                    print("\(string)")
                    completion(.error(e))
                }
            }
        });
        task.resume()
    }
    
    func getForecast(completion: @escaping (WeatherAPIResult) -> Void ) {

 
    }
    
    func download(image fromUrl : URL, completion: @escaping (UIImage?) -> Void) {
        let task = foregroundSession.dataTask(with: fromUrl) { (responseData, responseUrl, error) -> Void in
            if let data = responseData,
                let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    completion(image)
                }
            }
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        
        // Run task
        task.resume()
    }
}
