import Foundation
import MapKit

class StudentLocation: NSObject {
    
    var appdelegate: AppDelegate!
    
    //Get Student Data - Obtain student data
    
    func getStudentData(_ completionHandler: @escaping (_ success: Bool, _ error: String?)->Void){
        appdelegate=UIApplication.shared.delegate as! AppDelegate
        let request = NSMutableURLRequest(url: URL(string: "https://api.parse.com/1/classes/StudentLocation?limit=300")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completionHandler(false, error!.localizedDescription)
            }
            else {
                do {
                    let parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    if let students=parsedResult.value(forKey: "results") as? NSArray {
                        DispatchQueue.main.async{
                            for student in students {
                                let studentDictionary=student as! NSDictionary
                                self.appdelegate.studentInfo.append(StudentInformation(student: studentDictionary))
                            }
                            completionHandler(true, nil)
                        }
                    }
                    else {
                        completionHandler(false, "Unable to retrieve student data. Please try again.")
                    }
                }
                catch {
                    completionHandler(false, "Unable to retrieve student data. Please try again.")
                }
            }
        }
        task.resume()
    }
    
    //Post Location - post udacity account user location
    
    func postStudentLocation(_ completionHandler: @escaping (_ success: Bool, _ error: String?)->Void) {
        appdelegate=UIApplication.shared.delegate as! AppDelegate
        let request = NSMutableURLRequest(url: URL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"uniqueKey\": \"\(appdelegate.udacitykey)\", \"firstName\": \"\(appdelegate.firstName)\", \"lastName\": \"\(appdelegate.lastName)\",\"mapString\": \"\(appdelegate.mapString)\", \"mediaURL\": \"\(appdelegate.url)\",\"latitude\": \(appdelegate.geolat), \"longitude\": \(appdelegate.geolon)}".data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completionHandler(false, error!.localizedDescription)
            }
            else {
                do {
                    _ = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                    completionHandler(true, nil)
                }
                catch {
                    completionHandler(false, "Unable to post student location.")
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
        firstName = student.value(forKey: "firstName") as! String
        lastName = student.value(forKey: "lastName") as! String
        lat = student.value(forKey: "latitude") as! CLLocationDegrees
        lon = student.value(forKey: "longitude") as! CLLocationDegrees
        url = student.value(forKey: "mediaURL") as! String
    }
}
