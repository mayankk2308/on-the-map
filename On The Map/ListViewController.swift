import UIKit

class ListViewController: UITableViewController {
    
    //Properties - Activity indicator, it's temporary view, labels, and student data
    
    @IBOutlet var activityView: UIView!
    @IBOutlet var findLabel: UILabel!
    let studentData=StudentLocation()
    var appdelegate:AppDelegate!
    
    //UI - Manage activity indicator and table view settings and appearance
    
    override func viewWillAppear(animated: Bool) {
        appdelegate=UIApplication.sharedApplication().delegate as! AppDelegate!
        findLabel.text="Finding your friends..."
        let topBarSize=(self.navigationController?.navigationBar.frame)!.height + 20.0
        let topBarWidth=UIApplication.sharedApplication().statusBarFrame.width
        let temp=UIView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: topBarWidth, height: topBarSize)))
        let bottomTemp=UIView(frame: (self.tabBarController?.tabBar.frame)!)
        self.tableView.tableHeaderView=UIView()
        self.tableView.tableFooterView=activityView
        self.tableView.scrollIndicatorInsets.bottom=(self.tabBarController?.tabBar.frame)!.height
        self.tableView.scrollIndicatorInsets.top=topBarSize
        tableView.rowHeight=50
        if(appdelegate.studentInfo.isEmpty){
            if(Reachability.isConnectedToNetwork()){
                studentData.getStudentData(){(success, error) in
                    if !success {
                        dispatch_async(dispatch_get_main_queue()){
                            self.tableView.tableHeaderView=UIView()
                            self.findLabel.text="Unable to retrieve data."
                        }
                    }
                    else {
                        dispatch_async(dispatch_get_main_queue()){
                            self.tableView.tableHeaderView=temp
                            self.tableView.tableFooterView=bottomTemp
                            self.tableView.reloadData()
                        }
                    }
                }
            }
            else {
                findLabel.text="No internet connection available."
            }
        }
        else {
            self.tableView.tableHeaderView=temp
            self.tableView.tableFooterView=bottomTemp
            self.tableView.reloadData()
        }
    }
    
    //Data - Load and manage data in table view cells
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        cell.textLabel?.text="\(appdelegate.studentInfo[indexPath.row].firstName) \(appdelegate.studentInfo[indexPath.row].lastName)"
        cell.textLabel?.font=UIFont(name: "AvenirNext-Regular", size: 18)!
        cell.detailTextLabel?.font=UIFont(name: "AvenirNext-Regular", size: 12)!
        cell.detailTextLabel?.text=appdelegate.studentInfo[indexPath.row].url
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let url=NSURL(string: appdelegate.studentInfo[indexPath.row].url) {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            UIApplication.sharedApplication().openURL(url)
        }
        else {
            let alert = UIAlertController(title: "Invalid URL", message: "Cannot open URL because it is invalid.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appdelegate.studentInfo.count
    }
}
