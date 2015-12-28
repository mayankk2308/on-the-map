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
    let appdelegate=UIApplication.sharedApplication().delegate as! AppDelegate!
    var tapRecognizer:UITapGestureRecognizer?=nil
    
    
    //---------------------------------------*/
    
    
    //UI - Manage UI elements and keyboard
    
    override func viewWillAppear(animated: Bool) {
        self.signup.hidden = false
        self.login.enabled = true
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 1.0, green: 0.6, blue: 0.3, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 1.0, green: 0.3, blue: 0.2, alpha: 1.0).CGColor
        self.backgroundGradient = CAGradientLayer()
        self.backgroundGradient!.colors = [colorTop, colorBottom]
        self.backgroundGradient!.locations = [0.0, 1.0]
        self.backgroundGradient!.frame = view.frame
        self.view.layer.insertSublayer(self.backgroundGradient!, atIndex: 0)
        activityIndicator.hidden=true
        self.activityIndicator.hidesWhenStopped=true
        email.delegate=self
        pass.delegate=self
        tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
        tapRecognizer?.numberOfTapsRequired=1
        self.addKeyboardDismissRecognizer()
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.removeKeyboardDismissRecognizer()
    }
    
    override func viewDidDisappear(animated: Bool) {
        login.hidden=false
    }

    @IBAction func signUp(sender: UIButton) {
        let url=NSURL(string: "https://www.udacity.com/account/auth#!/signin")!
        UIApplication.sharedApplication().openURL(url)
    }
    
    //--------------------------------------*/
    
    
    //Login - Initiate and handle login to Udacity account
    
    @IBAction func initiateLogin(sender: UIButton) {
        self.view.endEditing(true)
        view.frame.origin.y=0
        if(!email.text!.isEmpty && !pass.text!.isEmpty){
            self.signup.hidden = true
            initiateLogin()
            }
        else {
            errorAlert("Please check your username and password once again.")
        }
    }
    
    
    func initiateLogin(){
        login.hidden=true
        activityIndicator.hidden=false
        self.activityIndicator.startAnimating()
        email.enabled=false
        pass.enabled=false
        if Reachability.isConnectedToNetwork() {
            udacityAccount.loginWithCredentials(email.text, password: pass.text) {(success, key, error) in
                if success {
                    self.appdelegate.udacitykey=key
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
            dispatch_async(dispatch_get_main_queue()){
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden=true
                let controller=self.storyboard?.instantiateViewControllerWithIdentifier("Nav") as! UINavigationController!
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
        
    func errorAlert(message: String!){
            dispatch_async(dispatch_get_main_queue()){
                self.activityIndicator.stopAnimating()
                self.login.hidden=false
                let alert=UIAlertController(title: "Login Failed", message: message, preferredStyle:  UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.activityIndicator.hidden=true
                self.login.hidden=false
                self.email.enabled=true
                self.pass.enabled=true
            }
        }
    
    
    //---------------------------------------*/
    
    
    //Keyboard - manage keyboard settings
    
    func textFieldDidBeginEditing(textField: UITextField) {
        subscribeToKeyboardNotifications()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        unsubscribeToKeyboardNotifications()
    }
    
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
            view.frame.origin.y-=110
        }
    }
    
    func keyboardWillHide(notification: NSNotification){//adjust view when the keyboard hides
        if(view.frame.origin.y == -110){
            view.frame.origin.y+=110
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {//functional keyboard return key
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
                self.signup.hidden = false
            }
            else {
                self.signup.hidden = true
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
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
}
