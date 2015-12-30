//
//  CustomAnnotation.swift
//  MapView
//
//  Created by Archita Bansal on 20/12/15.
//  Copyright © 2015 Archita Bansal. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject , MKAnnotation {
    
    var name : String?
    var address : String?
    var coordinate : CLLocationCoordinate2D
    var image : UIImage?
    
    init(name : String,address : String, coordinates : CLLocationCoordinate2D){
        self.name = name
        self.address = address
        self.coordinate = coordinates
        
    }

    var title: String? {
        return name
    }
    var subtitle: String? {
        return address
    }

}
