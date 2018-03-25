//
//  HomeVC.swift
//  MoodyMood
//
//  Created by Amr Farouq on 1/6/17.
//  Copyright © 2017 Amr Farouq. All rights reserved.
//

import UIKit

class HomeVC: UITabBarController {
    
    /*@IBOutlet weak var usernameLbl: UILabel!
     @IBAction func btnLogout(_ sender: AnyObject) {
     UserDefaults.standard.set(false, forKey: "ISLOGGEDIN")
     let manager = FBSDKLoginManager()
     manager.logOut()
     }*/
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Tab Bar Controller HOMEVC is loaded")
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
