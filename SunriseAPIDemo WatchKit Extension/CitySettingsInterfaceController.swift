//
//  CitySettingsInterfaceController.swift
//  APIDemo WatchKit Extension
//
//  Created by Parrot on 2019-03-04.
//  Copyright © 2019 Parrot. All rights reserved.
//

import WatchKit
import Foundation
import Alamofire
import SwiftyJSON

class CitySettingsInterfaceController: WKInterfaceController {

    // MARK: Outlets
    @IBOutlet var savedCityLabel: WKInterfaceLabel!
    @IBOutlet var loadingImage: WKInterfaceImage!
    @IBOutlet var saveButtonLabel: WKInterfaceLabel!

    // MARK: Variables
    var city:String!
    //var latitude:String?
    //var longitude:String?
    
    @IBAction func selectCityPressed() {
        // 1. When person clicks on button, show them the input UI
        let suggestedResponses = ["London", "Montreal","New York City","Los Angeles"]
        presentTextInputController(withSuggestions: suggestedResponses, allowedInputMode: .plain) {
            
            (results) in
            
            if (results != nil && results!.count > 0) {
                // 2. write your code to process the person's response
                let userResponse = results?.first as? String
                self.savedCityLabel.setText(userResponse)
                self.city = userResponse
            }
        }
    }
    
    @IBAction func saveButtonPressed() {
        print("Getting City")
        self.loadingImage.setImageNamed("Progress")
        self.loadingImage.startAnimatingWithImages(in: NSMakeRange(0, 10), duration: 1, repeatCount: 0)
        self.saveButtonLabel.setText("Saving...")
        
         let preferences = UserDefaults.standard
         preferences.set(self.city, forKey:"savedCity")
        // dismiss the View Controller
        self.popToRootController()
        
        
        self.loadingImage.stopAnimating()
    }
 
    // MARK: Default functions

override func awake(withContext context: Any?) {
      
    super.awake(withContext: context)
       
       // Configure interface objects here.
   }
   
   override func willActivate() {
       // This method is called when watch view controller is about to be visible to user
       super.willActivate()
    let preferences = UserDefaults.standard
          
    guard let savedCity = preferences.string(forKey: "savedCity") else {
               return
    
   }
    savedCityLabel.setText(savedCity)
    }
   override func didDeactivate() {
       // This method is called when watch view controller is no longer visible
       super.didDeactivate()
   }
}
