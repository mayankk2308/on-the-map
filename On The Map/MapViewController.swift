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
    
    override func viewWillAppear(_ animated: Bool) {
        appdelegate=UIApplication.shared.delegate as! AppDelegate
        self.map.delegate=self
        if(appdelegate.studentInfo.isEmpty){
            self.activity.isHidden=false
            self.tempView.isHidden=false
            self.activity.startAnimating()
            if(Reachability.isConnectedToNetwork()){
                studentData.getStudentData(){(success, error) in
                    DispatchQueue.main.async{
                        if !success {
                            DispatchQueue.main.async{
                                self.activityHandler()
                                self.displayError("Download Failed", message: error!)
                            }
                        }
                        else {
                            DispatchQueue.main.async{
                                self.activityHandler()
                                self.addAnnotations()
                            }
                        }
                    }
                }
            }
            else {
                DispatchQueue.main.async{
                    self.activityHandler()
                    self.displayError("Download Failed", message: "Please check your internet connection and try again.")
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if annotations.isEmpty {
            self.addAnnotations()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if !annotations.isEmpty {
            self.map.removeAnnotations(self.annotations)
            self.annotations = [MKPointAnnotation]()
        }
    }
    
    
    func activityHandler() {
        self.activity.stopAnimating()
        self.tempView.isHidden=true
    }
    
    
    func displayError(_ title: String, message: String){
        let alert=UIAlertController(title: title, message: message, preferredStyle:  UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseid="studentPin"
        var annotationView=mapView.dequeueReusableAnnotationView(withIdentifier: reuseid) as! MKPinAnnotationView!
        if annotationView == nil {
            annotationView=MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseid)
            annotationView?.canShowCallout=true
            annotationView?.animatesDrop=true
            annotationView?.rightCalloutAccessoryView=UIButton(type: UIButtonType.infoLight)
        }
        else {
            annotationView?.annotation=annotation
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView,annotationView view: MKAnnotationView,calloutAccessoryControlTapped control: UIControl){
        if UIApplication.shared.canOpenURL(URL(string: view.annotation!.subtitle!!)!) {
            UIApplication.shared.openURL(URL(string: view.annotation!.subtitle!!)!)
        }
        else {
            self.displayError("URL Invalid", message: "Cannot open URL because it is invalid.")
        }
    }
}
