//
//  Extensions.swift
//  CookieCrunch
//
//  Created by Gregory Cedarblade on 2/23/17.
//  Copyright © 2017 Gregory Cedarblade. All rights reserved.
//

import Foundation

extension Dictionary {
  
  static func loadJSONFromBundle(fileName: String) -> Dictionary<String, AnyObject>? {
    
    var dataOK: Data
    var dictionaryOK: NSDictionary = NSDictionary()
    
    if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
      
      // Create the Data object
      do {
        
        let data = try Data(contentsOf: URL(fileURLWithPath: path), options: NSData.ReadingOptions()) as Data!
        
        dataOK = data!
        
      } catch {
        print("Could not load level file: \(fileName), error: \(error)")
        return nil
      }
      
      // Create the Dictionary from the Data object
      do {
        
        let dictionary = try JSONSerialization.jsonObject(with: dataOK, options: JSONSerialization.ReadingOptions()) as AnyObject!
        
        dictionaryOK = (dictionary as! NSDictionary as? Dictionary<String, AnyObject>)! as NSDictionary
        
      } catch {
        print("Level file '\(fileName)' is not vaild JSON: \(error)")
        return nil
      }
      
      
    }
    
    return dictionaryOK as? Dictionary<String, AnyObject>
    
  }
  
}
