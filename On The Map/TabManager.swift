import UIKit

class TabManager: UITabBarController {
    
    //Properties - Log out & Location posting buttons
    
    @IBOutlet var logoutButton: UIBarButtonItem!
    @IBOutlet var pin: UIBarButtonItem!
    
    //UI - Manage navigation and tab bar item colors
    
    override func viewWillAppear(animated: Bool) {
        self.pin.enabled = true
        self.logoutButton.enabled = true
        self.tabBarItem.enabled = true
        self.view.userInteractionEnabled = true
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 18)!], forState: UIControlState.Normal)
        self.navigationItem.leftBarButtonItem?.tintColor=UIColor.purpleColor()
        self.navigationItem.rightBarButtonItem?.tintColor=UIColor.purpleColor()
        navigationController?.navigationBar.titleTextAttributes=[NSFontAttributeName:UIFont(name: "AvenirNext-Medium", size: 18)!]
        let appearance=UITabBarItem.appearance()
        appearance.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "AvenirNext-Medium", size: 11.5)!], forState: .Normal)
        let bar=UITabBar.appearance()
        bar.tintColor=UIColor.purpleColor()
    }
    
    //Post - post user location
    
    @IBAction func postLocation(sender: UIBarButtonItem) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("postInfo") as! PostLocationViewController!
        self.presentViewController(controller, animated: true, completion: nil)
    }
    @IBAction func logout(sender: UIBarButtonItem) {
        let udacitylogut=UdacityLogin()
        if(Reachability.isConnectedToNetwork()){
            self.pin.enabled = false
            self.logoutButton.enabled = false
            self.tabBarItem.enabled = false
            self.view.userInteractionEnabled = false
            self.navigationItem.title="Logging Out..."
            udacitylogut.logout(){(success) in
                dispatch_async(dispatch_get_main_queue()){
                    if success {
                        let appdelegate=UIApplication.sharedApplication().delegate as! AppDelegate
                        appdelegate.studentInfo = [StudentInformation]()
                        appdelegate.firstName = nil
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                    else {
                        self.navigationItem.title="On The Map"
                        self.pin.enabled = true
                        self.logoutButton.enabled = true
                        self.tabBarItem.enabled = true
                        self.view.userInteractionEnabled = true
                        self.errorAlert("Server error. Unable to logout.")
                    }
                }
            }
        }
        else {
            self.errorAlert("Unable to connect to the internet.")
        }
    }
    
    func errorAlert(message: String!){
        let alert=UIAlertController(title: "Logout Failed", message: message, preferredStyle:  UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

