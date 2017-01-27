//
//  DetailsViewController.swift
//  Places
//
//  Created by Boris Kachulachki on 1/24/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import Social

class DetailsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  var place: Place!
  let infoCellId = "info-cell"
  let interactiveCellId = "interactive-cell"
  let directionsSegueId = "directions-segue"
  let gallerySegueId = "gallery-segue"
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = place.placeName
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.loadDetailInfo()
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 4
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 4
    } else if section == 1 {
      return 2
    } else if section == 2  {
      return 1
    } else {
      return 1
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cellId = infoCellId
    if indexPath.section != 0 {
      cellId = interactiveCellId
    }
    
    let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellId)! as UITableViewCell
    var key = "unknown"
    var value = "unknown"
    
    if indexPath.section == 0 {
      if indexPath.row == 0 {
        key = "Name"
        if self.place.placeName.characters.count > 0 {
          value = self.place.placeName
        }
      } else if indexPath.row == 1 {
        key = "Address"
        if let address = self.place.address {
          if address.characters.count > 0 {
            value = address
          }
        }
        
      } else if indexPath.row == 2 {
        key = "Phone number"
        if let phoneNumber = self.place.phoneNumber {
          if phoneNumber.characters.count > 0 {
            value = phoneNumber
          }
        }
      } else if indexPath.row == 3 {
        key = "Website"
        if let website = self.place.website {
          if website.characters.count > 0 {
            value = website
          }
        }
      }
    } else if indexPath.section == 1 {
      if indexPath.row == 0 {
        key = "Share this place on Facebook!"
      } else if indexPath.row == 1 {
        key = "Share this place on Twitter!"
      }
    } else if indexPath.section == 2 {
      key = "Navigate here..."
    } else {
      key = "Photos of \(self.place.placeName)"
    }
    
    if indexPath.section == 0 {
      cell.textLabel?.text = key
      cell.detailTextLabel?.text = value
    } else {
      cell.textLabel?.text = key
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if indexPath.section == 0 {
      return
    } else if indexPath.section == 1 {
      if indexPath.row == 0 {
        self.shareOnFacebook()
      } else if indexPath.row == 1 {
        self.shareOnTwitter()
      }
    } else if indexPath.section == 2 {
      self.performSegue(withIdentifier: directionsSegueId, sender: self)
    } else {
      if let photoReferences = self.place.photoReferences {
        if photoReferences.count != 0 {
          self.performSegue(withIdentifier: gallerySegueId, sender: self)
          return
        }
      }
      
      let alertController = UIAlertController(title: "No photos", message: "There are no photos found for this place.", preferredStyle: .alert)
      
      let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { action in
        // ...
      }
      alertController.addAction(cancelAction)
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "    Place info"
    } else if section == 1{
      return "    Social"
    } else if section == 2 {
      return "    Navigation"
    } else {
      return "    Gallery"
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == directionsSegueId {
      let controller = segue.destination as! DirectionsViewController
      controller.place = self.place
    } else if segue.identifier == gallerySegueId {
      let navController = segue.destination as! UINavigationController
      let galleryController = navController.viewControllers[0] as! GalleryViewController
      galleryController.place = self.place
    }
  }
  
  func shareOnFacebook() -> Void {
    if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
      let socialShare = SLComposeViewController.init(forServiceType: SLServiceTypeFacebook)
      socialShare?.add(self.generatePlaceUrl())
      socialShare?.setInitialText("I'm at \(self.place.placeName)")
      self.present(socialShare!, animated: true, completion: nil)
    }
  }
  
  func shareOnTwitter() -> Void {
    if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
      let socialShare = SLComposeViewController.init(forServiceType: SLServiceTypeTwitter)
      socialShare?.add(self.generatePlaceUrl())
      socialShare?.setInitialText("I'm at \(self.place.placeName)")
      self.present(socialShare!, animated: true, completion: nil)
    }
  }
  
  func generatePlaceUrl() -> URL {
    let placeNamePlus = self.place.placeName.replacingOccurrences(of: " ", with: "+")
    var urlString = "https://www.google.com/maps/place/" + placeNamePlus
    if let addressPlus = self.place.address?.replacingOccurrences(of: " ", with: "+") {
      urlString =  urlString + "+" + addressPlus
    }

    let url = URL.init(string: urlString)
    if let finalUrl = url {
      return finalUrl
    }
    
    return URL.init(string: "https://www.maps.google.com")!
  }
  
  func loadDetailInfo() {
    let loader = PlacesLoader()
    self.activityIndicator.startAnimating()
    self.tableView.isHidden = true
    loader.loadDetailInformation(forPlace: self.place) { (dictionary, error) in
      guard dictionary != nil else {
        DispatchQueue.main.async {
          self.activityIndicator.stopAnimating()
          self.tableView.isHidden = false
          self.tableView.reloadData()
        }
        
        return
      }
      
      if let resultDictionary = dictionary!["result"] as? NSDictionary {
        self.place.address = resultDictionary["formatted_address"] as? String
        self.place.phoneNumber = resultDictionary["formatted_phone_number"] as? String
        self.place.website = resultDictionary["website"] as? String
        
        if let photosArr = resultDictionary["photos"] as? [NSDictionary] {
          for photoDict in photosArr {
            let photoReference = photoDict["photo_reference"] as? String
            if self.place.photoReferences == nil {
              self.place.photoReferences = [String]()
            }
            
            self.place.photoReferences?.append(photoReference!)
          }
        }
      }
        
      DispatchQueue.main.async {
        self.activityIndicator.stopAnimating()
        self.tableView.isHidden = false
        self.tableView.reloadData()
      }
    }
  }
}
