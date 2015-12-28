import UIKit
import MapKit

class PostMapViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    //Properties - URL textfield, gesture recognizer, post button, and activity indicator
    
    @IBOutlet var urlField: UITextField!
    var touchRecognizer: UITapGestureRecognizer!
    @IBOutlet var map: MKMapView!
    var appdelegate: AppDelegate!
    @IBOutlet var post: OverlayButton!
    @IBOutlet var activity: UIActivityIndicatorView!
    
    //UI - Manage activity indicator and text field
    
    override func viewWillAppear(animated: Bool) {
        self.activity.hidden = true
        appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
        touchRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        urlField.delegate = self
        urlField.font = UIFont (name: "Roboto-Regular", size: 18)
        urlField.attributedPlaceholder = NSAttributedString(string: "Enter URL here.", attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor()])
    }
    
    override func viewDidAppear(animated: Bool) {
        if Reachability.isConnectedToNetwork() {
            self.addAnnotation()
        }
        else {
            self.displayAlert("Download Failed", message: "Please check your internet connection and try again.")
        }
    }
    
    //User Location - Post user location and URL to server
    
    @IBAction func postLocation(sender: UIButton) {
        if self.urlField.text!.isEmpty {
            self.displayAlert("Cannot Post Data", message: "Please enter a URL.")
        }
        else if UIApplication.sharedApplication().canOpenURL(NSURL(string: self.urlField.text!)!) {
            if Reachability.isConnectedToNetwork() {
                self.activity.hidden = false
                self.activity.startAnimating()
                StudentLocation().postStudentLocation() { success, error in
                    if success {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.activity.stopAnimating()
                            self.activity.hidden = true
                            self.appdelegate.studentInfo = [StudentInformation]()
                            StudentLocation().getStudentData(){ success, error in
                                return
                            }
                            self.dismissViewControllerAnimated(true, completion: nil)
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.activity.stopAnimating()
                            self.activity.hidden = true
                            self.displayAlert("Post Failed", message: error)
                        }
                    }
                }
            }
            else {
                self.displayAlert("Post Failed", message: "Please check your internet connection and try again.")
            }
        }
        else {
            self.displayAlert("Invalid URL", message: "Please check your URL and try again.")
        }
        
    }
    
    @IBAction func dismissView(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func displayAlert(title: String!, message: String!) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Map - Show user map annotation preview
    
    func addAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = appdelegate.geolat
        annotation.coordinate.longitude = appdelegate.geolon
        annotation.title = "\(appdelegate.firstName) \(appdelegate.lastName)"
        annotation.subtitle = "Your link will be here."
        self.map.setRegion(MKCoordinateRegion(center: annotation.coordinate, span: MKCoordinateSpanMake(0.01, 0.01)), animated: true)
        self.map.addAnnotation(annotation)
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
    
    //Textfield - Manage textfield and keyboard
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.view.addGestureRecognizer(self.touchRecognizer)
        urlField.placeholder = ""
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.view.removeGestureRecognizer(self.touchRecognizer)
        if textField.text!.isEmpty {
            self.post.enabled = false
            urlField.attributedPlaceholder = NSAttributedString(string: "Enter your place.", attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor()])
        }
        else {
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: textField.text!)!) {
                appdelegate.url = textField.text
            }
            else {
                self.displayAlert("Invalid URL", message: "Please check your URL and try again.")
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func handleSingleTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
