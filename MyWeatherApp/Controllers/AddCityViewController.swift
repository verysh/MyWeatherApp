//
//  AddCityViewController.swift
//  MyWeatherApp
//
//  Created by VLAD on 12/09/2018.
//  Copyright © 2018 Vlad. All rights reserved.
//

import UIKit
import SearchTextField
import Alamofire

enum Actions: Int {
    case OK = 1
    case Cancel = 2
}

protocol AddCityProtocol: class {
    func passAddedCity(city: String)
}

class AddCityViewController: UIViewController {

    @IBOutlet weak var cityTextField: SearchTextField!
    @IBOutlet weak var okBtn: UIButton!
    @IBOutlet weak var citiesTableView: UITableView!
    weak var delegate: AddCityProtocol?
    var citiesModel = [CityModel]()
    var filtredDatasource = [CityModel]()
    var identifier = "citySearchIdentifier"
    var spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Add City"
        let textAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.tintColor = .white
//        configureSimpleSearchTextField(textField: cityTextField)
        cityTextField.delegate = self
        cityTextField.addTarget(self, action: #selector(AddCityViewController.textFieldDidChange(_:)), for: .editingChanged)
        okBtn.isEnabled = false
        okBtn.alpha = 0.5
        citiesTableView.isHidden = true
        addSpinner()
        DispatchQueue.global(qos: .background).async {
            self.localCountries()
        }
    }
    
    fileprivate func addSpinner() {
        spinner.color = .black
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: citiesTableView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: citiesTableView.centerYAnchor).isActive = true
    }
    
    fileprivate func localCountries() {
        //        var url: String = "https://raw.githubusercontent.com/meMo-Minsk/all-countries-and-cities-json/master/countries.json"
        //        url = "https://raw.githubusercontent.com/lutangar/cities.json/master/cities.json"
        //
        //        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default)
        //            .responseJSON { response in
        //                if let result = response.result.value as? Array<Any>  {
        //                    for item in result {
        //                        if let jsonResult = item as? Dictionary<String, String> {
        //                            guard let name = jsonResult["name"] else { return }
        //                            guard let country = jsonResult["country"] else { return }
        //                            self.citiesModel.append(CityModel(city: name, country: country))
        //                        }
        //                    }
        //                }
        //            }
        
        if let path = Bundle.main.path(forResource: "countries", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Array<Any> {
                    for item in jsonResult {
                        if let json = item as? Dictionary<String, String> {
                            guard let name = json["capital"] else { return }
                            guard let country = json["country"] else { return }
                            self.citiesModel.append(CityModel(city: name, country: country))
                        }
                    }
                    DispatchQueue.main.async {
                        self.spinner.isHidden = true
                        self.citiesTableView.reloadData()
                    }
                }
            } catch {
                let alert  = UIAlertController(title: "Error!", message: "Error to fetch cities", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func selectCity(city: String) {
        if let delegate = delegate {
            delegate.passAddedCity(city: city)
            navigationController?.popViewController(animated: true)
        }
    }
    
    fileprivate func configureSimpleSearchTextField(textField: SearchTextField) {
        // Start visible even without user's interaction as soon as created - Default: false
//        textField.startVisibleWithoutInteraction = false
//        textField.filterStrings(myCountries)
    }
  
    @IBAction func sendBtnAction(_ sender: UIButton) {
        switch sender.tag {
        case Actions.OK.rawValue:
            guard let city = cityTextField.text else { return }
            selectCity(city: city)
        case Actions.Cancel.rawValue:
            navigationController?.popViewController(animated: true)
        default:
            break;
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        citiesTableView.isHidden = (textField.text?.count != 0 && textField.text != " ") ? false : true
        if (textField.text?.count != 0 && textField.text != " ") {
            let resultPredicate = NSPredicate(format:"self contains[cd] %@", self.cityTextField.text!)
            self.filtredDatasource = self.citiesModel.filter({
                return resultPredicate.evaluate(with: $0.city)
            })
        } else {
            self.filtredDatasource = self.citiesModel
        }
        citiesTableView.reloadData()
    }
}

extension AddCityViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            okBtn.isEnabled = (updatedText.count == 0) ? false : true
            okBtn.alpha = (updatedText.count == 0) ? 0.5 : 1
        }
        return true
    }
}

extension AddCityViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filtredDatasource.count;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let indexPath = self.citiesTableView.indexPathForSelectedRow else { return }
        guard let currentCell = self.citiesTableView.cellForRow(at: indexPath) as? CityModelTableViewCell else { return }
        guard let city = currentCell.cityLabel.text else { return }
        selectCity(city: city)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AddCityViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? CityModelTableViewCell else { return UITableViewCell() }
        let cityModel = self.filtredDatasource[indexPath.row]
        cell.configureCell(model: cityModel)
        return cell
    }
}
