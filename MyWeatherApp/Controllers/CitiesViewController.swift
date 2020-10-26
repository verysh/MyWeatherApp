//
//  ViewController.swift
//  MyWeatherApp
//
//  Created by VLAD on 12/11/2017.
//  Copyright © 2017 Vlad. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MBProgressHUD
import CoreData
import SearchTextField

class CitiesViewController: UIViewController {

    var cities = [City]()
    var hud = MBProgressHUD()
    var filteredCities = [City]()
    var myTextField: SearchTextField!
    var textField = UITextField()
    var searchActive : Bool = false
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCityBarButtonItem: UIBarButtonItem!
    
    let searchController = UISearchController(searchResultsController: nil)
    var myCountries = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cities = CoreDataManager.sharedInstance.fetchRequest()
        searchBar.delegate = self
        searchBar.placeholder = "Search City.."
        searchBar.showsCancelButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    // MARK: Actions
    @IBAction func addCityTapped(_ sender: UIBarButtonItem) {
        if ServerManager.sharedManager.isConnectedToInternet() {
            displayCity()
        } else {
            Helper.showMessageOffline(vc: self)
        }
    }
    
    @IBAction func refreshCities(_ sender: UIBarButtonItem) {
        if ServerManager.sharedManager.isConnectedToInternet() {
            updateInfo()
        } else {
            Helper.showMessageOffline(vc: self)
        }
    }
    
    // MARK: Methods
    fileprivate func updateInfo() {
        for city in cities {
            ServerManager.sharedManager.getOpenWeatherMapRequestWithCityName(cityName:city.name!,
                                                                             onSuccess: { (weatherObject) in
                                                                                
                                                city.temp = weatherObject.temperature!
                                                CoreDataManager.sharedInstance.saveContext()
                                                self.tableView.reloadData()
                                            },
                                             onFailure: {(error) in
                                                print("error")
                                                
                                                let alert = UIAlertController(title: "Error",
                                                                              message:"No such city",
                                                                              preferredStyle: .alert)
                                                
                                                let actionCancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                                                alert.addAction(actionCancel)
                                                
                                                self.present(alert, animated: true, completion: nil)
                    })
        }
    }
    
    fileprivate func displayCity() {
        guard let popoverContent = self.storyboard?.instantiateViewController(withIdentifier: "AddCityViewController") as? AddCityViewController else { return }
        popoverContent.delegate = self
        navigationController?.pushViewController(popoverContent, animated: true)
    }
    
    fileprivate func requestWeather(city: String?) {
        ServerManager.sharedManager.getOpenWeatherMapRequestWithCityName(cityName:city!,
                         onSuccess: { (weatherObject) in
                            
                            CoreDataManager.sharedInstance.saveItem(city: weatherObject.cityName, temp: weatherObject.temperature, country: weatherObject.country)
                            
                            self.cities = CoreDataManager.sharedInstance.fetchRequest()
                            self.tableView.reloadData()
        },
                         onFailure: {(error) in
                            print("error")
                            
                            let alert = UIAlertController(title: "Error",
                                                          message:"No such city",
                                                          preferredStyle: .alert)
                            
                            let actionCancel = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alert.addAction(actionCancel)
                            
                            self.present(alert, animated: true, completion: nil)
        })
    }
    
}

extension CitiesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as? DetailWeatherViewController else { return }
        detailVC.model(model: searchActive ? filteredCities[indexPath.row] : cities[indexPath.row])
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = CoreDataManager.sharedInstance.managedObjectContext()
            context.delete(cities[indexPath.row] as NSManagedObject)
            cities.remove(at: indexPath.row)
            CoreDataManager.sharedInstance.saveContext()
            tableView.deleteRows(at: [indexPath], with: .none)
        }
    }
}

extension CitiesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchActive ? filteredCities.count : cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CityWeatherTableViewCell
        cell.configureCellWithModel(cityModel: searchActive ? filteredCities[indexPath.row] : cities[indexPath.row])
        return cell
    }
}

class Helper  {
    class func showMessageOffline(vc: UIViewController) {
        let actionSheetController: UIAlertController = UIAlertController(title: "Offline!", message: "Please, check your internet connection", preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        actionSheetController.addAction(okAction)
        vc.present(actionSheetController, animated: true, completion: nil)
    }
}

//MARK: - UISearchBarDelegate
extension CitiesViewController: UISearchBarDelegate {
    //MARK: - UISearchResultsUpdating
    //    func updateSearchResults(for searchController: UISearchController) {
    //        filteredCities = cities.filter({(city) -> Bool in
    //               city.name!.contains(searchController.searchBar.text!)
    //        })
    //        tableView.reloadData()
    //    }
    
    //MARK: UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = (filteredCities.count == 0) ? false : true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        searchBar.text = ""
        searchBar.showsCancelButton = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredCities = cities.filter({ (city) -> Bool in
            let tmp: NSString = city.name! as NSString
            let range = tmp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        searchActive = (filteredCities.count == 0) ? false : true
        self.tableView.reloadData()
    }
}
 
extension CitiesViewController: AddCityProtocol {
    func passAddedCity(city: String) {
        self.requestWeather(city: city)
    }
}
