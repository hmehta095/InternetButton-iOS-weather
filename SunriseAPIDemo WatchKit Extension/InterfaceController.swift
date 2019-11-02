//
//  InterfaceController.swift
//  SunriseAPIDemo WatchKit Extension
//
//  Created by MacStudent on 2019-10-16.
//  Copyright © 2019 MacStudent. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire
import SwiftyJSON

class InterfaceController: WKInterfaceController {
    
     let APIID = "d2c0d622cb9de74c46c1ca58f2317c8f"
    @IBOutlet weak var cityTime: WKInterfaceLabel!
    @IBOutlet weak var cityNameLabel: WKInterfaceLabel!
    @IBOutlet weak var temp: WKInterfaceLabel!
    @IBOutlet weak var descLabel: WKInterfaceLabel!
    var seconds = 0
    var timer = Timer()
    
    @IBAction func buttonPressed() {
        print("Button pressed")
        AF.request("https://api.sunrise-sunset.org/json?lat=43.6532&lng=-79.3832").responseJSON {
            
            (xyz) in
            print(xyz.value)
            
            // convert the response to a JSON object
            let x = JSON(xyz.value)
            let sunrise = x["results"]["sunrise"]
            let sunset = x["results"]["sunset"]

            print("Sunrise: \(sunrise)")
            print("Sunset: \(sunset)")
            //self.responseLabel.setText("Sunrise: \(sunrise)")
        }
        
        
        
    }
    @IBOutlet weak var windLabel: WKInterfaceLabel!
    
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        runTimer()
        print("SHARED PREFERENCES OUTPUT")
                      let preferences = UserDefaults.standard
               print(preferences.string(forKey: "savedCity"))
            
               var city = preferences.string(forKey:"savedCity") ?? ""
               print("CITY NAME IS :\(city)")
               if (city == "") {
                print("Preference was empty")
                   city = "LONDON"
                  
               }
       
               // Update UI
               // self.cityLabel.setText(city)
        AF.request("https://samples.openweathermap.org/data/2.5/weather?q=\(city),uk&appid=\(APIID)").responseJSON {

            (xyz) in
            print(xyz.value)

            // convert the response to a JSON object
            let x = JSON(xyz.value)
            let main = x["name"]
        print("---------------------------------------------------------")
         print("---------------------------------------------------------")
         print("---------------------------------------------------------")
         print("---------------------------------------------------------")
        
        let description = x["weather"]
        
            let d = x["main"]["temp_max"]
            let desc = description[0]["description"]
            print("Description is : \(description[0]["description"])")
            print("Sunrise: \(main)")
            print("Description: \(description)")
        print("Main: \(d)")
            self.cityNameLabel.setText("\(main)")
            self.descLabel.setText("\(desc)")
            self.temp.setText("\(d)")
            
         
    }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    func runTimer() {
           timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
       }
       @objc
       func updateTimer() {
           seconds += 1
           showtime()
       }
      func showtime()
      {
        AF.request("http://worldtimeapi.org/api/timezone/Europe/London").responseJSON
                            {
                                (xyz) in

                                           // convert the response to a JSON object
                                           let x = JSON(xyz.value)
                                           let time = x["utc_datetime"]
                                           print("DateTime: \(time)")
                                          // print("Sunset: \(description)")
                                if time == "null"
                                {
                                    self.cityTime.setText("Updating...")
                                }
                                var str = "\(time)"
                                var strArray = str.components(separatedBy: "T")
                                print("----------------------")
                                print(strArray[0])
                                print(strArray[1])
                                 print("----------------------")
                               var str1 = "\(strArray[1])"
                                var strArray1 = str1.components(separatedBy: ".")
                                print("----------------------")
                                print(strArray1[0])
                                                              print(strArray1[1])
                            print("----------------------")
                                           self.cityTime.setText("\(strArray1[0])")
                               
                        }
               
                    
    }
   
}
