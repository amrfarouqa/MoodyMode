//
//  HomeViewController.swift
//  MoodyMood
//
//  Created by Amr Farouq on 1/6/17.
//  Copyright © 2017 Amr Farouq. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKShareKit
import Firebase
import UserNotifications
import SystemConfiguration
class HomeViewController: UIViewController {
    
    func uploadMoodHistoryUserData(){
        let prefs:UserDefaults = UserDefaults.standard
        if let UserMood:String = prefs.string(forKey: "STATUS"){
            let UserName:NSString = (prefs.value(forKey: "USERNAME") as? NSString)!
            let UserProfile:NSString = (prefs.value(forKey: "USERPICTURE")as? NSString)!
            let UserMail:NSString = (prefs.value(forKey: "EMAIL")as? NSString)!
            let UserID:NSString = (prefs.value(forKey: "ID") as? NSString)!
            //print("Username:", UserName, "User Profile:", UserProfile, "User Mail", UserMail, "UserID: ", UserID)
            do {
                
                let post:NSString = "email=\(UserMail)&mood=\(UserMood)&ID=\(UserID)&name=\(UserName)&profileimage=\(UserProfile)" as NSString
                
                NSLog("PostData: %@",post);
                
                let url:URL = URL(string:"http://138.201.61.97/~moodymood/php/set_mood_history.php")!
                
                let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
                
                let postLength:NSString = String( postData.count ) as NSString
                
                let request:NSMutableURLRequest = NSMutableURLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = postData
                request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                
                var reponseError: NSError?
                var response: URLResponse?
                
                var urlData: Data?
                do {
                    
                    urlData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning:&response)
                } catch let error as NSError {
                    reponseError = error
                    urlData = nil
                    print(error)
                }
                
                if ( urlData != nil ) {
                    let res = response as! HTTPURLResponse!;
                    if ((res?.statusCode)! >= 200 && (res?.statusCode)! < 300)
                    {
                        let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                        
                        NSLog("Response ==> %@", responseData);
                        
                        //var error: NSError?
                        
                        let jsonData:NSDictionary = try JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers ) as! NSDictionary
                        
                        
                        let success:NSInteger = jsonData.value(forKey: "success") as! NSInteger
                        
                        //[jsonData[@"success"] integerValue];
                        
                        NSLog("Success: %ld", success);
                        
                        if(success == 1)
                        {
                            NSLog("HomeViewController Mood History Updated successfully");
                        } else {
                            var error_msg:NSString
                            
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! NSString
                            } else {
                                error_msg = "HomeViewController Invalid Email!"
                            }
                            print(error_msg)
                            
                        }
                    } else {
                        print("Connection Failed")
                    }
                } else {
                    print("Error In Updating History")
                }
            } catch let error as NSError{
                print("Couldn't Connect To Server")
                print("Error", error)
            }
            
        }else{
            print("Mood not selected!!")
        }
    }

    @IBAction func ShareMyMoodBtn(_ sender: AnyObject) {
        if(connectedToNetwork()){
            // Assemble Content
            let prefs:UserDefaults = UserDefaults.standard
            if let mood:String = prefs.string(forKey: "STATUS"){
                let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
                content.contentURL =  Foundation.URL(string: "http://codendot.com/")
                content.contentTitle = "Sharing My Mood With You!"
                content.contentDescription = "I Feel : ".appending(mood)
                switch mood {
                case "veryhappy":
                    content.imageURL = Foundation.URL(string: "http://138.201.61.97/~moodymood/img/veryhappy.png")
                    break
                case "happy" :
                    content.imageURL = Foundation.URL(string: "http://138.201.61.97/~moodymood/img/happy.png")
                    break
                case "normal" :
                    content.imageURL = Foundation.URL(string: "http://138.201.61.97/~moodymood/img/normal.png")
                    break
                case "sad" :
                    content.imageURL = Foundation.URL(string: "http://138.201.61.97/~moodymood/img/sad.png")
                    break
                case "verysad" :
                    content.imageURL = Foundation.URL(string: "http://138.201.61.97/~moodymood/img/verysad.png")
                    break
                case "depressed" :
                    content.imageURL = Foundation.URL(string: "http://138.201.61.97/~moodymood/img/depressed.png")
                    break
                default :
                    content.imageURL = Foundation.URL(string: "http://138.201.61.97/~moodymood/img/statuss.png")
                    break
                }
                let ShareDialog: FBSDKShareDialog = FBSDKShareDialog()
                ShareDialog.mode = FBSDKShareDialogMode.automatic
                ShareDialog.shareContent = content
                if (ShareDialog.canShow()){
                    ShareDialog.show()
                }else{
                    let alert = UIAlertController(title: "Ooops!", message:"Facebook Error!", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in})
                    self.present(alert, animated: true){};
                }
                print("HomeViewController Handle Facebook Share")
            }else{
                let alert = UIAlertController(title: "Ooops!!", message:"You Didn't Set Your Mode!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                    print("HomeViewController Error Facebook Share")
                })
                self.present(alert, animated: true){};
            }
        }else{
            let alert = UIAlertController(title: "Ooops!!", message:"Connection Error!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in})
            self.present(alert, animated: true){};
        }
    }
    
    func saveFriends(){
        FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "id, first_name, last_name, middle_name, name, email, picture"]).start { (connection, result, err) in
            
            if err != nil {
                print("HomeViewController Failed to start graph request:", err ?? "")
                return
            }
            let data:[String:AnyObject] = result as! [String : AnyObject]
            let prefs:UserDefaults = UserDefaults.standard
            prefs.set(data, forKey: "FriendsData")
            prefs.synchronize()
            print("HomeViewController Friends Updated", data)
            
        }
    }
    
    
    @IBOutlet weak var labelName: UILabel!
        @IBAction func updateStatusBtn(_ sender: AnyObject) {
            if(connectedToNetwork()){
                let LoadingAlert = UIAlertController(title: "MoodyMood!", message: "Please wait...", preferredStyle: .alert)
                
                LoadingAlert.view.tintColor = UIColor.black
                let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50,height: 50)) as UIActivityIndicatorView
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
                loadingIndicator.startAnimating();
                
                LoadingAlert.view.addSubview(loadingIndicator)
                present(LoadingAlert, animated: true, completion: nil)
                uploadMoodHistoryUserData()
                let prefs:UserDefaults = UserDefaults.standard
                
                if let userStatus:String = prefs.string(forKey: "STATUS") {
                    
                    let email:NSString = (prefs.value(forKey: "EMAIL") as? NSString)!
                    let mood:NSString = userStatus as NSString
                    let ID:NSString = (prefs.value(forKey: "ID") as? NSString)!
                    
                    do {
                        print("Test")
                        var SortID:NSString = ""
                        switch mood {
                        case "veryhappy":
                            SortID = "1"
                            break
                        case "happy" :
                            SortID = "2"
                            break
                        case "normal" :
                            SortID = "3"
                            break
                        case "sad" :
                            SortID = "4"
                            break
                        case "verysad" :
                            SortID = "5"
                            break
                        case "depressed" :
                            SortID = "6"
                            break
                        default :
                            break
                        }
                        
                        let post:NSString = "email=\(email)&mood=\(mood)&ID=\(ID)&sortid\(SortID)" as NSString
                        
                        NSLog("PostData: %@",post);
                        
                        let url:URL = URL(string:"http://138.201.61.97/~moodymood/php/setusermood.php")!
                        
                        let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
                        
                        let postLength:NSString = String( postData.count ) as NSString
                        
                        let request:NSMutableURLRequest = NSMutableURLRequest(url: url)
                        request.httpMethod = "POST"
                        request.httpBody = postData
                        request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                        request.setValue("application/json", forHTTPHeaderField: "Accept")
                        
                        
                        var reponseError: NSError?
                        var response: URLResponse?
                        
                        var urlData: Data?
                        do {
                            
                            urlData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning:&response)
                        } catch let error as NSError {
                            reponseError = error
                            urlData = nil
                        }
                        
                        if ( urlData != nil ) {
                            let res = response as! HTTPURLResponse!;
                            
                            if ((res?.statusCode)! >= 200 && (res?.statusCode)! < 300)
                            {
                                let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                                
                                NSLog("Response ==> %@", responseData);
                                
                                //var error: NSError?
                                
                                let jsonData:NSDictionary = try JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers ) as! NSDictionary
                                
                                
                                let success:NSInteger = jsonData.value(forKey: "success") as! NSInteger
                                
                                //[jsonData[@"success"] integerValue];
                                
                                NSLog("Success: %ld", success);
                                
                                if(success == 1)
                                {
                                    NSLog("HomeViewController Mood Added successfully");
                                    LoadingAlert.dismiss(animated: true, completion: { () -> Void in
                                        let alerts = UIAlertController(title: "Mood", message:"Your Mood Now Is: ".appending(mood as String).appending(". Would You Like To Share It On Facebook?"), preferredStyle: .alert)
                                        alerts.addAction(UIAlertAction(title: "YES", style: .default) { _ in
                                            // Assemble Content
                                            let prefs:UserDefaults = UserDefaults.standard
                                            if let mood:String = prefs.string(forKey: "STATUS"){
                                                let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
                                                content.contentURL =  Foundation.URL(string: "http://codendot.com/")
                                                content.contentTitle = "Sharing My Mood With You!"
                                                content.contentDescription = "I Feel : ".appending(mood)
                                                switch mood {
                                                case "veryhappy":
                                                    content.imageURL = Foundation.URL(string: "http://138.201.61.97/~moodymood/img/veryhappy.png")
                                                    break
                                                case "happy" :
                                                    content.imageURL = Foundation.URL(string: "http://138.201.61.97/~moodymood/img/happy.png")
                                                    break
                                                case "normal" :
                                                    content.imageURL = Foundation.URL(string: "http://138.201.61.97/~moodymood/img/normal.png")
                                                    break
                                                case "sad" :
                                                    content.imageURL = Foundation.URL(string: "http://138.201.61.97/~moodymood/img/sad.png")
                                                    break
                                                case "verysad" :
                                                    content.imageURL = Foundation.URL(string: "http://138.201.61.97/~moodymood/img/verysad.png")
                                                    break
                                                case "depressed" :
                                                    content.imageURL = Foundation.URL(string: "http://138.201.61.97/~moodymood/img/depressed.png")
                                                    break
                                                default :
                                                    content.imageURL = Foundation.URL(string: "http://138.201.61.97/~moodymood/img/statuss.png")
                                                    break
                                                }
                                                let ShareDialog: FBSDKShareDialog = FBSDKShareDialog()
                                                ShareDialog.mode = FBSDKShareDialogMode.automatic
                                                ShareDialog.shareContent = content
                                                if (ShareDialog.canShow()){
                                                    ShareDialog.show()
                                                }else{
                                                    let alert = UIAlertController(title: "Ooops!", message:"Facebook Error!", preferredStyle: .alert)
                                                    
                                                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in})
                                                    self.present(alert, animated: true){};
                                                }
                                                print("HomeViewController Handle Facebook Share")
                                            }else{
                                                let alert = UIAlertController(title: "Ooops!!", message:"You Didn't Set Your Mode!", preferredStyle: .alert)
                                                
                                                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                                                    print("HomeViewController Error Facebook Share")
                                                })
                                                self.present(alert, animated: true){};
                                            }
                                        })
                                        alerts.addAction(UIAlertAction(title: "NO", style: .default) { _ in})
                                        
                                        self.present(alerts, animated: true){};
                                    })
                                } else {
                                    var error_msg:NSString
                                    
                                    if jsonData["error_message"] as? NSString != nil {
                                        error_msg = jsonData["error_message"] as! NSString
                                    } else {
                                        error_msg = "HomeViewController Invalid Email!"
                                    }
                                    LoadingAlert.dismiss(animated: true, completion: { () -> Void in
                                        let alert = UIAlertController(title: "Oops!", message:"Invalid Email!", preferredStyle: .alert)
                                        print(error_msg)
                                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                                        
                                        self.present(alert, animated: true){};
                                    })
                                }
                            } else {
                                LoadingAlert.dismiss(animated: true, completion: { () -> Void in
                                    let alert = UIAlertController(title: "Oops!", message:"Connection Failed!", preferredStyle: .alert)
                                    print("HomeViewController Status Code Error", res?.statusCode as Any)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                                    
                                    self.present(alert, animated: true){};
                                })
                            }
                        } else {
                            LoadingAlert.dismiss(animated: true, completion: { () -> Void in
                                let error = reponseError
                                let alert = UIAlertController(title: "Oops!", message:error?.localizedDescription, preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                                self.present(alert, animated: true){};
                            })
                        }
                    } catch {
                        LoadingAlert.dismiss(animated: true, completion: { () -> Void in
                            let alert = UIAlertController(title: "Oops!", message:"Server Error, Couldn't Connect To Server!", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                            
                            self.present(alert, animated: true){};
                        })
                    }
                    
                }else{
                    LoadingAlert.dismiss(animated: true, completion: { () -> Void in
                        let alert = UIAlertController(title: "Oops!", message:"You didn't Set Your Mood Yet!", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                        self.present(alert, animated: true){};
                        
                    })
                }
            }else{
                let alert = UIAlertController(title: "Oops!", message:"Connection Failed!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                self.present(alert, animated: true){};
            }
            
    }
    @IBOutlet weak var statusImage: UIImageView!
    @IBAction func depressedBtn(_ sender: AnyObject) {
        statusImage.image = UIImage(named: "depressed")
        let prefs:UserDefaults = UserDefaults.standard
        prefs.set("depressed", forKey: "STATUS")
        prefs.synchronize()
        print("HomeViewController Mood Set to: depressed")
        
    }
    @IBAction func verySadBtn(_ sender: AnyObject) {
        statusImage.image = UIImage(named: "verysad")
        let prefs:UserDefaults = UserDefaults.standard
        prefs.set("verysad", forKey: "STATUS")
        prefs.synchronize()
        print("HomeViewController Mood Set to: verysad")
    }
    @IBAction func sadBtn(_ sender: AnyObject) {
        statusImage.image = UIImage(named: "sad")
        let prefs:UserDefaults = UserDefaults.standard
        prefs.set("sad", forKey: "STATUS")
        prefs.synchronize()
        print("HomeViewController Mood Set to: sad")
    }
    @IBAction func normalBtn(_ sender: AnyObject) {
        statusImage.image = UIImage(named: "normal")
        let prefs:UserDefaults = UserDefaults.standard
        prefs.set("normal", forKey: "STATUS")
        prefs.synchronize()
        print("HomeViewController Mood Set to: normal")
    }
    @IBAction func happyBtn(_ sender: AnyObject) {
        statusImage.image = UIImage(named: "happy")
        let prefs:UserDefaults = UserDefaults.standard
        prefs.set("happy", forKey: "STATUS")
        prefs.synchronize()
        print("HomeViewController Mood Set to: happy")
    }
    @IBAction func veryHappyBtn(_ sender: AnyObject) {
        statusImage.image = UIImage(named: "veryhappy")
        let prefs:UserDefaults = UserDefaults.standard
        prefs.set("veryhappy", forKey: "STATUS")
        prefs.synchronize()
        print("HomeViewController Mood Set to: veryhappy")
    }
    @IBOutlet weak var NavBar: UINavigationBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        if(connectedToNetwork()){
            self.loadUser()
            self.saveFriends()
            self.setupNavBar()
            self.loadStatus()
            self.refresh()
            self.setLocalNot()
        }else{
            let alert = UIAlertController(title: "Oops!", message:"Connection Failed!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
            self.present(alert, animated: true){};
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        let prefs:UserDefaults = UserDefaults.standard
        let ReloadStatus:Bool = prefs.bool(forKey: "RELOADSTATUS")
        if(ReloadStatus){
            print("Homeviewcontroller already reloaded")
        }else{
            reloadData()
        }
    }
    func reloadData(){
        if (connectedToNetwork()){
            let LoadingAlert = UIAlertController(title: "MoodyMood!", message: "Please wait...", preferredStyle: .alert)
            
            LoadingAlert.view.tintColor = UIColor.black
            let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50,height: 50)) as UIActivityIndicatorView
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            LoadingAlert.view.addSubview(loadingIndicator)
            present(LoadingAlert, animated: true, completion: nil)
            self.loadUser()
            self.saveFriends()
            self.setupNavBar()
            self.loadStatus()
            self.refresh()
            self.setLocalNot()
            let prefs:UserDefaults = UserDefaults.standard
            prefs.setValue(true, forKey: "RELOADSTATUS")
            LoadingAlert.dismiss(animated: true, completion: { () -> Void in
                print("HomeViewController Loaded With Refresh")
            })
        }else{
            let alert = UIAlertController(title: "Oops!", message:"Connection Failed!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
            self.present(alert, animated: true){};
        }
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    func setLocalNot(){
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "MoodyMood!", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "Don't Forget To Set Your Mood!", arguments: nil)
        content.sound = UNNotificationSound.default()
        content.badge = UIApplication.shared.applicationIconBadgeNumber as NSNumber?
        content.categoryIdentifier = "com.codendot.MoodyMood"
        
        let prefs:UserDefaults = UserDefaults.standard
        
        if let NotificationInterval:String = prefs.string(forKey: "NotInt"){
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: Double(NotificationInterval)!, repeats: true)
            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
            print("Local Notification Updated Is Set to: ", NotificationInterval)
        }else{
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 86400.0, repeats: true)
            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
            print("Local Notification Is Set to: 24 Hours")
        }
    }
    func sendPushNot(){
        let prefs:UserDefaults = UserDefaults.standard
        if let deviceToken:String = prefs.string(forKey: "DeviceToken"){
            do {
                let post:NSString = "token=\(deviceToken)" as NSString
                
                NSLog("PostData: %@",post);
                
                let url:URL = URL(string:"http://138.201.61.97/~moodymood/php/MoodyMoodPush.php")!
                
                let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
                
                let postLength:NSString = String( postData.count ) as NSString
                
                let request:NSMutableURLRequest = NSMutableURLRequest(url: url)
                request.httpMethod = "POST"
                request.httpBody = postData
                request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                
                
                var reponseError: NSError?
                var response: URLResponse?
                
                var urlData: Data?
                do {
                    urlData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning:&response)
                } catch let error as NSError {
                    reponseError = error
                    urlData = nil
                }
                
                if ( urlData != nil ) {
                    let res = response as! HTTPURLResponse!;
                    
                    if ((res?.statusCode)! >= 200 && (res?.statusCode)! < 300)
                    {
                        let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                        
                        NSLog("Response ==> %@", responseData);
                        
                        //var error: NSError?
                        
                        let jsonData:NSDictionary = try JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers ) as! NSDictionary
                        
                        
                        let success:NSInteger = jsonData.value(forKey: "success") as! NSInteger
                        
                        //[jsonData[@"success"] integerValue];
                        
                        NSLog("Success: %ld", success);
                        
                        if(success == 1)
                        {
                            NSLog("HomeViewController Notification Sent");
                            
                            let alert = UIAlertController(title: "Mood", message:"Notification Sent", preferredStyle: .alert)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in})
                            self.present(alert, animated: true){};
                        } else {
                            var error_msg:NSString
                            
                            if jsonData["error_message"] as? NSString != nil {
                                error_msg = jsonData["error_message"] as! NSString
                            } else {
                                error_msg = "HomeViewController Invalid Email!"
                            }
                            let alert = UIAlertController(title: "Oops!", message:"Invalid Email!", preferredStyle: .alert)
                            print(error_msg)
                            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                            self.present(alert, animated: true){};
                        }
                    } else {
                        let alert = UIAlertController(title: "Oops!", message:"Connection Failed!", preferredStyle: .alert)
                        print("HomeViewController Status Code Error", res?.statusCode as Any)
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                        self.present(alert, animated: true){};
                    }
                } else {
                    let error = reponseError
                    let alert = UIAlertController(title: "Oops!", message:error?.localizedDescription, preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                    self.present(alert, animated: true){};
                    
                }
            } catch {
                let alert = UIAlertController(title: "Oops!", message:"Server Error, Couldn't Connect To Server!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
                self.present(alert, animated: true){};
            }
            print("Device Token Available: ", deviceToken)
        }else{
            print("Device Token is Not Available")
        }
    }
    
    func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
    func loadUser(){
        let prefs:UserDefaults = UserDefaults.standard
        
        if let UserNameTxt:String = prefs.string(forKey: "USERNAME"){
            self.labelName.text = UserNameTxt
            print("HomeViewController Username Updated", UserNameTxt)
        }
    }
    func loadStatus(){
        let prefs:UserDefaults = UserDefaults.standard
        
        if let userStatus:String = prefs.string(forKey: "STATUS") {
            statusImage.image = UIImage(named: userStatus)
            print("HomeViewController Status Updated", userStatus)
        }
    }
    func setupNavBar(){
        let title = UIBarButtonItem(title: "MoodyMood", style: .plain, target: self, action: #selector(handleMore))
        
        let logo = UIBarButtonItem(image: UIImage(named: "icon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMore))
        
        let msgz = UIBarButtonItem(image: UIImage(named: "chat")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMessage))
        
        let refreshbtn = UIBarButtonItem(image: UIImage(named: "refresh")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(refresh))
        
        let logout = UIBarButtonItem(image: UIImage(named: "logout")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogout))
        
        let navItem = UINavigationItem(title: "")
        navItem.leftBarButtonItems = [logo, title]
        navItem.rightBarButtonItems = [logout, msgz, refreshbtn]
        NavBar.setItems([navItem], animated: false)
        print("HomeViewController NavBar Updated")
    }
    func handleMore(){
        print("HomeViewController Handlemore clicked")
    }
    func handleMessage(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = UINavigationController(rootViewController: MessagesController())
        appDelegate.window!.makeKeyAndVisible()
        print("HomeViewController Handle MESSAGE CLICKED")
    }
    func handleLogout(){
        let alert = UIAlertController(title: "Logout", message:"Are You Sure You Want To Logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("HomeViewController Logout Canceled")
        }))
        
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            UserDefaults.standard.set(false, forKey: "ISLOGGEDIN")
            let manager = FBSDKLoginManager()
            manager.logOut()
            do {
                try FIRAuth.auth()?.signOut()
                print("HomeViewController the user is logged out")
            } catch let error as NSError {
                print(error.localizedDescription)
                print("HomeViewController the current user id is \(FIRAuth.auth()?.currentUser?.uid)")
            }
            let LoginVC = self.storyboard!.instantiateViewController(withIdentifier: "LoginVC")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window!.rootViewController = LoginVC
            appDelegate.window!.makeKeyAndVisible()
            let prefs:UserDefaults = UserDefaults.standard
            prefs.set("", forKey: "EMAIL")
            prefs.set("", forKey: "ID")
            prefs.set("", forKey: "USERNAME")
            prefs.set("", forKey: "USERPICTURE")
            prefs.set(false, forKey: "ISLOGGEDIN")
            prefs.synchronize()
            print("HomeViewController Handle LOGOUT CLICKED")
            })
        self.present(alert, animated: true){};
        
    }
    
    func refresh(){
        loadUser()
        saveFriends()
        loadStatus()
        setLocalNot()
        print("HomeViewController refresh is done")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
