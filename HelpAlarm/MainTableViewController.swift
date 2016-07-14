//
//  MainTableViewController.swift
//  HelpAlarm
//
//  Created by Thomas Mac on 06/07/2016.
//  Copyright © 2016 ThomasNeyraut. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import WatchConnectivity

class MainTableViewController: UITableViewController, AVAudioPlayerDelegate, WCSessionDelegate, UITextFieldDelegate {

    private let musicArray: Array = ["sirene1", "sirene2", "sirene3", "hurlement"]
    
    private let extensionArray: Array = ["wav", "wav", "wav", "wav"]
    
    private let sauvegarde = NSUserDefaults()
    
    private var audioPlayer = AVAudioPlayer()
    
    private var isActivate = false
    
    private var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.tableView.registerClass(TableViewCellWithOneButton.classForCoder(), forCellReuseIdentifier:"cellOneButton")
        self.tableView.registerClass(TableViewCellWithTwoButtons.classForCoder(), forCellReuseIdentifier:"cellTwoButtons")
        
        self.title = "Help Alarm"
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.8)
        shadow.shadowOffset = CGSizeMake(0, 1)
        
        let rightButton = UIBarButtonItem(title:"Change password", style:UIBarButtonItemStyle.Done, target:self, action:#selector(self.changePassword))
        rightButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red:245.0/255.0, green:245.0/255.0, blue:245.0/255.0, alpha:1.0), NSShadowAttributeName: shadow, NSFontAttributeName: UIFont(name:"HelveticaNeue-CondensedBlack", size:21.0)!], forState:UIControlState.Normal)
        
        self.navigationItem.rightBarButtonItem = rightButton
        
        if (!self.sauvegarde.boolForKey("initialisation"))
        {
            self.sauvegarde.setInteger(0, forKey:"music")
            self.sauvegarde.synchronize()
            
            self.setFirstPassword()
        }
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        if (WCSession.defaultSession().reachable) {
            //This means the companion app is reachable
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch _ {
            
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return (textField.text?.characters.count)! + string.characters.count <= 4
    }
    
    private func setFirstPassword()
    {
        let alertController = UIAlertController(title:"Password", message:"Rentrez un password à 4 chiffres.", preferredStyle:.Alert)
        
        let alertAction = UIAlertAction(title:"OK", style:.Default) { (_) in
            let passwordTextField = alertController.textFields![0] as UITextField
            let passwordConfirmationTextField = alertController.textFields![1] as UITextField
            if (!passwordTextField.hasText() || passwordTextField.text?.characters.count != 4 || passwordTextField.text != passwordConfirmationTextField.text)
            {
                self.setFirstPassword()
            }
            else
            {
                self.sauvegarde.setObject(passwordTextField.text, forKey:"password")
                self.sauvegarde.setBool(true, forKey:"initialisation")
                self.sauvegarde.synchronize()
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler{ (textField) in
            textField.placeholder = "password : 4 chiffres"
            textField.textAlignment = .Center
            textField.keyboardType = UIKeyboardType.NumberPad
            textField.secureTextEntry = true
            textField.delegate = self
        }
        
        alertController.addTextFieldWithConfigurationHandler{ (textField) in
            textField.placeholder = "password confirmation"
            textField.textAlignment = .Center
            textField.keyboardType = UIKeyboardType.NumberPad
            textField.secureTextEntry = true
            textField.delegate = self
        }
        
        alertController.addAction(alertAction)
        self.presentViewController(alertController, animated:true, completion:nil)
    }
    
    @objc private func changePassword()
    {
        let alertController = UIAlertController(title:"Password", message:"Rentrez un password à 4 chiffres.", preferredStyle:.Alert)
        
        let alertAction = UIAlertAction(title:"OK", style:.Default) { (_) in
            let ancienPasswordTextField = alertController.textFields![0] as UITextField
            let passwordTextField = alertController.textFields![1] as UITextField
            let passwordConfirmationTextField = alertController.textFields![2] as UITextField
            if (!passwordTextField.hasText() || (passwordTextField.text?.characters.count)! != 4 || ancienPasswordTextField.text != self.sauvegarde.objectForKey("password") as? String || passwordTextField.text != passwordConfirmationTextField.text)
            {
                self.changePassword()
            }
            else
            {
                self.sauvegarde.setObject(passwordTextField.text, forKey:"password")
                self.sauvegarde.synchronize()
            }
        }
        
        let otherAlertAction = UIAlertAction(title:"Annuler", style:.Default) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler{ (textField) in
            textField.placeholder = "ancien password"
            textField.textAlignment = .Center
            textField.keyboardType = UIKeyboardType.NumberPad
            textField.secureTextEntry = true
            textField.delegate = self
        }
        
        alertController.addTextFieldWithConfigurationHandler{ (textField) in
            textField.placeholder = "password : 4 chiffres"
            textField.textAlignment = .Center
            textField.keyboardType = UIKeyboardType.NumberPad
            textField.secureTextEntry = true
            textField.delegate = self
        }
        
        alertController.addTextFieldWithConfigurationHandler{ (textField) in
            textField.placeholder = "password confirmation"
            textField.textAlignment = .Center
            textField.keyboardType = UIKeyboardType.NumberPad
            textField.secureTextEntry = true
            textField.delegate = self
        }
        
        alertController.addAction(alertAction)
        alertController.addAction(otherAlertAction)
        self.presentViewController(alertController, animated:true, completion:nil)
    }
    
    @objc private func stopMusic()
    {
        let alertController = UIAlertController(title:"Password", message:"Rentrez votre password.", preferredStyle:.Alert)
        
        let alertAction = UIAlertAction(title:"OK", style:.Default) { (_) in
            let passwordTextField = alertController.textFields![0] as UITextField
            if (!passwordTextField.hasText() || passwordTextField.text?.characters.count != 4 || passwordTextField.text != self.sauvegarde.objectForKey("password") as? String)
            {
                self.stopMusic()
            }
            else
            {
                let data = ["data": "stop"]
                WCSession.defaultSession().sendMessage(data, replyHandler: { (_: [String : AnyObject]) -> Void in }, errorHandler: { (NSError) -> Void in })
                
                let shadow = NSShadow()
                shadow.shadowColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.8)
                shadow.shadowOffset = CGSizeMake(0, 1)
                
                let rightButton = UIBarButtonItem(title:"Change password", style:UIBarButtonItemStyle.Done, target:self, action:#selector(self.changePassword))
                rightButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red:245.0/255.0, green:245.0/255.0, blue:245.0/255.0, alpha:1.0), NSShadowAttributeName: shadow, NSFontAttributeName: UIFont(name:"HelveticaNeue-CondensedBlack", size:21.0)!], forState:UIControlState.Normal)
                
                self.navigationItem.rightBarButtonItem = rightButton
                
                self.isActivate = false
                self.timer.invalidate()
                self.audioPlayer.stop()
            }
        }
        
        alertController.addTextFieldWithConfigurationHandler{ (textField) in
            textField.placeholder = "password"
            textField.textAlignment = .Center
            textField.keyboardType = UIKeyboardType.NumberPad
            textField.secureTextEntry = true
        }
        
        alertController.addAction(alertAction)
        self.presentViewController(alertController, animated:true, completion:nil)
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if (message["data"] as! String == "keepSoundMax")
        {
            self.keepSoundMax()
            return
        }
        
        if (self.isActivate)
        {
            return
        }
        self.isActivate = true
        self.keepSoundMax()
        self.playMusicAtIndice(self.sauvegarde.integerForKey("music"), numberOfLoops:-1, volume:1)
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target:self, selector:#selector(self.keepSoundMax), userInfo:nil, repeats:true)
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.8)
        shadow.shadowOffset = CGSizeMake(0, 1)
        
        let rightButton = UIBarButtonItem(title:"Stop", style:UIBarButtonItemStyle.Done, target:self, action:#selector(self.stopMusic))
        rightButton.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red:245.0/255.0, green:245.0/255.0, blue:245.0/255.0, alpha:1.0), NSShadowAttributeName: shadow, NSFontAttributeName: UIFont(name:"HelveticaNeue-CondensedBlack", size:21.0)!], forState:UIControlState.Normal)
        
        self.navigationItem.rightBarButtonItem = rightButton
    }

    @objc private func keepSoundMax()
    {
        (MPVolumeView().subviews.filter{ NSStringFromClass($0.classForCoder) == "MPVolumeSlider" }.first as? UISlider)?.setValue(1, animated:false)
    }
    
    internal func playMusicAtIndice(indice: Int, numberOfLoops: Int, volume: Float)
    {
        if (indice < 0 || indice >= self.musicArray.count)
        {
            return
        }
        (MPVolumeView().subviews.filter{ NSStringFromClass($0.classForCoder) == "MPVolumeSlider" }.first as? UISlider)?.setValue(volume, animated:false)
        
        let music = NSBundle.mainBundle().pathForResource(String(self.musicArray[indice]), ofType:String(self.extensionArray[indice]))
        do {
            self.audioPlayer = try AVAudioPlayer(contentsOfURL:NSURL(fileURLWithPath:music!))
            self.audioPlayer.delegate = self
            self.audioPlayer.numberOfLoops = numberOfLoops
            self.audioPlayer.play()
        } catch _ {
            
        }
    }
    
    internal func setNewFavorisMusic(indice: Int)
    {
        if (indice < 0 || indice >= self.musicArray.count)
        {
            return
        }
        self.sauvegarde.setInteger(indice, forKey:"music")
        self.sauvegarde.synchronize()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (section == 0)
        {
            return 1
        }
        return self.musicArray.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0)
        {
            return "Song save"
        }
        return "Others songs"
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 75.0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0)
        {
            let cell = tableView.dequeueReusableCellWithIdentifier("cellOneButton", forIndexPath: indexPath) as! TableViewCellWithOneButton
            
            cell.imageView?.image = UIImage(named:NSLocalizedString("ICON_MUSIC_FAVORIS", comment:""))
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            cell.textLabel?.lineBreakMode = .ByWordWrapping
            
            cell.textLabel?.numberOfLines = 0
            
            cell.textLabel?.text = String(self.musicArray[self.sauvegarde.integerForKey("music")])
            
            cell.mainTableViewController = self
            
            cell.indice = self.sauvegarde.integerForKey("music")
            
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("cellTwoButtons", forIndexPath: indexPath) as! TableViewCellWithTwoButtons
        
        cell.imageView?.image = UIImage(named:NSLocalizedString("ICON_MUSIC", comment:""))
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        cell.textLabel?.lineBreakMode = .ByWordWrapping
        
        cell.textLabel?.numberOfLines = 0
        
        cell.textLabel?.text = String(self.musicArray[indexPath.row])
        
        cell.mainTableViewController = self
        
        cell.indice = indexPath.row
        
        return cell
    }
    
}
