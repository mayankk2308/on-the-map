import Foundation
import MapKit

class StudentLocation: NSObject {
    
    var appdelegate: AppDelegate!
    
    //Get Student Data - Obtain student data
    
    func getStudentData(completionHandler: (success: Bool, error: String!)->Void){
        appdelegate=UIApplication.sharedApplication().delegate as! AppDelegate
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=300")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, error: error!.localizedDescription)
            }
            else {
                do {
                    let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    if let students=parsedResult.valueForKey("results") as? NSArray {
                        dispatch_async(dispatch_get_main_queue()){
                            for student in students {
                                let studentDictionary=student as! NSDictionary
                                self.appdelegate.studentInfo.append(StudentInformation(student: studentDictionary))
                            }
                            completionHandler(success: true, error: nil)
                        }
                    }
                    else {
                        completionHandler(success: false, error: "Unable to retrieve student data. Please try again.")
                    }
                }
                catch {
                    completionHandler(success: false, error: "Unable to retrieve student data. Please try again.")
                }
            }
        }
        task.resume()
    }
    
    //Post Location - post udacity account user location
    
    func postStudentLocation(completionHandler: (success: Bool, error: String!)->Void) {
        appdelegate=UIApplication.sharedApplication().delegate as! AppDelegate
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(appdelegate.udacitykey)\", \"firstName\": \"\(appdelegate.firstName)\", \"lastName\": \"\(appdelegate.lastName)\",\"mapString\": \"\(appdelegate.mapString)\", \"mediaURL\": \"\(appdelegate.url)\",\"latitude\": \(appdelegate.geolat), \"longitude\": \(appdelegate.geolon)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, error: error!.localizedDescription)
            }
            else {
                do {
                    _ = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    completionHandler(success: true, error: nil)
                }
                catch {
                    completionHandler(success: false, error: "Unable to post student location.")
                }
            }
        }
        task.resume()
    }
}

//Student Information - store incoming student information for each student in this struct

struct StudentInformation {
    let firstName:String
    let lastName:String
    let lat:CLLocationDegrees
    let lon:CLLocationDegrees
    let url:String
    
    init(student: NSDictionary){
        firstName = student.valueForKey("firstName") as! String
        lastName = student.valueForKey("lastName") as! String
        lat = student.valueForKey("latitude") as! CLLocationDegrees
        lon = student.valueForKey("longitude") as! CLLocationDegrees
        url = student.valueForKey("mediaURL") as! String
    }
}