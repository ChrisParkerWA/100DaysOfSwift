//
//  ViewController.swift
//  P16CapCities
//
//  Created by Chris Parker on 13/4/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .automatic
        title = "Captial Cities"
        
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home to the 2012 Summer Olympics.")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Light.")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country inside it.")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), info: "Named after George himself.")
        let perth = Capital(title: "Perth", coordinate: CLLocationCoordinate2D(latitude: -31.9505, longitude: 115.8605), info: "Best city in the world and home of the 1962 Commonwealth Games.")
        let sydney = Capital(title: "Sydney", coordinate: CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093), info: "Home of the 2000 Summer Olympics.")
        
        /*
         Challenge Q2 - Add a UIAlertController that lets users specify how they want to view the map.
         There's a mapType property that draws the maps in different ways. For example, .satellite
         gives a satellite view of the terrain.
        */
        chooseMapDisplayStyle()
        
        mapView.addAnnotations([london, oslo, paris, rome, washington, perth, sydney])
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 1
        guard annotation is Capital else { return nil }
        
        // 2
        let identifier = "Capital"
        
        // 3
        /*
         Challenge Q1 - Try typecasting the return value from dequeueReusableAnnotationView() so that
         it's an MKPinAnnotationView.
         */
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            //4
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            
            // 5
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            // 6
            annotationView?.annotation = annotation
        }
        /*
         Challenge Q1 - Once that’s done, change the pinTintColor property to your favorite UIColor.
         */        
        annotationView?.pinTintColor = UIColor.blue
        return annotationView

    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        let placeName = capital.title?.replacingOccurrences(of: " ", with: "_")
//        let placeInfo = capital.info
        
        /*
         Challenge Q3 Modify the callout button so that pressing it shows a new view controller with a web view,
         taking users to the Wikipedia entry for that city.
         */
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedWebsite = "en.wikipedia.org/wiki/\(placeName!)"
            vc.city = placeName!
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func chooseMapDisplayStyle() {
        showAlert(title: "Display option", message: "Choose either Standard or Satellite")
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let standardAction = UIAlertAction(title: "Standard (default)", style: .default) { ( action ) in
            self.mapView.mapType = .standard
        }
        let satelliteAction = UIAlertAction(title: "Satellite", style: .default) { ( action ) in
            self.mapView.mapType = .satellite
        }
        
        alert.addAction(standardAction)
        alert.addAction(satelliteAction)
        
        present(alert, animated: true)
    }
}


