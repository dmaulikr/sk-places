//
//  GalleryViewController.swift
//  SKPlaces
//
//  Created by Boris Kachulachki on 1/26/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

class GalleryViewController: UIPageViewController {
  
  var place: Place!
  var currentVC: UIViewController?
  var lastVC: UIViewController?
  let pictureViewControllerId = "PictureViewController"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = place.placeName
    navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Close", style: .plain, target: self, action: #selector(close))
    let startingVC = self.viewController(atIndex: 0)!
    let viewControllers = [startingVC]
    self.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil)
    self.delegate = self
    self.dataSource = self
  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
  }
  
  func viewController(atIndex index: Array<Any>.Index) -> UIViewController? {
    guard self.place.photoReferences != nil else {
      return nil
    }
    
    if self.place.photoReferences!.count == 0 || index >= self.place.photoReferences!.count {
      return nil
    }
    
    guard let photoReferences = self.place.photoReferences else {
      return nil
    }
    
    let pictureController: PictureViewController = self.storyboard?.instantiateViewController(withIdentifier: pictureViewControllerId) as! PictureViewController
    pictureController.photoReference = photoReferences[index]
    return pictureController
  }
  
  func close() {
    self.dismiss(animated: true, completion: nil)
  }
}

extension GalleryViewController: UIPageViewControllerDataSource {
  func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return self.place.photoReferences!.count
  }
  
  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    return 0
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    if let photoReference = (viewController as! PictureViewController).photoReference {
      if var index = self.place.photoReferences!.index(of: photoReference) {
        if index == 0 {
          return nil
        }
        
        index -= 1
        return self.viewController(atIndex: index)
      }
      
      return nil
    }
    
    return nil
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    if let photoReference = (viewController as! PictureViewController).photoReference {
      if var index = self.place.photoReferences!.index(of: photoReference) {
        index += 1
        if index == self.place.photoReferences?.count {
          return nil
        }
        
        return self.viewController(atIndex: index)
      }
      
      return nil
    }
    
    return nil
  }
}

extension GalleryViewController: UIPageViewControllerDelegate {
  func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
    guard pendingViewControllers.count != 0 else {
      return
    }
    
    lastVC = pendingViewControllers.first
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if completed {
      currentVC = lastVC
    }
  }
}


