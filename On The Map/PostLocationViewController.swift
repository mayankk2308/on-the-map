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
    
    override func viewWillAppear(_ animated: Bool) {
        self.locationField.isEnabled = false
        self.findOnMap.isHidden = true
        self.activity.isHidden = true
        self.findOnMap.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 15)
        self.cancel.titleLabel?.font = UIFont(name: "Roboto-Regular", size: 15)
        self.tapGestureRecognizer=UITapGestureRecognizer(target: self, action: #selector(PostLocationViewController.handleSingleTap(_:)))
        self.locationField.delegate = self
        whereLabel.font = UIFont(name: "Roboto-Thin", size: 24)!
        studyingLabel.font = UIFont(name: "Roboto-Medium", size: 24)!
        todayLabel.font = UIFont(name: "Roboto-Thin", size: 24)!
        locationField.font = UIFont(name: "Roboto-Regular", size: 18)!
        locationField.attributedPlaceholder = NSAttributedString(string: "Enter your location here.", attributes: [NSForegroundColorAttributeName: UIColor.lightText])
        appdelegate = UIApplication.shared.delegate as! AppDelegate!
        if appdelegate.firstName != nil {
            self.findOnMap.isHidden = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        appdelegate = UIApplication.shared.delegate as! AppDelegate!
        if appdelegate.firstName == nil {
            self.activity.isHidden = false
            self.activity.startAnimating()
            if Reachability.isConnectedToNetwork() {
                self.udacityInfo.getUserData(appdelegate.udacitykey) {(success, firstName, lastName, error) in
                    if success {
                        DispatchQueue.main.async {
                            self.locationField.isEnabled = true
                            self.manageActivity()
                            self.appdelegate.firstName = firstName
                            self.appdelegate.lastName = lastName
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.manageActivity()
                            self.errorAlert("Download Failed", message: error)
                        }
                    }
                }
            }
            else {
                self.errorAlert("Download Failed", message: "Please check your internet connection and try again.")
                self.activity.stopAnimating()
                self.activity.isHidden = true
            }
        }
        else {
            self.manageActivity()
            self.locationField.isEnabled = true
        }
    }
    
    //Geocoding - Initiate geocoding of string
    
    @IBAction func initiateGeocoding(_ sender: UIButton) {
        if locationField.text!.isEmpty {
            self.errorAlert("Cannot Find Location", message: "Please enter a location before searching for it on the map.")
        }
        else {
            startGeocoding()
        }
    }
    
    func startGeocoding() {
        self.findOnMap.isHidden = true
        self.activity.isHidden = false
        self.activity.startAnimating()
        if Reachability.isConnectedToNetwork() {
            self.geocodeString(locationField.text) { (error, lat, lon) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.appdelegate.mapString = self.locationField.text
                        self.appdelegate.geolat = lat
                        self.appdelegate.geolon = lon
                        self.activity.stopAnimating()
                        self.activity.isHidden = true
                        let controller = self.storyboard?.instantiateViewController(withIdentifier: "postMap") as! PostMapViewController!
                        self.present(controller!, animated: false, completion: nil)
                    }
                }
                else {
                    DispatchQueue.main.async {
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
    
    func geocodeString(_ string: String!, completionHandler: @escaping (_ error: String?, _ lat: CLLocationDegrees?, _ lon: CLLocationDegrees?) -> Void) {
        CLGeocoder().geocodeAddressString(string, completionHandler: { (placemark, error) in
            if error != nil {
                completionHandler(error!.localizedDescription, nil, nil)
            }
            else {
                let place = placemark![0]
                completionHandler(nil, place.location!.coordinate.latitude, place.location!.coordinate.longitude)
            }
        })
    }
    
    //Keyboard - Manage the keyboard
    
    
    func subscribeToKeyboardNotifications(){//subscribe to keyboard notifications
        NotificationCenter.default.addObserver(self,selector: #selector(PostLocationViewController.keyboardWillShow(_:)),name: NSNotification.Name.UIKeyboardWillShow,object:nil)
        NotificationCenter.default.addObserver(self,selector: #selector(PostLocationViewController.keyboardWillHide(_:)),name: NSNotification.Name.UIKeyboardWillHide,object:nil)
    }
    
    func unsubscribeToKeyboardNotifications(){//unsubscribe to keyboard notifications
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name.UIKeyboardWillShow,object:nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name.UIKeyboardWillHide,object:nil)
    }
    
    func keyboardWillShow(_ notification: Notification){//adjust view when the keyboard shows
        if(view.frame.origin.y==0){
            view.frame.origin.y-=35
        }
    }
    
    func keyboardWillHide(_ notification: Notification){//adjust view when the keyboard hides
        if(view.frame.origin.y == -35){
            view.frame.origin.y+=35
        }
    }
    
    @IBAction func returnToOtherStudentPosView(_ sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func manageActivity() {
        self.activity.stopAnimating()
        self.activity.isHidden = true
        self.findOnMap.isHidden = false
    }
    
    func errorAlert(_ title: String!, message: String!) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //Textfield - Manage text fields
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.subscribeToKeyboardNotifications()
        self.view.addGestureRecognizer(tapGestureRecognizer)
        textField.placeholder=""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.unsubscribeToKeyboardNotifications()
        self.view.removeGestureRecognizer(tapGestureRecognizer)
        if textField.text!.isEmpty {
            textField.attributedPlaceholder = NSAttributedString(string: "Enter your location here.", attributes: [NSForegroundColorAttributeName: UIColor.lightText])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.startGeocoding()
        self.view.endEditing(true)
        return true
    }
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
