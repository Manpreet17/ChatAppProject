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
import os.log
class LocationViewController: UIViewController,CLLocationManagerDelegate {
    var user : Users?
    var city : String?
    var country : String?
    var latitude = 0.0;
    var longitude = 0.0;
    var locationManager:CLLocationManager!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        determineMyCurrentLocation();
    }
    
    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
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
        latitude = userLocation.coordinate.latitude;
        longitude = userLocation.coordinate.longitude;
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    @IBAction func sendLocation(_ sender: Any) {
        determineMyCurrentLocation();
        print("user latitude = \(latitude)");
        print("user longitude = \(longitude)");
        sendLocationMessage(latitude: latitude,longitude: longitude)
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
    
    @IBAction func BackToChatcontroller(_ sender: Any) {
         loadChatLogController();
    }
    
    func fetchCityAndCountry(currentLocation: CLLocation,completion:@escaping (String)->()){
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation, completionHandler: {(placemarks, error) -> Void in
            
            if (error != nil) {
                
                os_log("Reverse geocoder failed with error %s", type: OSLogType.error, error!.localizedDescription)
            } else {
                
                let place = placemarks![0]
                completion(place.locality!)
            }
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

