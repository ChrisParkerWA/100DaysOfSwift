//
//  CountryFactsViewController.swift
//  C5Countries
//
//  Created by Chris Parker on 13/4/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit
import MapKit

class CountryFactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var country: Country!
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var flag: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        title = country.name
        
        loadMap()
        loadFlag()
    }
    
    func loadMap() {
        guard
            let latitude = country.latlng.first,
            let longitude = country.latlng.last
            else { return }
        
        let centreCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Set Annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = centreCoordinates
        annotation.title = country.name
        
        mapView.addAnnotation(annotation)
        
        // Centre map on location
        let region = MKCoordinateRegion(
            center: centreCoordinates,
            latitudinalMeters: 3_000_000,
            longitudinalMeters: 3_000_000)
        mapView.setRegion(region, animated: true)
    }
    
    func loadFlag() {        
        let flagURL = URL( string: "https://flags.fmcdn.net/data/flags/w1160/\(country.alpha2Code.lowercased()).png")
        var image: UIImage?
        if let url = flagURL {
            //All network operations has to run on different thread (not on main thread).
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = NSData(contentsOf: url)
                //All UI operations has to run on main thread.
                DispatchQueue.main.async {
                    if imageData != nil {
                        image = UIImage(data: imageData! as Data)
                        self.flag.image = image
                        self.flag.sizeToFit()
                        self.flag.layer.borderWidth = 1
                        self.flag.layer.borderColor = UIColor.gray.cgColor
                    } else {
                        image = nil
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CountryDetails", for: indexPath) as? CountryCell else {
            fatalError("Unable to dequeue Country Cell")
        }
        tableView.rowHeight = 337
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let area = numberFormatter.string(from: NSNumber(value: country.area ?? 0))
        let population = numberFormatter.string(from: NSNumber(value: country.population))
        cell.countryLabel.text = country.name
        cell.capitalLabel.text = country.capital
        cell.regionLabel.text = country.region
        cell.populationLabel.text = "\(population!)"
        cell.areaLabel.text = "\(area!) Sq Km"
        cell.subRegionLabel.text = country.subregion
        cell.nativeNameLabel.text = country.nativeName
        cell.numericCodeLabel.text = "\(country.numericCode ?? "0")"
        // Configure the cell...
        
        return cell
    }
    
}
