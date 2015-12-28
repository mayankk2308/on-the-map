import Foundation

class UdacityLogin: NSObject {
    
    //Login - Process login credentials
    
    func loginWithCredentials(username: String!, password: String!, completionHandler: (success: Bool, key: String!, error: String!)->Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if downloadError != nil {
                completionHandler(success: false, key: nil, error: downloadError!.localizedDescription)
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))//subset response data
            do { let parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                if let uniquekey=parsedResult.valueForKey("account")?.valueForKey("key") as? String {
                    completionHandler(success: true, key: uniquekey, error: nil)
                }
                else {
                    completionHandler(success: false, key: nil, error: "Incorrect username and password combination. Please try again.")
                }
            }
            catch {
                completionHandler(success: false, key: nil, error: "Unable to retrieve user information. Please try again.")
            }
        }
        task.resume()
    }
    
    //User Data - Obtain user data from Udacity API
    
    func getUserData(userid: String!, completionHandler: (success: Bool, firstName: String!, lastName: String!, error: String!)->Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(userid)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, firstName: nil, lastName: nil, error: error!.localizedDescription)
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))//subset response data
            do { let parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                if let firstName=parsedResult.valueForKey("user")?.valueForKey("first_name") as? String {
                    let lastName=parsedResult.valueForKey("user")?.valueForKey("last_name") as? String
                    completionHandler(success: true, firstName: firstName, lastName: lastName, error: nil)
                }
                else {
                    completionHandler(success: false, firstName: nil, lastName: nil, error: "Unable to retrieve user information. Please try again.")
                }
            }
            catch {
                completionHandler(success: false, firstName: nil, lastName: nil, error: "Unable to retrieve user information. Please try again.")
            }
        }
        task.resume()
    }
    
    //Log Out - Log out of Udacity account
    
        func logout(completionHandler: (success: Bool)->Void){
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
            request.HTTPMethod = "DELETE"
            var xsrfCookie: NSHTTPCookie? = nil
            let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
            }
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil {
                    completionHandler(success: false)
                    return
                }
                _ = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                    completionHandler(success: true)
            }
            task.resume()
        }
    }