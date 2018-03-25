//
//  InviteVC.swift
//  MoodyMood
//
//  Created by Amr Farouq on 1/13/17.
//  Copyright © 2017 Amr Farouq. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class InviteVC: UIViewController, FBSDKAppInviteDialogDelegate {
    @IBAction func ShareAppBtn(_ sender: Any) {
        let content = FBSDKAppInviteContent()
        content.appLinkURL = URL(string: "https://fb.me/237440423332144")
        content.appInvitePreviewImageURL = URL(string: "http://138.201.61.97/~moodymood/img/proticonsmall.png")
        FBSDKAppInviteDialog.show(from: self, with: content, delegate: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        let alert = UIAlertController(title: "MoodyMood!", message:"Facebook Error", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in})
        self.present(alert, animated: true){};
        
    }
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        let alert = UIAlertController(title: "MoodyMood!", message:"Facebook Invite Succeeded", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in})
        self.present(alert, animated: true){};
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

