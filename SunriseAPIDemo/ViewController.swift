//
//  ViewController.swift
//  SunriseAPIDemo
//
//  Created by MacStudent on 2019-10-16.
//  Copyright © 2019 MacStudent. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Particle_SDK

class ViewController: UIViewController {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var resultsLabel: UILabel!
       var seconds = 0
       var timer = Timer()
       
    // MARK: User variables
    let USERNAME = "hmehta095@gmail.com"
    let PASSWORD = "Hmehta_095@"
    
    // MARK: Device
    let DEVICE_ID = "31002e000447363333343435"
    var myPhoton : ParticleDevice?

    let APIID = "d2c0d622cb9de74c46c1ca58f2317c8f"
    
    
    
    var preception:JSON = [];
    var temperature:JSON = [];
    override func viewDidLoad()
    {
        super.viewDidLoad()
        runTimer()
        AF.request("https://samples.openweathermap.org/data/2.5/weather?q=London,uk&appid=\(APIID)").responseJSON {

                   (xyz) in
                   print("xyz is: \(xyz.value)")
            

                   // convert the response to a JSON object
                   let x = JSON(xyz.value)
                   let main = x["name"]
               print("---------------------------------------------------------")
                print("---------------------------------------------------------")
                print("---------------------------------------------------------")
                print("---------------------------------------------------------")
               
                let description = x["weather"]
            self.preception = x["clouds"]["all"]
            print("precesption is : \(self.preception)")
            
            self.temperature = x["main"]["temp"]
            print("Temperature is : \(self.temperature)")
            
                      
                          let d = x["main"]["temp_max"]
                          let desc = description[0]["description"]
                          print("Description is : \(description[0]["description"])")
                          print("Sunrise: \(main)")
                          print("Description: \(description)")
                      print("Main: \(d)")
               self.resultsLabel.text = "\(d) and \(desc) and \(main)"
               }
        // Do any additional setup after loading the view.
        
        

               // 1. Initialize the SDK

               ParticleCloud.init()

        

               // 2. Login to your account

               ParticleCloud.sharedInstance().login(withUser: self.USERNAME, password: self.PASSWORD) { (error:Error?) -> Void in

                   if (error != nil) {

                       // Something went wrong!

                       print("Wrong credentials or as! ParticleCompletionBlock no internet connectivity, please try again")

                       // Print out more detailed information

                       print(error?.localizedDescription)

                   }

                   else {

                       print("Login success!")



                       // try to get the device

                       self.getDeviceFromCloud()



                   }

               } // end login
        
        
        
        
    }
    
    @IBAction func clickButtonPressed(_ sender: Any) {
        print("Button pressed")
        
        // 1. Go to sunrise-sunset api
        // & wait for the website to repond
        
    AF.request("https://samples.openweathermap.org/data/2.5/weather?q=London,uk&appid=\(APIID)").responseJSON {

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
        self.resultsLabel.text = "\(d) and \(desc) and \(main)"
        }
//         AF.request("http://worldtimeapi.org/api/timezone/Europe/London").responseJSON
//            {
//                (xyz) in
//                            print("DATA iS:")
//                print(xyz.value)
//
//                           // convert the response to a JSON object
//                           let x = JSON(xyz.value)
//                           let time = x["utc_datetime"]
//                           //let description = x["weather"]["description"]
//
//                           print("DateTime: \(time)")
//                          // print("Sunset: \(description)")
//                           self.resultsLabel.text = "TIME: \(time)"
//        }
       
    }
    var hour:String = "";
    var min:String = "";
    var sec:String = "";
    func runTimer() {
              timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
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
                                            self.timeLabel.text = ""
                                        }
                                   var str = "\(time)"
                                if str.isEmpty
                                {
                                    return
                                    
                                }
                                
                                   var strArray = str.components(separatedBy: "T")
                                   print("----------------------")
                                   print(strArray[0])
                                  // print(strArray[1])
//                                if strArray[1].count == 0
//                                {
//                                     self.timeLabel.text = ""
//                                }
                                
                                print("----------------------")
                            
                                var str1 = "\(strArray[1])"
                                print("zzzzz\(str1)")
                                if str1.isEmpty{
                                    return
                                }
                                
                                   var strArray1 = str1.components(separatedBy: ".")
                                   print("----------------------")
                                   print(strArray1[0])
                                    print(strArray1[1])
                               print("----------------------")
                                self.timeLabel.text = "\(strArray1[0])"
                                var splitTime = strArray1[0].components(separatedBy: ":")
                               
