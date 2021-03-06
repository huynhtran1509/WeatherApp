//
//  ViewController.swift
//  Rainyapp
//
//  Created by Khoa on 8/7/16.
//  Copyright © 2016 Khoa. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation
class WeatherVC : UIViewController , UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
   
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var currentWeatherTypeLbl: UILabel!
    @IBOutlet weak var currentTempLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    var forecasts = [Forecast]()

    var currentWeather : CurrentWeather!
    
    var locationManager =  CLLocationManager()
    var currentlocation : CLLocation!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.allowsSelection = false
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        currentWeather = CurrentWeather()
      
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationAuthStatus()
    }
    func locationAuthStatus(){
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse{
           currentlocation = locationManager.location
            
            Location.instance.latitude = currentlocation.coordinate.latitude
            Location.instance.longitude = currentlocation.coordinate.longitude
            
           
            print("||||||||||||||||||||||||||||||||||||||||||||||||||||||| ")
            print(Location.instance.latitude, Location.instance.longitude)
            print(CURRENT_WEATHER_URL)
          
            
            
            currentWeather.downloadWeatherDetails {
                // self.updateMainUI()
                self.downloadForecastWeather {
                    self.updateMainUI()
                }
            }
            
            
        }
        else
        {
            locationManager.requestWhenInUseAuthorization()
            locationAuthStatus()
        }
    }
    func downloadForecastWeather(completed : DownloadComplete)
    {
        //let forecastURL = URL(string: FORECAST_WEATHER_URL)!
        Alamofire.request(.GET , FORECAST_WEATHER_URL).responseJSON{
            response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, AnyObject>{
                if let list = dict["list"] as? [Dictionary<String, AnyObject>] {
                    for obj in list {
                        let tempForecast = Forecast(weatherDict: obj)
                        self.forecasts.append(tempForecast)
                     /*   print(tempForecast.date)
                        print(tempForecast.minTemp)
                        print(tempForecast.maxTemp)
                        print(tempForecast.weatherType)
                        */
                    
                    }
                    self.tableView.reloadData()
                }
            }
            
            completed()
        }
    
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecasts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if  let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for:  indexPath  ) as? WeatherCell{
            
            let forecastCell = forecasts[indexPath.row]
            
            cell.updateUI(forecastData: forecastCell)
        
            return cell
            
        }
        else
        {
            return UITableViewCell()
        }
    }
    
    func updateMainUI()
    {
        
        
        dateLbl.text = currentWeather.date
        locationLbl.text = currentWeather.cityName
        currentWeatherTypeLbl.text = currentWeather.weatherType
        currentTempLbl.text = "\(currentWeather.weatherTemp)"
        weatherImage.image = UIImage(named: currentWeather.weatherType)
    }
}






