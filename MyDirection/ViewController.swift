//
//  ViewController.swift
//  MyLocation
//
//  Created by Faris Ali Yafie on 05/05/20.
//  Copyright © 2020 Faris Ali Yafie. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var findLocationTextField: UITextField!
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet var mapView: MKMapView!
    
    //manage user's location
    var locManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locManager.desiredAccuracy = kCLLocationAccuracyBest // High Battery Usage
        locManager.delegate = self
        locManager.requestAlwaysAuthorization()
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        
        mapView.delegate = self
    }
    
    // get address from textfield
    func getAddress(){
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(findLocationTextField.text!) { (placemarks, error) in
            guard let placemarks = placemarks, let target = placemarks.first?.location
                else{
                    print("No Location Found")
                    return
            }
            print(target)
            self.mapThis(location, destinationCoor: target.coordinate)
        }
    }
    
    //update location state
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            manager.stopUpdatingLocation()
            mapThis(location, destinationCoor: )
        }
        print(locations)
    }
    
    func render(_ location: CLLocation){
        let sourceCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: sourceCoordinate, span: span)
        mapView.setRegion(region, animated: true)

        // pin current location
        let pinned = MKPointAnnotation()
        pinned.coordinate = sourceCoordinate
        mapView.addAnnotation(pinned)
    }

    // create direction from source to destination place
    func mapThis(_ location : CLLocation, destinationCoor : CLLocationCoordinate2D){
        let sourceCoor = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: sourceCoor, span: span)
                mapView.setRegion(region, animated: true)
            let pinned = MKPointAnnotation()
            pinned.coordinate = sourceCoor
                mapView.addAnnotation(pinned)
        
        let sourcePlaceMark = MKPlacemark(coordinate: sourceCoor)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationCoor)
        
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationItem = MKMapItem(placemark: destinationPlaceMark)
        
        let destinationRequest = MKDirections.Request()
        destinationRequest.source = sourceItem
        destinationRequest.destination = destinationItem
        destinationRequest.transportType = .automobile
        destinationRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: destinationRequest)
        directions.calculate { (response, error) in
            guard let response = response else{
                if let error = error {
                    print("Something is wrong")
                }
                return
            }
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline)
            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        render.strokeColor = .blue
        return render
    }
    
    @IBAction func directionPressed(_ sender: Any) {
        getAddress()
    }
}

