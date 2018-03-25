//
//  ViewController.swift
//  MoodyMood
//
//  Created by Amr Farouq on 1/6/17.
//  Copyright © 2017 Amr Farouq. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
class LoginVC: UIViewController, FBSDKLoginButtonDelegate {
    var messagesController: MessagesController?
    override func viewDidLoad() {
        super.viewDidLoad()
        addLoginBtn()
        print("Login VC ViewDidload Fininshed")
    }
    @IBOutlet weak var profileImageOutlet: UIImageView!
    func addLoginBtn(){
        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        //frame's are obselete, please use constraints instead because its 2016 after all
        loginButton.frame = CGRect(x: 16, y: 400, width: view.frame.width - 32, height: 50)
        
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile", "user_friends"]
         print("Login VC Login FB Button added")
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if ((error) != nil) {
            print("Facebook Login Erro: ", error)
            return
        }
        else if result.isCancelled {
            // Handle cancellations
            print("Facebook Result Canceled")
        }
        else {
            print("Facebook Login Success")
            self.showEmailAddress()
            self.saveFriends()
        }
        
    }
    func openHomeScene(){
        let Saved = self.storyboard!.instantiateViewController(withIdentifier: "HomeVC")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = Saved
        appDelegate.window!.makeKeyAndVisible()
        print("LoginVC OpenHomeScene Clicked")
    }
    func showEmailAddress() {
        let LoadingAlert = UIAlertController(title: "MoodyMood!", message: "Please wait...", preferredStyle: .alert)
        
        LoadingAlert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50,height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        LoadingAlert.view.addSubview(loadingIndicator)
        self.present(LoadingAlert, animated: true, completion: nil)
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email, picture"]).start { (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph request:", err ?? "")
                return
            }
            
            let data:[String:AnyObject] = result as! [String : AnyObject]
            
            print("resultnew :" , data)
            
            let email = data["email"] as? String
            let name = data["name"] as? String
            let id = data["id"] as? String
            let picture = data["picture"] as? NSDictionary
            let dataa = picture?["data"] as? NSDictionary
            let url = dataa?["url"] as? String
            let prefs:UserDefaults = UserDefaults.standard
            prefs.set(email!, forKey: "EMAIL")
            prefs.set(id!, forKey: "ID")
            prefs.set(name!, forKey: "USERNAME")
            prefs.set(url!, forKey: "USERPICTURE")
            prefs.set(true, forKey: "ISLOGGEDIN")
            prefs.synchronize()
            self.profileImageOutlet.loadImageUsingUrlString(url!)
            
            self.checkIfEmailExists(emailA: email!, passwordA: id!)
            LoadingAlert.dismiss(animated: true, completion: { () -> Void in
                print("HomeViewController Loaded With Refresh")
                self.openHomeScene()
            })
            print("Load FaceBook User Data Success")
        }
    }
    
    func checkIfEmailExists(emailA: String, passwordA: String) {
        
        self.handleRegister()
        FIRAuth.auth()?.signIn(withEmail: emailA, password: passwordA, completion: { (user, error) in
            
            if error != nil {
                print("Firebase Login Error", error!)
                
                return
            }
            
            print("LoginVC successfully logged in our firebase user")
            
            self.messagesController?.fetchUserAndSetupNavBarTitle()
            
        })
        
        self.handleRegister()
        FIRAuth.auth()?.signIn(withEmail: emailA, password: passwordA, completion: { (user, error) in
            
            if error != nil {
                print(error!)
                print("Firebase Login Error", error!)
                return
            }
            
            print("successfully logged in our firebase user")
            
            self.messagesController?.fetchUserAndSetupNavBarTitle()
            
        })

        
        
    }
    
    func saveFriends(){
        FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "id, first_name, last_name, middle_name, name, email, picture"]).start { (connection, result, err) in
            
            if err != nil {
                print("LoginVC Failed to start graph request:", err ?? "")
                return
            }
            let data:[String:AnyObject] = result as! [String : AnyObject]
            //print(data)
            let prefs:UserDefaults = UserDefaults.standard
            prefs.set(data, forKey: "FriendsData")
            prefs.synchronize()
            print("LoginVC User Friends Saved Successfully")
        }
    }
    
    func taggableFriends(){
        FBSDKGraphRequest(graphPath: "/me/taggable_friends", parameters: ["fields": "id, first_name, last_name, middle_name, name, email, picture"]).start { (connection, result, err) in
            
            if err != nil {
                print("Failed to start graph request:", err ?? "")
                return
            }
            //let data:[String:AnyObject] = result as! [String : AnyObject]
           // print(data)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleRegister() {
        let prefs:UserDefaults = UserDefaults.standard
        let email:String = prefs.string(forKey: "EMAIL")!
        let password:String = prefs.string(forKey: "ID")!
        let name:String = prefs.string(forKey: "USERNAME")!
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
            
            if error != nil {
                print("FireBase Registration Errorr", error!)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
          
            //successfully authenticated user
            let imageName = UUID().uuidString
          
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(imageName).jpg")
          
            
            if let profileImage = self.profileImageOutlet.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {

                storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                    
                    if error != nil {
                        print("FireBase User Image Upload Errorr", error!)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        
                        print("User Profile Image URL: ", profileImageUrl)
                        
                        let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl]
                        
                        self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
                    }
                })
            }
        })
    }
    
    func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = FIRDatabase.database().reference()
        print(ref)
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print("Login VC FireBase UpdateChild Value Error", err!)
                return
            }
            
            //            self.messagesController?.fetchUserAndSetupNavBarTitle()
            //            self.messagesController?.navigationItem.title = values["name"] as? String
            let user = User()
            //this setter potentially crashes if keys don't match
            user.setValuesForKeys(values)
            print("LoginVC Values Of Firebase User", values)
            self.messagesController?.setupNavBarWithUser(user)
        })
    }

}

