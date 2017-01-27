//
//  ListViewController.swift
//  Places
//
//  Created by Boris Kachulachki on 1/25/17.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import UIKit

class ListViewController: BaseViewController {
    @IBOutlet weak var tableView: UITableView!
    let cellId = "cell"
    let detailsSegueId = "details-segue"
    var places = [Place]()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredPlaces = [Place]()
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      self.tableView.delegate = self
      self.tableView.dataSource = self
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        self.tableView.reloadData()
    }

    func filterContentForSearchText(searchText: String) {
      filteredPlaces = places.filter { place in
        return place.placeName.lowercased().contains(searchText.lowercased())
      }
      
      tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailsSegueId {
            let controller = segue.destination as! DetailsViewController
            let place = sender as! Place
            controller.place = place
        }
    }
}

extension ListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if searchController.isActive && searchController.searchBar.text != "" {
        return filteredPlaces.count
      }
      
      return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell: RightIconTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellId)! as! RightIconTableViewCell
      let place: Place
      if searchController.isActive && searchController.searchBar.text != "" {
        place = filteredPlaces[indexPath.row]
      } else {
        place = places[indexPath.row]
      }
      
      cell.setPlace(place: place)
      return cell
    }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if indexPath.row >= self.places.count {
      return
    }
    
    let cell: RightIconTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellId)! as! RightIconTableViewCell
    let place: Place
    if searchController.isActive && searchController.searchBar.text != "" {
      place = filteredPlaces[indexPath.row]
    } else {
      place = places[indexPath.row]
    }
    
    if let icon = place.iconImage {
      cell.setIcon(icon: icon)
    } else {
      let loader = PlacesLoader()
      loader.loadIcon(forPlace: place, handler: { (icon, error) in
        guard error == nil else {
          return
        }
        
        if let cell: RightIconTableViewCell = self.tableView.cellForRow(at: indexPath) as? RightIconTableViewCell {
          DispatchQueue.main.async {
            if let cellIcon = icon {
              cell.setIcon(icon: cellIcon)
            }
          }
        }
      })
    }
  }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let place: Place
        if searchController.isActive && searchController.searchBar.text != "" {
          place = filteredPlaces[indexPath.row]
        } else {
          place = places[indexPath.row]
        }
        self.performSegue(withIdentifier: detailsSegueId, sender: place)
    }
}

extension ListViewController: UISearchResultsUpdating {
  public func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchText: searchController.searchBar.text!)
  }
}
