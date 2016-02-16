//
//  ViewController.swift
//  MapView
//
//  Created by Archita Bansal on 18/12/15.
//  Copyright © 2015 Archita Bansal. All rights reserved.
//

import UIKit
import MapKit



class ViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager:CLLocationManager = CLLocationManager()
    let googleAPIKey = "AIzaSyBMNaT-KjtguI390tylZ6A4KOi-CiAbNK4"//"AIzaSyCkXIX_OlhHIlPpdyzNsprcEkyh4Y1Co04"
    var currentCentre : CLLocationCoordinate2D! = CLLocationCoordinate2DMake(12.9500, 77.5900){
        willSet{
            print("willset \(currentCentre)")
        }
        didSet{
            print("didset \(currentCentre)")
           
            var diffDist: CLLocationDistance = CLLocation(latitude: oldValue.longitude, longitude: oldValue.latitude).distanceFromLocation(CLLocation(latitude: currentCentre.longitude, longitude: currentCentre.latitude))
            
            if diffDist > 600.0{
                if self.isTA{
                    self.fetchTouristPlaces("bang")
                }
                else{
                    self.searchGooglePlaces(self.type)
                }
                
            }
           
        }
        
        
    }
    var currentDist : CLLocationDistance!
    var type = "food"
    var isSetRegion = false
    var isTA = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        createToolbarView()
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        self.locationManager.startUpdatingLocation()
        mapView.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        
        
      

    }
    
    override func viewWillAppear(animated: Bool) {
        
        
        var location = CLLocationCoordinate2DMake(12.9500, 77.5900)
        
        let span = MKCoordinateSpanMake(0.15, 0.15)
        var region = MKCoordinateRegion(center: location, span: span)
        
        mapView.setRegion(region, animated: true)
        
        
    }
    
    func createToolbarView(){
        
        let optionsButtonView = UIToolbar(frame: CGRect(x: 0, y: 20, width: self.view.bounds.width, height: 44))
        optionsButtonView.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        
        let  foodButton = UIBarButtonItem(title: "FOOD", style: UIBarButtonItemStyle.Done, target: self, action: Selector("optionChoosed:"))
        foodButton.tag = 1
        
        let  templeButton = UIBarButtonItem(title: "TEMPLE", style: UIBarButtonItemStyle.Done, target: self, action: Selector("optionChoosed:"))
        templeButton.tag = 2
        
        let  atmButton = UIBarButtonItem(title: "ATM", style: UIBarButtonItemStyle.Done, target: self, action: Selector("optionChoosed:"))
        atmButton.tag = 3
        
        let  tourAttButton = UIBarButtonItem(title: "TouristAttraction", style: UIBarButtonItemStyle.Done, target: self, action: Selector("optionChoosed:"))
        tourAttButton.tag = 4

        
      //  foodButton.setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.blackColor()], forState: UIControlState.Normal)
        
        let toolbarItems = [flexSpace,tourAttButton,atmButton,templeButton,foodButton]
        optionsButtonView.setItems(toolbarItems, animated: false)
        self.view.addSubview(optionsButtonView)
        
    }
    
    func optionChoosed(sender : UIBarButtonItem ){
        
        switch(sender.tag){
            case 1:
                self.type = "restaurant"
        case 2:
                self.type = "hindu_temple"
        case 3:
                self.type = "atm"
        case 4:
            self.isTA = true
            self.fetchTouristPlaces("bang")
            return

        default:
                break
        }
        
        self.searchGooglePlaces(self.type)
        self.isTA = false
        
    }
    
    func searchGooglePlaces(type:String){
        let url = "https://maps.googleapis.com/maps/api/place/search/json?location=\(self.currentCentre.latitude),\(self.currentCentre.longitude)&radius=500&types=\(type)&sensor=true&key=\(self.googleAPIKey)"
       // let url = "https://maps.googleapis.com/maps/api/place/search/json?location=-33.8670522,151.1957362&radius=500&types=food&sensor=true&key=\(self.googleAPIKey)"
        
        var urlStr : NSString = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!

        let requestUrl = NSURL(string: urlStr as String)

        dispatch_async(dispatch_get_main_queue(), {
            
            var data : NSData = NSData(contentsOfURL: requestUrl!)!
            var error : NSError!
            var json : NSDictionary = NSDictionary()
            do{
                json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as! NSDictionary
                print(json)
            }
            catch{
                
            }
            let results : NSArray = json.valueForKey("results")! as! NSArray
            self.plotPositions(results)
            
            
        })
        
        
    }
    
    
    func fetchTouristPlaces(city : String){
        
        let url = "http://tourist-attraction.mangalmp.com/api/places/bang"
        
        var urlStr : NSString = url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        let requestUrl = NSURL(string: urlStr as String)
        var request = NSMutableURLRequest(URL: requestUrl!)// Creating Http Request
        request.HTTPMethod="GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Creating NSOperationQueue to which the handler block is dispatched when the request completes or failed
        var queue: NSOperationQueue = NSOperationQueue()
        
        // Sending Asynchronous request using NSURLConnection
        
       
        
        NSURLConnection.sendAsynchronousRequest(request, queue: queue) { (response : NSURLResponse?, responseData:NSData?, error:NSError?) -> Void in
            if error != nil
            {
                print(error!.description)
//                self.removeActivityIndicator()
            }
            else
            {
                //var json : NSArray = NSArray()
                do{
                     let res = response as! NSHTTPURLResponse!
                    print("response is \(res)")
                     let jsonString = try NSString(data: responseData!, encoding: NSUTF8StringEncoding)
                     print("response is \(jsonString)")
                     let json = try NSJSONSerialization.JSONObjectWithData(responseData!, options: [.AllowFragments,.MutableContainers]) as? NSArray
                   
                    print(json)
                    self.plotTouristSpots(json!)
                }
                catch{
                    
                }
               
            }
        }
        
        
      
        
    }
    
    func plotTouristSpots(data:NSArray){
        
        for annotation in self.mapView.annotations{
            
            if annotation.isKindOfClass(CustomAnnotation){
                self.mapView.removeAnnotation(annotation)
            }
        }
        
        for(var i=0;i<data.count;i++){
            var place : NSDictionary = data[i] as! NSDictionary
            var name : String = place.valueForKey("name") as! String
            var coordinate : CLLocationCoordinate2D = CLLocationCoordinate2D()
            var latString = place.valueForKey("lat") as! String
            
            if let number = Double(latString) {
                coordinate.latitude = number as! CLLocationDegrees
            }
            var lngString = place.valueForKey("lng") as! String
            if let number = Double(lngString) {
                coordinate.longitude = number as! CLLocationDegrees
            }
            
            var customAnnotation = CustomAnnotation(name: name, address: "bang", coordinates: coordinate)
            
            self.mapView.addAnnotation(customAnnotation)
            

            
        }
        
    }
    
    
    
    func plotPositions(data : NSArray){
        for annotation in self.mapView.annotations{
            
            if annotation.isKindOfClass(CustomAnnotation){
                self.mapView.removeAnnotation(annotation)
            }
        }
        for(var i=0;i<data.count;i++){
            var place:NSDictionary = data[i] as! NSDictionary
            
            var geo : NSDictionary = place.valueForKey("geometry") as! NSDictionary
            var name : String = place.valueForKey("name") as! String
            var address : String = place.valueForKey("vicinity") as! String
            var loc : NSDictionary = geo.valueForKey("location") as! NSDictionary
            var coordinate : CLLocationCoordinate2D = CLLocationCoordinate2D()
            coordinate.latitude = loc.valueForKey("lat") as! CLLocationDegrees
            coordinate.longitude = loc.valueForKey("lng") as! CLLocationDegrees
            
            var customAnnotation = CustomAnnotation(name: name, address: address, coordinates: coordinate)
            
            self.mapView.addAnnotation(customAnnotation)
             
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pinAnnotation"
        
        var annotationView : MKAnnotationView!
        if annotation.isKindOfClass(CustomAnnotation){
            if let dequedView = self.mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKAnnotationView?{
                dequedView.annotation = annotation
                annotationView = dequedView
            }else{
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            annotationView.enabled = true
            var imageView = UIImageView(frame: CGRect(x: -2, y: -4, width: 24, height: 24))
            imageView.layer.cornerRadius = 12.0
            imageView.layer.masksToBounds = true
            
            if (self.type == "food" || self.type == "restaurant"){
               imageView.image = UIImage(named: "restroIcon")
            }else if(self.type == "hindu_temple"){
               imageView.image = UIImage(named: "templeIcon")
            }else if(self.type == "atm"){
                imageView.image = UIImage(named: "atmIcon")
            }
            if self.isTA{
                imageView.image = UIImage(named: "tourAttIcon")
                print(annotation.title)
                
            }
            annotationView.addSubview(imageView)
            annotationView.canShowCallout = true
            //annotationView.animatesDrop = true
            return annotationView
        }
       
        return nil
    }

    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
        
        if !self.isSetRegion{
            if let loc = self.mapView.userLocation.location {
                let region = MKCoordinateRegionMakeWithDistance(loc.coordinate, 2000, 2000)
                self.mapView.setRegion(region, animated: true)
            }
            self.isSetRegion = true
            
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        var mapRect : MKMapRect = self.mapView.visibleMapRect
        var eastMapPoint : MKMapPoint = MKMapPoint(x: MKMapRectGetMinX(mapRect), y: MKMapRectGetMinY(mapRect))
        var westMapPoint : MKMapPoint = MKMapPoint(x: MKMapRectGetMaxX(mapRect), y: MKMapRectGetMaxY(mapRect))
        self.currentDist = MKMetersBetweenMapPoints(eastMapPoint, westMapPoint)
        self.currentCentre = self.mapView.centerCoordinate
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

