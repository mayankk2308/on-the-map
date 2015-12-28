import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    //Properties - Map, Student data, and Annotations
    
    let studentData=StudentLocation()
    @IBOutlet var map: MKMapView!
    var url:String!
    var appdelegate:AppDelegate!
    @IBOutlet var tempView: UIView!
    @IBOutlet var activity: UIActivityIndicatorView!
    var annotations = [MKPointAnnotation]()
    
    //UI - Manage Activity view and map view
    
    override func viewWillAppear(animated: Bool) {
        appdelegate=UIApplication.sharedApplication().delegate as! AppDelegate
        self.map.delegate=self
        if(appdelegate.studentInfo.isEmpty){
            self.activity.hidden=false
            self.tempView.hidden=false
            self.activity.startAnimating()
            if(Reachability.isConnectedToNetwork()){
                studentData.getStudentData(){(success, error) in
                    dispatch_async(dispatch_get_main_queue()){
                        if !success {
                            dispatch_async(dispatch_get_main_queue()){
                                self.activityHandler()
                                self.displayError("Download Failed", message: error)
                            }
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue()){
                                self.activityHandler()
                                self.addAnnotations()
                            }
                        }
                    }
                }
            }
            else {
                dispatch_async(dispatch_get_main_queue()){
                    self.activityHandler()
                    self.displayError("Download Failed", message: "Please check your internet connection and try again.")
                }
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if annotations.isEmpty {
            self.addAnnotations()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        if !annotations.isEmpty {
            self.map.removeAnnotations(self.annotations)
            self.annotations = [MKPointAnnotation]()
        }
    }
    
    
    func activityHandler() {
        self.activity.stopAnimating()
        self.tempView.hidden=true
    }
    
    
    func displayError(title: String, message: String){
        let alert=UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Student Locations - Process and display student locations on a map
    
    func addAnnotations(){
        for student in appdelegate.studentInfo {
            let annotation=MKPointAnnotation()
            annotation.coordinate.latitude=student.lat
            annotation.coordinate.longitude=student.lon
            annotation.title="\(student.firstName) \(student.lastName)"
            annotation.subtitle=student.url
            self.annotations.append(annotation)
        }
        self.map.addAnnotations(annotations)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseid="studentPin"
        var annotationView=mapView.dequeueReusableAnnotationViewWithIdentifier(reuseid) as! MKPinAnnotationView!
        if annotationView == nil {
            annotationView=MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseid)
            annotationView.canShowCallout=true
            annotationView.animatesDrop=true
            annotationView.rightCalloutAccessoryView=UIButton(type: UIButtonType.InfoLight)
        }
        else {
            annotationView.annotation=annotation
        }
        return annotationView
    }
    
    func mapView(mapView: MKMapView,annotationView view: MKAnnotationView,calloutAccessoryControlTapped control: UIControl){
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: view.annotation!.subtitle!!)!) {
            UIApplication.sharedApplication().openURL(NSURL(string: view.annotation!.subtitle!!)!)
        }
        else {
            self.displayError("URL Invalid", message: "Cannot open URL because it is invalid.")
        }
    }
}
