//
//  SettingsVC.swift
//  MoodyMood
//
//  Created by Amr Farouq on 1/11/17.
//  Copyright © 2017 Amr Farouq. All rights reserved.
//

import UIKit
import UserNotifications
class SettingsVC: UIViewController,UIPickerViewDataSource,UIPickerViewDelegate{

    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var PickerView: UIPickerView!
    let pickerData = ["1 Minute(for Test)","24 Hours","2 Days","5 Days","10 Days","20 Days","One Month"]
    override func viewDidLoad() {
        super.viewDidLoad()
        PickerView.dataSource = self
        PickerView.delegate = self
        let prefs:UserDefaults = UserDefaults.standard
        if let Interval = prefs.string(forKey: "NotInt"){
            myLabel.text = Interval
        }else{
            myLabel.text = "Interval"
        }
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        myLabel.text = pickerData[row]
        switch pickerData[row]{
        case "24 Hours":
            let prefs:UserDefaults = UserDefaults.standard
            prefs.set(86400.0, forKey: "NotInt")
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "MoodyMood!", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "Don't Forget To Set Your Mood!", arguments: nil)
            content.sound = UNNotificationSound.default()
            content.badge = UIApplication.shared.applicationIconBadgeNumber as NSNumber?
            content.categoryIdentifier = "com.codendot.MoodyMood"
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 86400.0, repeats: true)
            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
            print("Local Notification Is Set to: 24 Hours")
            break
        case "2 Days":
            let prefs:UserDefaults = UserDefaults.standard
            prefs.set(1728000.0, forKey: "NotInt")
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "MoodyMood!", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "Don't Forget To Set Your Mood!", arguments: nil)
            content.sound = UNNotificationSound.default()
            content.badge = UIApplication.shared.applicationIconBadgeNumber as NSNumber?
            content.categoryIdentifier = "com.codendot.MoodyMood"
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1728000.0, repeats: true)
            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
            print("Local Notification Is Set to: 2 Days")
            break
        case"5 Days":
            let prefs:UserDefaults = UserDefaults.standard
            prefs.set(432000.0, forKey: "NotInt")
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "MoodyMood!", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "Don't Forget To Set Your Mood!", arguments: nil)
            content.sound = UNNotificationSound.default()
            content.badge = UIApplication.shared.applicationIconBadgeNumber as NSNumber?
            content.categoryIdentifier = "com.codendot.MoodyMood"
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 432000.0, repeats: true)
            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
            print("Local Notification Is Set to: 5 Days")
            break
        case"10 Days":
            let prefs:UserDefaults = UserDefaults.standard
            prefs.set(864000.0, forKey: "NotInt")
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "MoodyMood!", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "Don't Forget To Set Your Mood!", arguments: nil)
            content.sound = UNNotificationSound.default()
            content.badge = UIApplication.shared.applicationIconBadgeNumber as NSNumber?
            content.categoryIdentifier = "com.codendot.MoodyMood"
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 864000.0, repeats: true)
            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
            print("Local Notification Is Set to: 10 Days")
            break
        case"20 Days":
            let prefs:UserDefaults = UserDefaults.standard
            prefs.set(1728000.0, forKey: "NotInt")
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "MoodyMood!", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "Don't Forget To Set Your Mood!", arguments: nil)
            content.sound = UNNotificationSound.default()
            content.badge = UIApplication.shared.applicationIconBadgeNumber as NSNumber?
            content.categoryIdentifier = "com.codendot.MoodyMood"
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1728000.0, repeats: true)
            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
            print("Local Notification Is Set to: 20 Days")
            break
        case"One Month":
            let prefs:UserDefaults = UserDefaults.standard
            prefs.set(2592000.0, forKey: "NotInt")
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "MoodyMood!", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "Don't Forget To Set Your Mood!", arguments: nil)
            content.sound = UNNotificationSound.default()
            content.badge = UIApplication.shared.applicationIconBadgeNumber as NSNumber?
            content.categoryIdentifier = "com.codendot.MoodyMood"
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 2592000.0, repeats: true)
            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
            print("Local Notification Is Set to: One Month")
            break
        case"1 Minute(for Test)":
            let prefs:UserDefaults = UserDefaults.standard
            prefs.set(60.0, forKey: "NotInt")
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "MoodyMood!", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "Don't Forget To Set Your Mood!", arguments: nil)
            content.sound = UNNotificationSound.default()
            content.badge = UIApplication.shared.applicationIconBadgeNumber as NSNumber?
            content.categoryIdentifier = "com.codendot.MoodyMood"
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 60.0, repeats: true)
            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
            print("Local Notification Is Set to: 1 Second")
            break
        default:
            let prefs:UserDefaults = UserDefaults.standard
            prefs.set(86400.0, forKey: "NotInt")
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "MoodyMood!", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "Don't Forget To Set Your Mood!", arguments: nil)
            content.sound = UNNotificationSound.default()
            content.badge = UIApplication.shared.applicationIconBadgeNumber as NSNumber?
            content.categoryIdentifier = "com.codendot.MoodyMood"
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 86400.0, repeats: true)
            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
            print("Local Notification Is Set to: 24 Hours")
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
