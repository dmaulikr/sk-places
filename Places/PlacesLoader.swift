/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreLocation

struct PlacesLoader {
  let apiURL = "https://maps.googleapis.com/maps/api/place/"
  let apiKey = "AIzaSyAQ5EcgNtOSVbe1p_q8--Nzd9UhXL802sk"
  
  func loadPOIS(location: CLLocation, radius: Int = 30, handler: @escaping (NSDictionary?, NSError?) -> Void) {
    print("Load pois")
    let latitude = location.coordinate.latitude
    let longitude = location.coordinate.longitude
    
    let uri = apiURL + "nearbysearch/json?location=\(latitude),\(longitude)&radius=\(radius)&sensor=true&types=establishment&key=\(apiKey)"
    
    let url = URL(string: uri)!
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let dataTask = session.dataTask(with: url) { data, response, error in
      if let error = error {
        print(error)
      } else if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {          do {
            let responseObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            guard let responseDict = responseObject as? NSDictionary else {
              return
            }
            
            handler(responseDict, nil)
      
          } catch let error as NSError {
            handler(nil, error)
          }
        }
      }
    }
    
    dataTask.resume()
  }
  
  func loadDetailInformation(forPlace: Place, handler: @escaping (NSDictionary?, NSError?) -> Void) {
    
    let uri = apiURL + "details/json?reference=\(forPlace.reference)&sensor=true&key=\(apiKey)"
    
    let url = URL(string: uri)!
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let dataTask = session.dataTask(with: url) { data, response, error in
      if let error = error {
        print(error)
      } else if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          do {
            let responseObject = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
            guard let responseDict = responseObject as? NSDictionary else {
              return
            }
            
            handler(responseDict, nil)
            
          } catch let error as NSError {
            handler(nil, error)
          }
        }
      }
    }
    
    dataTask.resume()
  }
  
  func loadIcon(forPlace place: Place, handler: @escaping (UIImage?, NSError?) -> Void) {
    loadDetailInformation(forPlace: place) { (dictionary, error) in
      guard error == nil else {
        handler(nil, error)
        return
      }
      
      if let dict = dictionary {
        if let resultDict = dict["result"] as? NSDictionary {
          if let iconUrl = resultDict["icon"] as? String {
            if let url = URL(string: iconUrl) {
              DispatchQueue.global().async {
                let iconData = try! Data(contentsOf: url)
                if let icon = UIImage(data: iconData) {
                  handler(icon, nil)
                }
              }
            }
          }
        }
      }
    }
  }
  
  func loadPicture(forPhotoReference photoReference: String, handler: @escaping (UIImage?, NSError?) -> Void) {
    let uri = apiURL + "photo?maxwidth=400&maxheight=600&photoreference=\(photoReference)&key=\(apiKey)"
    
    let url = URL(string: uri)!
    let session = URLSession(configuration: URLSessionConfiguration.default)
    let dataTask = session.dataTask(with: url) { (data, response, error) in
      if let error = error {
        print(error)
      } else if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
          let image = UIImage(data: data!)
          handler(image, nil)
        }
      }
    }
    
    dataTask.resume()
  }
}
