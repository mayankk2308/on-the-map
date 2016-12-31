import UIKit

class TabManager: UITabBarController {
    
    //Properties - Log out & Location posting buttons
    
    @IBOutlet var logoutButton: UIBarButtonItem!
    @IBOutlet var pin: UIBarButtonItem!
    
    //UI - Manage navigation and tab bar item colors
    
    override func viewWillAppear(_ animated: Bool) {
        self.pin.isEnabled = true
        self.logoutButton.isEnabled = true
        self.tabBarItem.isEnabled = true
        self.view.isUserInteractionEnabled = true
        self.navigationItem.leftBarButtonItem?.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 18)!], for: UIControlState())
        self.navigationItem.leftBarButtonItem?.tintColor=UIColor.purple
        self.navigationItem.rightBarButtonItem?.tintColor=UIColor.purple
        navigationController?.navigationBar.titleTextAttributes=[NSFontAttributeName:UIFont(name: "AvenirNext-Medium", size: 18)!]
        let appearance=UITabBarItem.appearance()
        appearance.setTitleTextAttributes([NSFontAttributeName:UIFont(name: "AvenirNext-Medium", size: 11.5)!], for: UIControlState())
        let bar=UITabBar.appearance()
        bar.tintColor=UIColor.purple
    }
    
    //Post - post user location
    
    @IBAction func postLocation(_ sender: UIBarButtonItem) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "postInfo") as! PostLocationViewController!
        self.present(controller!, animated: true, completion: nil)
    }
    @IBAction func logout(_ sender: UIBarButtonItem) {
        let udacitylogut=UdacityLogin()
        if(Reachability.isConnectedToNetwork()){
            self.pin.isEnabled = false
            self.logoutButton.isEnabled = false
            self.tabBarItem.isEnabled = false
            self.view.isUserInteractionEnabled = false
            self.navigationItem.title="Logging Out..."
            udacitylogut.logout(){(success) in
                DispatchQueue.main.async{
                    if success {
                        let appdelegate=UIApplication.shared.delegate as! AppDelegate
                        appdelegate.studentInfo = [StudentInformation]()
                        appdelegate.firstName = nil
                        self.dismiss(animated: true, completion: nil)
                    }
                    else {
                        self.navigationItem.title="On The Map"
                        self.pin.isEnabled = true
                        self.logoutButton.isEnabled = true
                        self.tabBarItem.isEnabled = true
                        self.view.isUserInteractionEnabled = true
                        self.errorAlert("Server error. Unable to logout.")
                    }
                }
            }
        }
        else {
            self.errorAlert("Unable to connect to the internet.")
        }
    }
    
    func errorAlert(_ message: String!){
        let alert=UIAlertController(title: "Logout Failed", message: message, preferredStyle:  UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

