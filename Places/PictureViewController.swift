//
//  PictureViewController.swift
//  SKPlaces
//
//  Created by Boris Kachulachki on 1/26/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

class PictureViewController: UIViewController {
    @IBOutlet weak var activity: UIActivityIndicatorView!
  
    var photoReference: String!
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadImage() {
      let loader = PlacesLoader()
      self.activity.startAnimating()
      loader.loadPicture(forPhotoReference: self.photoReference) { (image, error) in
        DispatchQueue.main.async {
          self.activity.stopAnimating()
          self.imageView.image = image
        }
      }
    }

}
