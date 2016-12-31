import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //Properties - Buttons, Textfields, Gesture recognizer, Udacity account, and Activity indicator

    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var email: UITextField!
    @IBOutlet var pass: UITextField!
    @IBOutlet var login: UIButton!
    @IBOutlet var signup: UIButton!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    var backgroundGradient: CAGradientLayer? = nil
    var usedNext=false
    let udacityAccount=UdacityLogin()
    let appdelegate=UIApplication.shared.delegate as! AppDelegate!
    var tapRecognizer:UITapGestureRecognizer?=nil
    
    
    //---------------------------------------*/
    
    
    //UI - Manage UI elements and keyboard
    
    override func viewWillAppear(_ animated: Bool) {
        self.signup.isHidden = false
        self.login.isEnabled = true
        self.view.backgroundColor = UIColor.clear
        let colorTop = UIColor(red: 1.0, green: 0.6, blue: 0.3, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 1.0, green: 0.3, blue: 0.2, alpha: 1.0).cgColor
        self.backgroundGradient = CAGradientLayer()
        self.backgroundGradient!.colors = [colorTop, colorBottom]
        self.backgroundGradient!.locations = [0.0, 1.0]
        self.backgroundGradient!.frame = view.frame
        self.view.layer.insertSublayer(self.backgroundGradient!, at: 0)
        activityIndicator.isHidden=true
        self.activityIndicator.hidesWhenStopped=true
        email.delegate=self
        pass.delegate=self
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.handleSingleTap(_:)))
        tapRecognizer?.numberOfTapsRequired=1
        self.addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardDismissRecognizer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        login.isHidden=false
    }

    @IBAction func signUp(_ sender: UIButton) {
        let url=URL(string: "https://www.udacity.com/account/auth#!/signin")!
        UIApplication.shared.openURL(url)
    }
    
    //--------------------------------------*/
    
    
    //Login - Initiate and handle login to Udacity account
    
    @IBAction func initiateLogin(_ sender: UIButton) {
        self.view.endEditing(true)
        view.frame.origin.y=0
        if(!email.text!.isEmpty && !pass.text!.isEmpty){
            self.signup.isHidden = true
            initiateLogin()
            }
        else {
            errorAlert("Please check your username and password once again.")
        }
    }
    
    
    func initiateLogin(){
        login.isHidden=true
        activityIndicator.isHidden=false
        self.activityIndicator.startAnimating()
        email.isEnabled=false
        pass.isEnabled=false
        if Reachability.isConnectedToNetwork() {
            udacityAccount.loginWithCredentials(email.text, password: pass.text) {(success, key, error) in
                if success {
                    self.appdelegate?.udacitykey=key
                    self.completeLogin()
                }
                else {
                    self.errorAlert(error)
                }
            }
        }
        else {
            self.errorAlert("Please check your internet connection and try again.")
        }
    }
    
        func completeLogin(){
            DispatchQueue.main.async{
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden=true
                let controller=self.storyboard?.instantiateViewController(withIdentifier: "Nav") as! UINavigationController!
                self.present(controller!, animated: true, completion: nil)
            }
        }
        
    func errorAlert(_ message: String!){
            DispatchQueue.main.async{
                self.activityIndicator.stopAnimating()
                self.login.isHidden=false
                let alert=UIAlertController(title: "Login Failed", message: message, preferredStyle:  UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.activityIndicator.isHidden=true
                self.login.isHidden=false
                self.email.isEnabled=true
                self.pass.isEnabled=true
            }
        }
    
    
    //---------------------------------------*/
    
    
    //Keyboard - manage keyboard settings
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        subscribeToKeyboardNotifications()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        unsubscribeToKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications(){//subscribe to keyboard notifications
        NotificationCenter.default.addObserver(self,selector: #selector(LoginViewController.keyboardWillShow(_:)),name: NSNotification.Name.UIKeyboardWillShow,object:nil)
        NotificationCenter.default.addObserver(self,selector: #selector(LoginViewController.keyboardWillHide(_:)),name: NSNotification.Name.UIKeyboardWillHide,object:nil)
    }
    
    func unsubscribeToKeyboardNotifications(){//unsubscribe to keyboard notifications
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name.UIKeyboardWillShow,object:nil)
        NotificationCenter.default.removeObserver(self,name: NSNotification.Name.UIKeyboardWillHide,object:nil)
    }
    
    func keyboardWillShow(_ notification: Notification){//adjust view when the keyboard shows
        if(view.frame.origin.y==0){
            view.frame.origin.y-=110
        }
    }
    
    func keyboardWillHide(_ notification: Notification){//adjust view when the keyboard hides
        if(view.frame.origin.y == -110){
            view.frame.origin.y+=110
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {//functional keyboard return key
        if(textField==email){
            unsubscribeToKeyboardNotifications()
            textField.resignFirstResponder()
            pass.becomeFirstResponder()
            subscribeToKeyboardNotifications()
            return true
        }
        else {
            view.endEditing(true)
            view.frame.origin.y=0
            if(email.text!.isEmpty){
                errorAlert("Please check your username and password once again.")
                self.signup.isHidden = false
            }
            else {
                self.signup.isHidden = true
                initiateLogin()
            }
            return false
        }

    }
    
    
    //---------------------------------------*/
    
    
    //Tap - Manage gesture recognizer
    
    func addKeyboardDismissRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer!)
    }
    
    func removeKeyboardDismissRecognizer() {
        self.view.removeGestureRecognizer(tapRecognizer!)
    }
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
