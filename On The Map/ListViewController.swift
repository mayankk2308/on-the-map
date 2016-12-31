import UIKit

class ListViewController: UITableViewController {
    
    //Properties - Activity indicator, it's temporary view, labels, and student data
    
    @IBOutlet var activityView: UIView!
    @IBOutlet var findLabel: UILabel!
    let studentData=StudentLocation()
    var appdelegate:AppDelegate!
    
    //UI - Manage activity indicator and table view settings and appearance
    
    override func viewWillAppear(_ animated: Bool) {
        appdelegate=UIApplication.shared.delegate as! AppDelegate!
        findLabel.text="Finding your friends..."
        let topBarSize=(self.navigationController?.navigationBar.frame)!.height + 20.0
        let topBarWidth=UIApplication.shared.statusBarFrame.width
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
                        DispatchQueue.main.async{
                            self.tableView.tableHeaderView=UIView()
                            self.findLabel.text="Unable to retrieve data."
                        }
                    }
                    else {
                        DispatchQueue.main.async{
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
        cell?.textLabel?.text="\(appdelegate.studentInfo[indexPath.row].firstName) \(appdelegate.studentInfo[indexPath.row].lastName)"
        cell?.textLabel?.font=UIFont(name: "AvenirNext-Regular", size: 18)!
        cell?.detailTextLabel?.font=UIFont(name: "AvenirNext-Regular", size: 12)!
        cell?.detailTextLabel?.text=appdelegate.studentInfo[indexPath.row].url
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let url=URL(string: appdelegate.studentInfo[indexPath.row].url) {
            tableView.deselectRow(at: indexPath, animated: true)
            UIApplication.shared.openURL(url)
        }
        else {
            let alert = UIAlertController(title: "Invalid URL", message: "Cannot open URL because it is invalid.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appdelegate.studentInfo.count
    }
}
