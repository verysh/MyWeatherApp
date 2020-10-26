//
//  DetailWeatherViewController.swift
//  MyWeatherApp
//
//  Created by VLAD on 13/11/2017.
//  Copyright © 2017 Vlad. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreLocation

class DetailWeatherViewController: UIViewController {
    
    var hud = MBProgressHUD()
    var locationManager:CLLocationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var currentCoordinate = CLLocationCoordinate2D()
    
    var cityID: Int!
    var selectedCity = String()
    var city: String!
    
    @IBOutlet weak var iconimgVIew: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var windSpeedLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var temperatureView: UIView!
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var forecastCollectionView: UICollectionView!
    @IBOutlet weak var forecastFiveDaysCollectionView: UICollectionView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var allLabels: [UILabel]!
    
    var forecastArray = [Weather]()
    var weatherForWeek = [DaysForeCast]()
    var cityModel : City!
    var identifier = "ForecastCell"
    var fiveDaysIdentifier = "ForecastFiveDaysCell"
    
    var myCity: String?
    func model(model: City) {
        cityModel = model
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        request()
        RateManager.showRatesController()
        setupLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    fileprivate func applyColor(desc: String) {
        for label in allLabels {
            label.textColor = desc.contains("n") ? .white : .black
        }
    }
    
    fileprivate func request() {
        if ServerManager.sharedManager.isConnectedToInternet() {
            statusLabel.isHidden = true
            if let city = cityModel.name {
                showSelectedCity(city: city)
            }
        } else {
            statusLabel.isHidden = false
            setupAllViewsOffline(city: cityModel)
        }
    }
    
    //MARK:-LocationManagerDelegate
    fileprivate func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK:-Actions
    @IBAction func actionGetCurrentLocation(_ sender: UIBarButtonItem) {
        if ServerManager.sharedManager.isConnectedToInternet() {
            if let myCurrentCuty = myCity {
                showSelectedCity(city: myCurrentCuty)
            }
        } else {
            Helper.showMessageOffline(vc: self)
        }
    }
    
   
    fileprivate func showSelectedCity(city: String) {
        ServerManager.sharedManager.getOpenWeatherMapRequestWithCityName(cityName:city,
                                         onSuccess: { (weatherObject) in
                                    self.setupAllViewsFromServerObject(weatherObject: weatherObject)
                                    guard let imageName = weatherObject.iconName else { return }
                                    self.configureBackgroundImage(imagedName: imageName)
                                    self.getforecastWeatherFromServer(cityID: weatherObject.cityID)
                                    self.getWeekWeatherFromOpenWeatherMapServer(cityID: weatherObject.cityID)
                                    self.slideWindAndHumitidyLabel()
                                    self.fadeInAnimationLabels()
                },
                                 onFailure: {(error) in
                                    self.alertErrorDescription(erorr: error!.localizedDescription)
                                    self.hud.hide(animated: true)
        })
    }
    
    // MARK:-Requests
    fileprivate func getOpenWeatherMapWithCoordinates()  {
        ServerManager.sharedManager.getOpenWeatherMapRequestWithCoordinate(coordinate: self.currentCoordinate,
           onSuccess: { (weatherObject) in
                self.setupAllViewsFromServerObject(weatherObject: weatherObject)
                let imageName = weatherObject.iconName
                self.configureBackgroundImage(imagedName: imageName!)
                self.getforecastWeatherFromServer(cityID: weatherObject.cityID)
                self.slideWindAndHumitidyLabel()
                self.fadeInAnimationLabels()
            },
           onFailure: {(error) in
            self.alertErrorDescription(erorr: error!.localizedDescription)
            self.hud.hide(animated: true)
        })
    }
    
    fileprivate func getforecastWeatherFromServer(cityID: Int) {
        ServerManager.sharedManager.getOpenWeatherMapRequestForecastWithCityID(cityID:cityID,
                                                                                country:self.cityModel.country!,
                                   onSuccess: { (weatherObject) in
                                    var tempArray = [Weather]()
                                    for _ in 0...10 {
                                        tempArray.append(weatherObject)
                                    }

                                    self.forecastArray = tempArray
                                    DispatchQueue.main.async {
                                        self.forecastCollectionView.reloadData()
                                    }
            }, onFailure: {(error) in
                    self.alertErrorDescription(erorr: (error?.localizedDescription)!)
        })
    }
    
    fileprivate func getWeekWeatherFromOpenWeatherMapServer(cityID: Int) {
        ServerManager.sharedManager.getWeatherFromOpenWeatherMapServerWithCityID(cityID:cityID, onSuccess:  { (weatherObject) in
            self.weatherForWeek = weatherObject
            DispatchQueue.main.async {
                self.forecastFiveDaysCollectionView.reloadData()
            }
        }, onFailure: {(error) in
            guard let error = error else { return }
            self.alertErrorDescription(erorr: (error.localizedDescription))
        })
    }
    
    //MARK: - UI
    fileprivate func setupAllViewsFromServerObject(weatherObject: Weather) {
        self.cityNameLabel.text = "\(weatherObject.cityName),\(weatherObject.country)"
        self.currentTimeLabel.text = "\(Date().weekdayNameFull), \(weatherObject.currentTime)"
        self.temperatureLabel.text = "\(String(weatherObject.temperature))°"
        self.windSpeedLabel.text = String(weatherObject.windSpeed)
        self.humidityLabel.text = String(weatherObject.humidity)
        self.descriptionLabel.text = weatherObject.weatherDescription
        self.cityID = weatherObject.cityID
        if weatherObject.icon != nil {
            DispatchQueue.main.async(execute: {
                self.iconimgVIew.image = weatherObject.icon
                self.hud.hide(animated: true)
            })
        }
    }
    
    fileprivate func setupAllViewsOffline(city: City) {
        self.cityNameLabel.text = "\(city.name!), \(city.country!)"
        self.temperatureLabel.text = "\(city.temp)"
    }
    
    //MARK:-HelpedMethods
    fileprivate func configureBackgroundImage(imagedName: String) {
        let image = AdditionalMethods.method.configureBackgroundImage(iconImage: imagedName)
        self.backgroundImg.image = image
        self.view.backgroundColor = UIColor(patternImage: self.backgroundImg.image!)
        applyColor(desc:imagedName)
    }
    fileprivate func alertErrorDescription(erorr:String) {
        let alert = UIAlertController(title: "Error",
                                      message:erorr,
                                      preferredStyle: UIAlertControllerStyle.alert)
        let actionCancel = UIAlertAction(title: "Ok",
                                         style: UIAlertActionStyle.cancel,
                                         handler: nil)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func activityIndicatorStart()  {
        self.hud.label.text = "Loading..."
        self.view.addSubview(hud)
        self.hud.show(animated: true)
    }
    fileprivate func slideWindAndHumitidyLabel() {
        self.windSpeedLabel.transform = CGAffineTransform(translationX: -150, y: 0).scaledBy(x: 2, y: 2)
        self.humidityLabel.transform = CGAffineTransform(translationX: 150, y: 0).scaledBy(x: 2, y: 2)
        
        UIView.animate(withDuration: 0.7, delay: 0.5, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.9, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.windSpeedLabel.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1, y: 1)
            self.humidityLabel.transform = CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1, y: 1)
        }, completion: { (finished) in
        })
    }
    fileprivate func fadeInAnimationLabels() {
        self.temperatureView.alpha = 0
        self.descriptionLabel.alpha = 0
        self.currentTimeLabel.alpha = 0
        self.cityNameLabel.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            self.temperatureView.alpha = 1
            self.descriptionLabel.alpha = 1
            self.currentTimeLabel.alpha = 1
            self.cityNameLabel.alpha = 1
        })
    }
    
    fileprivate func displayCity(placemark: CLPlacemark) {
        city = "\(String(describing: placemark.locality)), \(String(describing: placemark.administrativeArea))"
    }
}