                                print("xxxxxxx\(splitTime)")
                                
                                
                                self.hour = splitTime[0]
                                self.min = splitTime[1]
                                self.sec = splitTime[2]
                                print(" Time after split is \(self.hour): \(self.min) : \(self.sec)")
                                //real time call
                                self.hourCall(hour: self.hour)
                                self.minCall(min: self.min)
                                self.secondCall(sec: self.sec)
                                  
                           }
                  
                       
       }
     // MARK: Get Device from Cloud
        // Gets the device from the Particle Cloud
        // and sets the global device variable
        func getDeviceFromCloud() {
        ParticleCloud.sharedInstance().getDevice(self.DEVICE_ID) { (device:ParticleDevice?, error:Error?) in
                
                if (error != nil) {
                    print("Could not get device")
                    print(error?.localizedDescription)
                    return
                }
                else {
                    print("Got photon: \(device?.id)")
                    self.myPhoton = device
                    // subscribe to events
                    self.subscribeToParticleEvents()
                }
                
            } // end getDevice()
        }
        
        
        

        
        func subscribeToParticleEvents() {
            var handler : Any?

                  handler = ParticleCloud.sharedInstance().subscribeToDeviceEvents(withPrefix: "playerChoice", deviceID: self.DEVICE_ID , handler: {

                          (event :ParticleEvent?, error : Error?) in

                      

                      if let _ = error {

                          print("could not subscribe to events")

                      } else {

                          print("got event with data \(event?.data)")

                          let choice = (event?.data)!

                          if (choice == "A") {
                            print("pressed aaaaaa")

                            self.temperature(temp: "\(self.temperature)")
//                              self.gameScore = self.gameScore + 1;

                          }

                          else if (choice == "B") {

                            self.percepitation(precep: "\(self.preception)")

                          }

                      }

                  })


        }
    func hourCall(hour : String) {
            
            print("Hour function call")
            
            let parameters = ["\(hour)"]
        print(hour)
            var task = myPhoton!.callFunction("hour", withArguments: parameters) {
                (resultCode : NSNumber?, error : Error?) -> Void in
                if (error == nil) {
                    print("Sent message to Particle to show hour")
                }
                else {
                    print("Error when telling Particle to show hour")
                }
            }
            //var bytesToReceive : Int64 = task.countOfBytesExpectedToReceive
            
        }
        
    func minCall(min : String) {
            
            print("Minute function call")
            
            let parameters = ["\(min)"]
            var task = myPhoton!.callFunction("min", withArguments: parameters) {
                (resultCode : NSNumber?, error : Error?) -> Void in
                if (error == nil) {
                    print("Sent message to Particle to show minute")
                }
                else {
                    print("Error when telling Particle to show minute")
                }
            }
            //var bytesToReceive : Int64 = task.countOfBytesExpectedToReceive
            
        }
    func secondCall(sec : String) {
        
        print("Second function call")
        
        let parameters = ["\(sec)"]
        var task = myPhoton!.callFunction("sec", withArguments: parameters) {
            (resultCode : NSNumber?, error : Error?) -> Void in
            if (error == nil) {
                print("Sent message to Particle to show second")
            }
            else {
                print("Error when telling Particle to show second")
            }
        }
        //var bytesToReceive : Int64 = task.countOfBytesExpectedToReceive
        
    }
    
    
    func temperature(temp : String) {
        
        print("In temperature")
        
        let parameters = ["\(temp)"]
        var task = myPhoton!.callFunction("temp", withArguments: parameters) {
            (resultCode : NSNumber?, error : Error?) -> Void in
            if (error == nil) {
                print("Sent message to Particle to show temperature")
            }
            else {
                print("Error when telling Particle to show temperature")
            }
        }
        //var bytesToReceive : Int64 = task.countOfBytesExpectedToReceive
        
    }
    
    
    func percepitation(precep : String) {
        
        print("In perception")
        
        let parameters = ["\(precep)"]
        var task = myPhoton!.callFunction("precep", withArguments: parameters) {
            (resultCode : NSNumber?, error : Error?) -> Void in
            if (error == nil) {
                print("Sent message to Particle to show perception")
            }
            else {
                print("Error when telling Particle to show perception")
            }
        }
        //var bytesToReceive : Int64 = task.countOfBytesExpectedToReceive
        
    }
    
    
    
}

