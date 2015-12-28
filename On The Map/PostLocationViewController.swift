import UIKit
import MapKit

class PostLocationViewController: UIViewController, UITextFieldDelegate {
    
    //Properties - Buttons, activity indicator, text fields, gesture recognizer, and user acoount details
    
    @IBOutlet var cancel: UIButton!
    @IBOutlet var findOnMap: UIButton!
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var whereLabel: UILabel!
    @IBOutlet var studyingLabel: UILabel!
    @IBOutlet var todayLabel: UILabel!
    @IBOutlet var locationField: UITextField!
    var tapGestureRecognizer: UITapGestureRecognizer!
    let udacityInfo = UdacityLogin()
    var appdelegate: AppDelegate!
    
    //UI - Manage buttons and textfields
    
    override func viewWillAppear(animated: Bool) {
        self.locationField.enabled = false
        self.findOnMap.hidden = true
        self.activity.hidden = true
        self.findOnMap.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 15)
        self.cancel.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 15)
        self.tapGestureRecognizer=UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        self.locationField.delegate = self
        whereLabel.font = UIFont(name: "Roboto-Thin", size: 24)!
        studyingLabel.font = UIFont(name: "Roboto-Medium", size: 24)!
        todayLabel.font = UIFont(name: "Roboto-Thin", size: 24)!
        locationField.font = UIFont(name: "Roboto-Regular", size: 18)!
        locationField.attributedPlaceholder = NSAttributedString(string: "Enter your location here.", attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor()])
        appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
        if appdelegate.firstName != nil {
            self.findOnMap.hidden = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate!
        if appdelegate.firstName == nil {
            self.activity.hidden = false
            self.activity.startAnimating()
            if Reachability.isConnectedToNetwork() {
                self.udacityInfo.getUserData(appdelegate.udacitykey) {(success, firstName, lastName, error) in
                    if success {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.locationField.enabled = true
                            self.manageActivity()
                            self.appdelegate.firstName = firstName
                            self.appdelegate.lastName = lastName
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.manageActivity()
                            self.errorAlert("Download Failed", message: error)
                        }
                    }
                }
            }
            else {
                self.errorAlert("Download Failed", message: "Please check your internet connection and try again.")
                self.activity.stopAnimating()
                self.activity.hidden = true
            }
        }
        else {
            self.manageActivity()
            self.locationField.enabled = true
        }
    }
    
    //Geocoding - Initiate geocoding of string
    
    @IBAction func initiateGeocoding(sender: UIButton) {
        if locationField.text!.isEmpty {
            self.errorAlert("Cannot Find Location", message: "Please enter a location before searching for it on the map.")
        }
        else {
            startGeocoding()
        }
    }
    
    func startGeocoding() {
        self.findOnMap.hidden = true
        self.activity.hidden = false
        self.activity.startAnimating()
        if Reachability.isConnectedToNetwork() {
            self.geocodeString(locationField.text) { (error, lat, lon) in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.appdelegate.mapString = self.locationField.text
                        self.appdelegate.geolat = lat
                        self.appdelegate.geolon = lon
                        self.activity.stopAnimating()
                        self.activity.hidden = true
                        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("postMap") as! PostMapViewController!
                        self.presentViewController(controller, animated: false, completion: nil)
                    }
                }
                else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.manageActivity()
                        self.errorAlert("Download Failed", message: error)
                    }
                }
            }
            
        }
        else {
            self.errorAlert("Download Failed", message: "Please check your internet connection and try again.")
            self.manageActivity()
        }
    }
    
    func geocodeString(string: String!, completionHandler: (error: String!, lat: CLLocationDegrees!, lon: CLLocationDegrees!) -> Void) {
        CLGeocoder().geocodeAddressString(string, completionHandler: { (placemark, error) in
            if error != nil {
                completionHandler(error: error!.localizedDescription, lat: nil, lon: nil)
            }
            else {
                let place = placemark![0]
                completionHandler(error: nil, lat: place.location!.coordinate.latitude, lon: place.location!.coordinate.longitude)
            }
        })
    }
    
    //Keyboard - Manage the keyboard
    
    
    func subscribeToKeyboardNotifications(){//subscribe to keyboard notifications
        NSNotificationCenter.defaultCenter().addObserver(self,selector: "keyboardWillShow:",name: UIKeyboardWillShowNotification,object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self,selector: "keyboardWillHide:",name: UIKeyboardWillHideNotification,object:nil)
    }
    
    func unsubscribeToKeyboardNotifications(){//unsubscribe to keyboard notifications
        NSNotificationCenter.defaultCenter().removeObserver(self,name: UIKeyboardWillShowNotification,object:nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,name: UIKeyboardWillHideNotification,object:nil)
    }
    
    func keyboardWillShow(notification: NSNotification){//adjust view when the keyboard shows
        if(view.frame.origin.y==0){
            view.frame.origin.y-=35
        }
    }
    
    func keyboardWillHide(notification: NSNotification){//adjust view when the keyboard hides
        if(view.frame.origin.y == -35){
            view.frame.origin.y+=35
        }
    }
    
    @IBAction func returnToOtherStudentPosView(sender: UIButton) {
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func manageActivity() {
        self.activity.stopAnimating()
        self.activity.hidden = true
        self.findOnMap.hidden = false
    }
    
    func errorAlert(title: String!, message: String!) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Textfield - Manage text fields
    
    func textFieldDidBeginEditing(textField: UITextField) {
        self.subscribeToKeyboardNotifications()
        self.view.addGestureRecognizer(tapGestureRecognizer)
        textField.placeholder=""
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        self.unsubscribeToKeyboardNotifications()
        self.view.removeGestureRecognizer(tapGestureRecognizer)
        if textField.text!.isEmpty {
            textField.attributedPlaceholder = NSAttributedString(string: "Enter your location here.", attributes: [NSForegroundColorAttributeName: UIColor.lightTextColor()])
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.startGeocoding()
        self.view.endEditing(true)
        return true
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
