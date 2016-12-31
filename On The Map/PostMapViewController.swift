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
    
    override func viewWillAppear(_ animated: Bool) {
        self.activity.isHidden = true
        appdelegate = UIApplication.shared.delegate as! AppDelegate!
        touchRecognizer = UITapGestureRecognizer(target: self, action: #selector(PostMapViewController.handleSingleTap(_:)))
        urlField.delegate = self
        urlField.font = UIFont (name: "Roboto-Regular", size: 18)
        urlField.attributedPlaceholder = NSAttributedString(string: "Enter URL here.", attributes: [NSForegroundColorAttributeName: UIColor.lightText])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() {
            self.addAnnotation()
        }
        else {
            self.displayAlert("Download Failed", message: "Please check your internet connection and try again.")
        }
    }
    
    //User Location - Post user location and URL to server
    
    @IBAction func postLocation(_ sender: UIButton) {
        if self.urlField.text!.isEmpty {
            self.displayAlert("Cannot Post Data", message: "Please enter a URL.")
        }
        else if UIApplication.shared.canOpenURL(URL(string: self.urlField.text!)!) {
            if Reachability.isConnectedToNetwork() {
                self.activity.isHidden = false
                self.activity.startAnimating()
                StudentLocation().postStudentLocation() { success, error in
                    if success {
                        DispatchQueue.main.async {
                            self.activity.stopAnimating()
                            self.activity.isHidden = true
                            self.appdelegate.studentInfo = [StudentInformation]()
                            StudentLocation().getStudentData(){ success, error in
                                return
                            }
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.activity.stopAnimating()
                            self.activity.isHidden = true
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
    
    @IBAction func dismissView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func displayAlert(_ title: String!, message: String!) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
    
    //Textfield - Manage textfield and keyboard
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.view.addGestureRecognizer(self.touchRecognizer)
        urlField.placeholder = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.removeGestureRecognizer(self.touchRecognizer)
        if textField.text!.isEmpty {
            self.post.isEnabled = false
            urlField.attributedPlaceholder = NSAttributedString(string: "Enter your place.", attributes: [NSForegroundColorAttributeName: UIColor.lightText])
        }
        else {
            if UIApplication.shared.canOpenURL(URL(string: textField.text!)!) {
                appdelegate.url = textField.text
            }
            else {
                self.displayAlert("Invalid URL", message: "Please check your URL and try again.")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func handleSingleTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