extension DetailWeatherViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0.0
        UIView.animate(withDuration: 0.7, animations: {
            cell.alpha = 1.0
        })
    }
}
extension DetailWeatherViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (collectionView == self.forecastCollectionView) ?  self.forecastArray.count : self.weatherForWeek.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: (collectionView == self.forecastCollectionView) ? identifier : fiveDaysIdentifier, for: indexPath) as? ForecastCollectionViewCell else { return  UICollectionViewCell() }
        cell.indexPath = indexPath
        let model = (collectionView == self.forecastCollectionView) ?  self.forecastArray[indexPath.item] : self.weatherForWeek[indexPath.item]
        cell.configureCell(model: model)
        return cell
    }
}
extension DetailWeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Followed this tutorial for the next piece:
        // http://www.veasoftware.com/tutorials/2014/10/18/xcode-6-tutorial-ios-8-current-location-in-swift
        CLGeocoder().reverseGeocodeLocation(manager.location!) { (placemarks, error) in
            
            if error != nil {
                self.myCity = "Error retrieving city."
            }
            
            if placemarks!.count > 0 {
                let placemark = placemarks![0] as CLPlacemark
//                self.displayCity(placemark: placemark)
                self.myCity = placemark.locality
            } else {
                self.myCity = "Error with data."
            }
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekdayOrdinal], from: self).weekday
    }
    func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
    }
    var weekdayNameFull: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    var weekdayAndDateNameFull: String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "EEEE, MM-dd HH:mm"
        return formatter.string(from: self)
    }
}
