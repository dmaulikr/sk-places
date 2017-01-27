//
//  DirectionsViewController.swift
//  Places
//
//  Created by Boris Kachulachki on 1/24/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit
import MapKit

class DirectionsViewController: BaseViewController, MKMapViewDelegate {
  
  var place: Place!
  @IBOutlet weak var mapView: MKMapView!
  fileprivate let locationManager = CLLocationManager()
  var route: MKRoute?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.title = place.placeName
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
      locationManager.requestWhenInUseAuthorization()
      mapView.delegate = self
      
      let request = MKDirectionsRequest()
      request.source = MKMapItem.forCurrentLocation()
      let locationPlacemark = MKPlacemark(coordinate: (self.place.location?.coordinate)!, addressDictionary: nil)
      request.destination = MKMapItem(placemark: locationPlacemark)
      request.transportType = .any;
      request.requestsAlternateRoutes = true;
      let directions = MKDirections(request: request);
      
      self.activityIndicator.startAnimating()
      directions.calculate { (response, error) in
        guard let response = response else {
          print(error!.localizedDescription)
          return;
        }
        
        print(response.description)
        
        self.route = response.routes[0]
        self.mapView.add(self.route!.polyline)
      }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    self.activityIndicator.stopAnimating()
    self.mapView.isHidden = false
    let myLineRenderer = MKPolylineRenderer(polyline: (self.route?.polyline)!)
    myLineRenderer.strokeColor = UIColor.red
    myLineRenderer.lineWidth = 3
    return myLineRenderer
  }
}

extension DirectionsViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    if locations.count > 0 {
      let location = locations.last!
      print("Accuracy: \(location.horizontalAccuracy)")
      if location.horizontalAccuracy < 100 {
        manager.stopUpdatingLocation()
        let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.region = region
        let annotation = PlaceAnnotation(location: place.location!.coordinate, title: place.placeName)
        DispatchQueue.main.async {
          self.mapView.addAnnotation(annotation)
        }
      }
    }
  }
}
