//
//  ViewController.swift
//  JobsPills
//
//  Created by Gabriel Tondin on 16/07/16.
//  Copyright © 2016 Caife Software. All rights reserved.
//

import UIKit
import SwiftyJSON
import FirebaseAnalytics


class ViewController: UIViewController {
    
    var sentences: JSON = JSON.null
    var contentSentence: String? = nil
    
    var contentVisible:Bool = false
    
    // Interface components
    @IBOutlet weak var lblChapter: UILabel!
    @IBOutlet weak var lblSentence: UILabel!
    @IBOutlet weak var lblDivider: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblMedia: UILabel!
    @IBOutlet weak var lblYear: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Hidding some buttons and labels o beniging
        lblChapter.hidden = true
        lblInfo.hidden = true
        lblDivider.hidden = true
        lblMedia.hidden = true
        lblYear.hidden = true
        
        
        // Enabling label sentence to be touchable
        lblSentence.userInteractionEnabled = true
        
        // Detecting long press touch on sentence
        let longTouchGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTouchHandler(_:)))
        lblSentence.addGestureRecognizer(longTouchGesture)
        
        // Detecting screenshot
        let mainQueue = NSOperationQueue.mainQueue()
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationUserDidTakeScreenshotNotification,
            object: nil,
            queue: mainQueue) { notification in
                if self.contentVisible == true {
                    self.showContentShare()
                    
                    FIRAnalytics.logEventWithName("Took Screenshot to Share Content", parameters: [
                        kFIRParameterContentType: "cont",
                        kFIRParameterItemID: "1"
                    ])
                }
            }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            randomizeSentence()
            
            contentVisible = true
            
            FIRAnalytics.logEventWithName("Shaked to Randomize Sentence", parameters: [
                kFIRParameterContentType: "cont",
                kFIRParameterItemID: "1"
            ])
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        randomizeSentence()
        
        contentVisible = true
        
        FIRAnalytics.logEventWithName("Touched to Randomize Sentence", parameters: [
            kFIRParameterContentType: "cont",
            kFIRParameterItemID: "1"
            ])
    }
    
    // Randomize a sentence to show
    func randomizeSentence() -> String{
        let position = Int(arc4random_uniform(UInt32(sentences.count)))
        
        let chapter: String = String(sentences[position]["Chapter"])
        contentSentence = String(sentences[position]["Text"])
        let info: String = String(sentences[position]["Info"])
        let media: String = String(sentences[position]["Media"])
        let year: String = String(sentences[position]["Year"])
    
        lblChapter.text = chapter
        lblChapter.hidden = false
        
        lblSentence.text = contentSentence

        lblDivider.text = "___"
        lblDivider.hidden = false
        
        lblInfo.text = info
        lblInfo.hidden = false
        lblMedia.text = media
        lblMedia.hidden = false
        lblYear.text = year
        lblYear.hidden = false
        
        FIRAnalytics.logEventWithName("Randomized Sentence", parameters: [
            kFIRParameterContentType: "cont",
            kFIRParameterItemID: "1"
        ])
        
        return contentSentence!
        
    }
    
    // Composing content to show this time
    func stringifySentence() -> String {
        let sentence = "JobsPills: \"" + contentSentence! + "\" (Steve Jobs)"
        
        return sentence
    }
    
    // Showing share activity
    func showContentShare() {
    
        let sharedInfoContent = "JobsPills - Frases do Steve Jobs - Get the app https://goo.gl/EhgwVP"
        
        let sharedItems = [screenShotToShare(), sharedInfoContent]
        
        let activityViewController = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
    }
    
    // Getting screen image to share
    func screenShotToShare() -> UIImage {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()

        return image
    }
    
    // Handling with long touch gesture
    func longTouchHandler(sender: UIGestureRecognizer) {
        if sender.state == .Ended {
            if contentVisible == true {
                self.showContentShare()
                
                FIRAnalytics.logEventWithName("Long Touched to Share Content", parameters: [
                    kFIRParameterContentType: "cont",
                    kFIRParameterItemID: "1"
                ])
            }
        }
    }
    
    
}
