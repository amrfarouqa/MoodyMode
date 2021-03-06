//
//  ViewController.swift
//  facebookfeed2
//
//  Created by Brian Voong on 2/20/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKShareKit
import Firebase
import SystemConfiguration

class HistoryPost: SafeJsonObject {
    var name: String?
    var profileImageName: String?
    var statusText: String?
    var statusImageName: String?
    var numLikes: String?
    var numComments: String?
    
    override func setValue(_ value: Any?, forKey key: String) {
        super.setValue(value, forKey: key)
    }
    
    
}


class HistoryFeed: SafeJsonObject {
    var feedUrl, title, link, author, type: String?
}

class HistoryFeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var posts = [HistoryPost]()
    var refresher:UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresher = UIRefreshControl()
        self.refresher.attributedTitle = NSAttributedString(string: "Pull to Refresh")
        self.refresher.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        self.collectionView!.alwaysBounceVertical = true
        collectionView!.addSubview(refresher)
        
        
        collectionView?.contentInset = UIEdgeInsetsMake(45, 0, 50, 0)
        
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        
        collectionView?.register(HistoryFeedCell.self, forCellWithReuseIdentifier: cellId)
        
        if(connectedToNetwork()){
            let LoadingAlert = UIAlertController(title: "MoodyMood!", message: "Please wait...", preferredStyle: .alert)
            
            LoadingAlert.view.tintColor = UIColor.black
            let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50,height: 50)) as UIActivityIndicatorView
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            LoadingAlert.view.addSubview(loadingIndicator)
            present(LoadingAlert, animated: true, completion: nil)
            posts.removeAll()
            refresh()
            LoadingAlert.dismiss(animated: true, completion: { () -> Void in
                print("HISTORY Loaded With Refresh")
            })
        }else{
            let alert = UIAlertController(title: "Ooops!!", message:"Connection Error!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in})
            self.present(alert, animated: true){};
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
    
    func LoadFriends(){
        let url = URL(string: "http://138.201.61.97/~moodymood/php/get_moods_history.php")
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                print("FriendsCVC Error Loading Url",url as Any, "with error", error!)
                return
            }
            
            do {
                
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String:Any]
                
                if let postsArray = json["moods"] as? [[String: String]] {
                    for value in postsArray {
                        let post = HistoryPost()
                        post.setValue(value["name"], forKey: "name")
                        post.setValue(value["img"], forKey: "statusImageName")
                        post.setValue(value["mood"], forKey: "statusText")
                        post.setValue(value["sortid"], forKey: "numLikes")
                        post.setValue(value["time"], forKey: "numComments")
                        post.setValue(value["ID"], forKey: "profileImageName")
                        self.posts.append(post)
                    }
                    self.posts.sort { Int($0.numLikes!)! < Int($1.numLikes!)!}
                    print("FriendsCVC Loaded From Server")
                    self.collectionView?.reloadData()
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.collectionView?.reloadData()
                    })
                    
                }
                
                DispatchQueue.main.async(execute: { () -> Void in
                    self.collectionView?.reloadData()
                })
                
            } catch let jsonError {
                print("FriendsCVC json error", jsonError)
            }
            
            
            
            }.resume()
    }
    
    func refresh()
    {
        if(connectedToNetwork()){
            self.posts.removeAll()
            setupNavBarButtons()
            saveFriends()
            LoadFriends()
            self.collectionView?.reloadData()
            refresher.endRefreshing()
            print("HistoryCVC Refreshed")
        }else{
            let alert = UIAlertController(title: "Ooops!!", message:"Connection Error!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in})
            self.present(alert, animated: true){};
        }
        
        
    }
    
    func saveFriends(){
        FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "id, first_name, last_name, middle_name, name, email, picture"]).start { (connection, result, err) in
            
            if err != nil {
                print("HistoryCVC Failed to start graph request:", err ?? "")
                return
            }
            let data:[String:AnyObject] = result as! [String : AnyObject]
            let prefs:UserDefaults = UserDefaults.standard
            prefs.set(data, forKey: "FriendsData")
            prefs.synchronize()
            print("HistoryCVC Friends Updated", data)
            
            
        }
    }
    
    func setupNavBarButtons() {
        
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 415, height: 44))
        
        let messages = UIBarButtonItem(image: UIImage(named: "chat")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMessage))
        
        let logout = UIBarButtonItem(image: UIImage(named: "logout")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleLogout))
        
        let title = UIBarButtonItem(title: "MoodyMood", style: .plain, target: self, action: #selector(handleMore))
        
        let logo = UIBarButtonItem(image: UIImage(named: "icon")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleMore))
        
        
        let navItem = UINavigationItem(title: "")
        navItem.rightBarButtonItems = [logout, messages]
        navItem.leftBarButtonItems = [logo, title]
        navBar.setItems([navItem], animated: false)
        
        self.view.addSubview(navBar);
        print("HistoryCVC NavBar Loaded")
        
    }
    func handleMessage(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window!.rootViewController = UINavigationController(rootViewController: MessagesController())
        appDelegate.window!.makeKeyAndVisible()
        print("HistoryCVC handleMessage")
        
    }
    func handleLogout(){
        
        let alert = UIAlertController(title: "Logout", message:"Are You Sure You Want To Logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("HistoryCVC Logout Canceled")
        }))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            UserDefaults.standard.set(false, forKey: "ISLOGGEDIN")
            let manager = FBSDKLoginManager()
            manager.logOut()
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
            print("HistoryCVC handleLogout")
        })
        self.present(alert, animated: true){};
        
    }
    
    func handleMore() {
        print("HistoryCVC handleMore")
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let HistoryFeedCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! HistoryFeedCell
        
        HistoryFeedCell.post = posts[(indexPath as NSIndexPath).item]
        HistoryFeedCell.feedController = self
        
        return HistoryFeedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let statusText = posts[(indexPath as NSIndexPath).item].statusText {
            
            let rect = NSString(string: statusText).boundingRect(with: CGSize(width: view.frame.width, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
            
            let knownHeight: CGFloat = 8 + 44 + 4 + 4 + 200 + 8 + 24 + 8 + 44
            
            return CGSize(width: view.frame.width, height: rect.height + knownHeight + 24)
        }
        
        return CGSize(width: view.frame.width, height: 500)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}

class HistoryFeedCell: UICollectionViewCell {
    
    var feedController: HistoryFeedController?
    var users = [User]()
    var post: HistoryPost? {
        didSet {
            
            if let name = post?.name {
                
                let attributedText = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14)])
                
                nameLabel.attributedText = attributedText
                
            }
            
            if let statusText = post?.statusText {
                statusTextView.text = "Feels : ".appending(statusText)
            }else{
                post?.statusText = "Status Not Assigned Yet!"
                statusTextView.text = "Status Not Assigned Yet!"
            }
            
            if let profileImag:String = post?.profileImageName {
                profileImageView.downloadedFrom(link: profileImag)
                print("Profile", profileImag)
            }
            
            if let statusImageName = post?.statusImageName {
                
                statusImageView.loadImageUsingUrlString(statusImageName)
            }else{
                post?.statusImageName = "http://138.201.61.97/~moodymood/img/statuss.png"
                statusImageView.loadImageUsingUrlString("http://138.201.61.97/~moodymood/img/statuss.png")
            }
            
            if let Time = post?.numComments {
                likesCommentsLabel.text = Time
            }
            
            
            
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fetchUser()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        
        
        
        return label
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let statusTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isScrollEnabled = false
        return textView
    }()
    
    let statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    let likesCommentsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.rgb(155, green: 161, blue: 171)
        return label
    }()
    
    let dividerLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(226, green: 228, blue: 232)
        return view
    }()
    
    let likeButton: UIButton = HistoryFeedCell.buttonForTitle("Share", imageName: "invite")
    let commentButton: UIButton = HistoryFeedCell.buttonForTitle("&", imageName: "comment")
    let shareButton: UIButton = HistoryFeedCell.buttonForTitle("Message", imageName: "messageiconn")
    
    static func buttonForTitle(_ title: String, imageName: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: UIControlState())
        button.setTitleColor(UIColor.rgb(143, green: 150, blue: 163), for: UIControlState())
        
        button.setImage(UIImage(named: imageName), for: UIControlState())
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
        
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        
        return button
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
    func handleShare(){
        if(connectedToNetwork()){
            // Assemble Content
            let content: FBSDKShareLinkContent = FBSDKShareLinkContent()
            content.contentURL =  Foundation.URL(string: "http://codendot.com/")
            content.contentTitle = "Sharing My Friend's Mood With You!"
            content.contentDescription = self.post?.name?.appending(" Feels : ").appending((self.post?.statusText)!)
            content.imageURL = Foundation.URL(string: (self.post?.statusImageName)!)
            // Share Dialog
            let ShareDialog: FBSDKShareDialog = FBSDKShareDialog()
            ShareDialog.mode = FBSDKShareDialogMode.automatic
            ShareDialog.shareContent = content
            if (ShareDialog.canShow()){
                ShareDialog.show()
            }else{
                let alert = UIAlertController(title: "Ooops!", message:"Facebook Error!", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in})
                feedController?.present(alert, animated: true){};
            }
            print("HistoryCVC Handle Facebook Share")
        }else{
            let alert = UIAlertController(title: "Ooops!!", message:"Connection Error!", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in})
            feedController?.present(alert, animated: true){};
        }
    }
    func handleMore(){
        print("HistoryCVC HandleMore")
    }
    func fetchUser() {
        FIRDatabase.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.id = snapshot.key
                user.setValuesForKeys(dictionary)
                self.users.append(user)
            }
            
        }, withCancel: nil)
        print("Firebase Users Fetched")
    }
    
    func handleMessage(){
        for user in users{
            if user.name == post?.name{
                let selectedUser = User()
                selectedUser.setValue(post?.name, forKey: "name")
                selectedUser.setValue(post?.profileImageName, forKey: "profileImageUrl")
                selectedUser.setValue(user.id, forKey: "id")
                selectedUser.setValue(user.email, forKey: "email")
                let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
                chatLogController.user = selectedUser
                feedController?.present(chatLogController, animated: true)
                print("New Message To :", selectedUser.name!)
            }
        }
        print("FriendsCVC HandleMessage")
    }

    func setupViews() {
        backgroundColor = UIColor.white
        
        addSubview(nameLabel)
        addSubview(profileImageView)
        addSubview(statusTextView)
        addSubview(statusImageView)
        addSubview(likesCommentsLabel)
        addSubview(dividerLineView)
        
        addSubview(likeButton)
        addSubview(commentButton)
        addSubview(shareButton)
        likeButton.addTarget(self,action:#selector(handleShare),
                             for:.touchUpInside)
        
        shareButton.addTarget(self,action:#selector(handleMessage),
                              for:.touchUpInside)
        
        addConstraintsWithFormat("H:|-8-[v0(44)]-8-[v1]|", views: profileImageView, nameLabel)
        
        addConstraintsWithFormat("H:|-4-[v0]-4-|", views: statusTextView)
        
        addConstraintsWithFormat("H:|[v0]|", views: statusImageView)
        
        addConstraintsWithFormat("H:|-12-[v0]|", views: likesCommentsLabel)
        
        addConstraintsWithFormat("H:|-12-[v0]-12-|", views: dividerLineView)
        
        //button constraints
        addConstraintsWithFormat("H:|[v0(v2)][v1(v2)][v2]|", views: likeButton, commentButton, shareButton)
        
        addConstraintsWithFormat("V:|-12-[v0]", views: nameLabel)
        
        
        
        addConstraintsWithFormat("V:|-8-[v0(44)]-4-[v1]-4-[v2(200)]-8-[v3(24)]-8-[v4(0.4)][v5(44)]|", views: profileImageView, statusTextView, statusImageView, likesCommentsLabel, dividerLineView, likeButton)
        
        addConstraintsWithFormat("V:[v0(44)]|", views: commentButton)
        addConstraintsWithFormat("V:[v0(44)]|", views: shareButton)
    }
}
extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: "http://graph.facebook.com/\(link)/picture?type=small") else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}
