import Foundation

class UdacityLogin: NSObject {
    
    //Login - Process login credentials
    
    func loginWithCredentials(_ username: String!, password: String!, completionHandler: @escaping (_ success: Bool, _ key: String?, _ error: String?)->Void){
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, downloadError in
            if downloadError != nil {
                completionHandler(false, nil, downloadError!.localizedDescription)
                return
            }
            let newData = data!.subdata(in: 5 ..< data!.count - 5)//subset response data
            do { let parsedResult = try JSONSerialization.jsonObject(with: newData, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                if let uniquekey=(parsedResult.value(forKey: "account") as AnyObject).value(forKey: "key") as? String {
                    completionHandler(true, uniquekey, nil)
                }
                else {
                    completionHandler(false, nil, "Incorrect username and password combination. Please try again.")
                }
            }
            catch {
                completionHandler(false, nil, "Unable to retrieve user information. Please try again.")
            }
        }
        task.resume()
    }
    
    //User Data - Obtain user data from Udacity API
    
    func getUserData(_ userid: String!, completionHandler: @escaping (_ success: Bool, _ firstName: String?, _ lastName: String?, _ error: String?)->Void) {
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(userid)")!)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completionHandler(false, nil, nil, error!.localizedDescription)
                return
            }
            let newData = data!.subdata(in: 5 ..< data!.count - 5)//subset response data
            do { let parsedResult = try JSONSerialization.jsonObject(with: newData, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                if let firstName=(parsedResult.value(forKey: "user") as AnyObject).value(forKey: "first_name") as? String {
                    let lastName=(parsedResult.value(forKey: "user") as AnyObject).value(forKey: "last_name") as? String
                    completionHandler(true, firstName, lastName, nil)
                }
                else {
                    completionHandler(false, nil, nil, "Unable to retrieve user information. Please try again.")
                }
            }
            catch {
                completionHandler(false, nil, nil, "Unable to retrieve user information. Please try again.")
            }
        }
        task.resume()
    }
    
    //Log Out - Log out of Udacity account
    
        func logout(_ completionHandler: @escaping (_ success: Bool)->Void){
            let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
            request.httpMethod = "DELETE"
            var xsrfCookie: HTTPCookie? = nil
            let sharedCookieStorage = HTTPCookieStorage.shared
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
            }
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                if error != nil {
                    completionHandler(false)
                    return
                }
                _ = data!.subdata(in: 5 ..< data!.count - 5)
                    completionHandler(true)
            }
            task.resume()
        }
    }
