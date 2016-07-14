//
//  InterfaceController.swift
//  Help Extension
//
//  Created by Thomas Mac on 06/07/2016.
//  Copyright © 2016 ThomasNeyraut. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet private var button: WKInterfaceButton!
    
    private var timer = NSTimer()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        if (WCSession.defaultSession().reachable) {
            //This means the companion app is reachable
        }
        
        self.button.setTitle("")
        self.button.setBackgroundImage(UIImage(named:"alarm.png"))
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction private func buttonActionListener()
    {
        let data = ["data": "alert"]
        WCSession.defaultSession().sendMessage(data, replyHandler: { (_: [String : AnyObject]) -> Void in }, errorHandler: { (NSError) -> Void in })
            
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target:self, selector:#selector(self.keepSoundMax), userInfo:nil, repeats:true)
    }
    
    @objc private func keepSoundMax()
    {
        let data = ["data": "keepSoundMax"]
        WCSession.defaultSession().sendMessage(data, replyHandler: { (_: [String : AnyObject]) -> Void in }, errorHandler: { (NSError) -> Void in })
    }
    
    func session(session: WCSession, didReceiveMessageData messageData: NSData) {
        self.timer.invalidate()
    }
    
}
