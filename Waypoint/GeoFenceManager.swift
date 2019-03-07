//
//  GeoFenceManager.swift
//  Waypoint
//
//  Created by -Theory- on 1/4/19.
//  Copyright © 2019 Ethan Alvey. All rights reserved.
//

import Foundation
import CoreLocation

struct GeoFence {
    
    var locationManager : CLLocationManager = CLLocationManager()
    
    //creates geofence
    func setUpGeofenceOnNoteLocation(latitude : Double, longitude : Double, noteTitle : String) {
        let geofenceRegionCenter = CLLocationCoordinate2DMake(latitude, longitude);
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter, radius: 100, identifier: noteTitle);
        geofenceRegion.notifyOnExit = true;
        geofenceRegion.notifyOnEntry = true;
        self.locationManager.startMonitoring(for: geofenceRegion)
    }
    
    //gets called when u go into geofence
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("it really do work chief")
        //Good place to schedule a local notification
    }
    
    //checks to see if location is enabled before doin the other stuff
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedAlways) {
            self.setUpGeofenceOnNoteLocation(latitude: 0, longitude: 0, noteTitle: "")
        }
    }

}
