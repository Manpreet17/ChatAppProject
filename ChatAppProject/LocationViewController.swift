//
//  LocationViewController.swift
//  ChatAppProject
//
//  Created by Manpreet Dhillon on 2018-11-26.
//  Copyright © 2018 UofR. All rights reserved.
//

import UIKit
import MapKit
import Firebase
class LocationViewController: UIViewController,CLLocationManagerDelegate {
     var user : Users?
    var latitude = 0.0;
    var longitude = 0.0;
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var map: MKMapView!
    var locationManager:CLLocationManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.action = #selector(loadController)
        determineMyCurrentLocation();
    }
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    @objc func loadController(){
        loadChatLogController();
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        
        // Drop a pin at user's Current Location
        let myAnnotation: MKPointAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude);
        myAnnotation.title = "Current location"
        map.addAnnotation(myAnnotation)
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        latitude = userLocation.coordinate.latitude;
        longitude = userLocation.coordinate.longitude;
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    @IBAction func sendLocation(_ sender: Any) {
        determineMyCurrentLocation();
        //openMapForPlace()
        sendLocationMessage(latitude: latitude,longitude: longitude)
        print("user latitude = \(latitude)");
        print("user longitude = \(longitude)");
    }
    
    func sendLocationMessage(latitude: Double,longitude: Double){
        let messageRef = Database.database().reference().child("messages")
        let childRef = messageRef.childByAutoId();
        let toId = user!.id!;
        let fromId = Auth.auth().currentUser!.uid
        let timestamp = Int(NSDate().timeIntervalSince1970);
        
        let values = ["longitude":longitude,"latitude":latitude,"toId":toId,"fromId":fromId,"timestamp":timestamp] as [String : Any]
        childRef.updateChildValues(values as [AnyHashable : Any], withCompletionBlock: {(err, messageRef) in
            if err != nil{
                print(err!)
                return
            }
            let ref = Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/").child("user-messages").child(fromId).child(toId)
            let messageId = childRef.key;
            let values = [messageId:1]
            ref.updateChildValues(values)
            let reciepentRef = Database.database().reference(fromURL: "https://chatappproject-627da.firebaseio.com/").child("user-messages").child(toId).child(fromId)
            reciepentRef.updateChildValues(values)
            print("message saved")
            self.loadChatLogController();
        })

    }
    func loadChatLogController(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "UserViewController") as! ChatLogViewController
        nextViewController.user = self.user
        self.present(nextViewController, animated:true, completion:nil)
        
    }
    func openMapForPlace() {
        
        let latitude: CLLocationDegrees = self.latitude
        let longitude: CLLocationDegrees = self.longitude
        
        let regionDistance:CLLocationDistance = 200
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Your location"
        mapItem.openInMaps(launchOptions: options)
    }
}

