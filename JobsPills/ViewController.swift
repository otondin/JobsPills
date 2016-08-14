//
//  ViewController.swift
//  JobsPills
//
//  Created by Gabriel Tondin on 16/07/16.
//  Copyright © 2016 Caife Software. All rights reserved.
//

import UIKit
import SwiftyJSON
import Firebase
import FirebaseAnalytics
import MessageUI

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var sentences: JSON = JSON.null
    var contentSentence: String? = nil
    
    // Shared Info
    let sharedInfoContent = "JobsPills - Frases do Steve Jobs - Baixe o app: http://jobspills.caife.com.br"
    
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
                    self.showActionOptions()
                    
                    FIRAnalytics.logEventWithName("Took Screenshot to Share Content", parameters: nil)
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
            
            FIRAnalytics.logEventWithName("Shaked to Randomize Sentence", parameters: nil)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        randomizeSentence()
        
        contentVisible = true
        
        FIRAnalytics.logEventWithName("Touched to Randomize Sentence", parameters: nil)
    }
    
    // Randomize a sentence to show
    func randomizeSentence() -> String {
        let position = Int(arc4random_uniform(UInt32(self.sentences.count)))
        
        let chapter: String = String(self.sentences[position]["Chapter"])
        self.contentSentence = String(self.sentences[position]["Text"])
        let info: String = String(self.sentences[position]["Info"])
        let media: String = String(self.sentences[position]["Media"])
        let year: String = String(self.sentences[position]["Year"])
        
        self.lblChapter.text = chapter
        self.lblChapter.hidden = false
        
        self.lblSentence.text = self.contentSentence
        
        self.lblDivider.text = "___"
        self.lblDivider.hidden = false
        
        self.lblInfo.text = info
        self.lblInfo.hidden = false
        self.lblMedia.text = media
        self.lblMedia.hidden = false
        self.lblYear.text = year
        self.lblYear.hidden = false
        
        return contentSentence!
    }
    
    // Composing content to show this time
    func stringifySentence() -> String {
        let sentence = "\"\(contentSentence!)\""
        
        return sentence
    }
    
    // Showing action options to share or report error on sentence
    func showActionOptions() {
        let optionMenu = UIAlertController(title: nil, message: "O que deseja fazer?", preferredStyle: .ActionSheet)
        
        let shareScreenShotOption = UIAlertAction(title: "Compartilhar screenshot", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
                self.shareScreenShotActivity()
        })
        
        let shareSentenceOption = UIAlertAction(title: "Compartilhar frase", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.shareSentenceActivity()
        })
        
        let reportErrorOption = UIAlertAction(title: "Reportar erro", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
                self.reportSentenceError()
        })
        
        let cancelOption = UIAlertAction(title: "Cancelar", style: .Cancel, handler: nil)
        
        optionMenu.addAction(shareScreenShotOption)
        optionMenu.addAction(shareSentenceOption)
        optionMenu.addAction(reportErrorOption)
        optionMenu.addAction(cancelOption)
        
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    // Showing share activity
    func shareScreenShotActivity() {
        
        let sharedImageContent = screenShotToShare().0
        
        let sharedItems = [sharedImageContent, sharedInfoContent]
        
        let activityViewController = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
        
        FIRAnalytics.logEventWithName("Shared Screenshot", parameters: nil)
    }
    
    func shareSentenceActivity() {
        
        let sharedItems = [stringifySentence(), sharedInfoContent]
        
        let activityViewController = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
        
        FIRAnalytics.logEventWithName("Shared Sentence", parameters: nil)
    }
    
    // Reporting Sencente Error
    func reportSentenceError() {
        let subject = "JobsPills - Reportar erro"
        let destination = "jobspills@caife.com.br"
        let mail = MFMailComposeViewController()
        let attachment = screenShotToShare().1
        
        mail.mailComposeDelegate = self
        mail.setSubject(subject)
        mail.setToRecipients([destination])
        mail.addAttachmentData(attachment, mimeType: "image/jpg", fileName: "Sentence")
        
        self.presentViewController(mail, animated: true, completion: nil)
    }
    
    // Controlling mail sending
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result {
        case MFMailComposeResultCancelled:
            print("Mail cancelled")
        case MFMailComposeResultSaved:
            print("Mail saved")
        case MFMailComposeResultSent:
            print("Mail sent")
        case MFMailComposeResultFailed:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
        
        FIRAnalytics.logEventWithName("Error Reported", parameters: nil)
        
    }

    // Getting screen image to share
    func screenShotToShare() -> (UIImage, NSData) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        let imageData = UIImagePNGRepresentation(image)
        let imageToShare = UIImage.init(data: imageData!)
        return (imageToShare!, imageData!)
    }
    
    // Handling with long touch gesture
    func longTouchHandler(sender: UILongPressGestureRecognizer) {
        if sender.state == .Began {
            if contentVisible == true {
                self.showActionOptions()
                
                FIRAnalytics.logEventWithName("Long Touched to Share Content", parameters: nil)
            }
        }
    }
    
    //MARK: Some animations
    

}
