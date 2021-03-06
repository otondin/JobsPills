//
//  ViewController.swift
//  JobsPills
//
//  Created by Gabriel Tondin on 16/07/16.
//  Copyright © 2016 Gabriel Tondin. All rights reserved.
//

import UIKit
import SwiftyJSON
import MessageUI
import FirebaseAnalytics

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var sentences: JSON = JSON.null
    var contentSentence: String?
    var contentVisible: Bool = false
    
    var canBecomeFirstResponde: Bool { return true }
    override var prefersStatusBarHidden: Bool { return true }
        
    // Shared Info
    let sharedInfoContent = "JobsPills - Baixe o app: http://jobspills.woords.com.br"
    
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
        
        if let file = Bundle(for:AppDelegate.self).path(forResource: "sentences", ofType: "json") {
            let data = try! Data(contentsOf: URL(fileURLWithPath: file))
            let json = try! JSON(data:data)
            sentences = json
        }
        
        // Hidding some buttons and labels o beniging
        lblChapter.isHidden = true
        lblInfo.isHidden = true
        lblDivider.isHidden = true
        lblMedia.isHidden = true
        lblYear.isHidden = true
        
        
        // Enabling label sentence to be touchable
        lblSentence.isUserInteractionEnabled = true
        
        // Detecting long press touch on sentence
        let longTouchGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longTouchHandler(_:)))
        lblSentence.addGestureRecognizer(longTouchGesture)
        
        // Detecting screenshot
        NotificationCenter.default.addObserver(forName: .UIApplicationUserDidTakeScreenshot, object: nil, queue: OperationQueue.main) { notification in
                if self.contentVisible == true {
                    self.showActionOptions()
                    
                    Analytics.logEvent("Took Screenshot to Share Content", parameters: nil)
                }
            }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            randomizeSentence()
            
            contentVisible = true
            
            Analytics.logEvent("Shaked to Randomize Sentence", parameters: nil)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        randomizeSentence()
        
        contentVisible = true
        
        Analytics.logEvent("Touched to Randomize Sentence", parameters: nil)
    }
    
    // Randomize a sentence to show
    func randomizeSentence() {
        let randomPosition = Int(arc4random_uniform(UInt32(sentences.count)))
        
        let chapter = sentences[randomPosition]["Chapter"].string
        let text = sentences[randomPosition]["Text"].string
        let info = sentences[randomPosition]["Info"].string
        let media = sentences[randomPosition]["Media"].string
        let year = sentences[randomPosition]["Year"].string
        
        self.lblChapter.text = chapter
        self.lblChapter.isHidden = false
        
        if let text = text {
            self.contentSentence = text
            self.lblSentence.text = self.contentSentence
        }
        
        self.lblDivider.text = "___"
        self.lblDivider.isHidden = false

        self.lblInfo.text = info
        self.lblInfo.isHidden = false
        
        self.lblMedia.text = media
        self.lblMedia.isHidden = false
        
        self.lblYear.text = year
        self.lblYear.isHidden = false
    }
    
    // Composing content to show this time
    func stringifySentence(_ contentSentence: String?) -> String {
        
        var stringSentence: String = ""
        
        if let content = contentSentence {
            stringSentence = "\"\(content)\" "
        }
        
        return stringSentence
    }
    
    // Showing action options to share or report error on sentence
    func showActionOptions() {
        let optionMenu = UIAlertController(title: nil, message: "O que deseja fazer?", preferredStyle: .actionSheet)
        
        let shareScreenShotOption = UIAlertAction(title: "Compartilhar screenshot", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
                self.shareScreenShotActivity()
        })
        
        let shareSentenceOption = UIAlertAction(title: "Compartilhar frase", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.shareSentenceActivity()
        })
        
        let reportErrorOption = UIAlertAction(title: "Reportar erro", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
                self.reportSentenceError()
        })
        
        let cancelOption = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        optionMenu.addAction(shareScreenShotOption)
        optionMenu.addAction(shareSentenceOption)
        optionMenu.addAction(reportErrorOption)
        optionMenu.addAction(cancelOption)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    // Showing share activity
    func shareScreenShotActivity() {
        
        let sharedImageContent = screenShotToShare().0
        
        let sharedItems = [sharedImageContent, sharedInfoContent] as [Any]
        
        let activityViewController = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
        
        Analytics.logEvent("Shared Screenshot", parameters: nil)
    }
    
    func shareSentenceActivity() {
        
        let sharedItems = [stringifySentence(contentSentence), sharedInfoContent]
        
        let activityViewController = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
        
        Analytics.logEvent("Shared Sentence", parameters: nil)
    }
    
    // Reporting Sencente Error
    func reportSentenceError() {
        let subject = "JobsPills - Reportar erro"
        let destination = "jobspills@woords.com.br"
        let mail = MFMailComposeViewController()
        let attachment = screenShotToShare().1
        
        mail.mailComposeDelegate = self
        mail.setSubject(subject)
        mail.setToRecipients([destination])
        mail.addAttachmentData(attachment, mimeType: "image/jpg", fileName: "Sentence")
        
        self.present(mail, animated: true, completion: nil)
    }
    
    // Controlling mail sending
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case MFMailComposeResult.cancelled:
            print("Mail cancelled")
        case MFMailComposeResult.saved:
            print("Mail saved")
        case MFMailComposeResult.sent:
            print("Mail sent")
        case MFMailComposeResult.failed:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        self.dismiss(animated: true, completion: nil)
        
        Analytics.logEvent("Error Reported", parameters: nil)
        
    }

    // Getting screen image to share
    func screenShotToShare() -> (UIImage, Data) {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        let imageData = UIImagePNGRepresentation(image!)
        let imageToShare = UIImage.init(data: imageData!)
        return (imageToShare!, imageData!)
    }
    
    // Handling with long touch gesture
    @objc func longTouchHandler(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            if contentVisible == true {
                self.showActionOptions()
                
                Analytics.logEvent("Long Touched to Share Content", parameters: nil)
            }
        }
    }
    
}
