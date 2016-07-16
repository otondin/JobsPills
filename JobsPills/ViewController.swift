//
//  ViewController.swift
//  JobsPills
//
//  Created by Gabriel Tondin on 16/07/16.
//  Copyright © 2016 Caife Software. All rights reserved.
//

import UIKit
import SwiftyJSON


class ViewController: UIViewController {
    
    var sentences: JSON = JSON.null
    
    // Interface components
    @IBOutlet weak var lblChapter: UILabel!
    @IBOutlet weak var lblSentence: UILabel!
    @IBOutlet weak var lblDivider: UILabel!
    @IBOutlet weak var lblInfoMediaYear: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        randomizeSentence()
    }
    
    // Randomize a sentence to show
    func randomizeSentence() {
        let position = Int(arc4random_uniform(UInt32(sentences.count)))
        
        let chapter: String = String(sentences[position]["Chapter"])
        let sentence: String = String(sentences[position]["Text"])
        let info: String = String(sentences[position]["Info"])
        let media: String = String(sentences[position]["Media"])
        let year: String = String(sentences[position]["Year"])
        
        lblChapter.text = chapter
        lblChapter.hidden = false
        
        lblSentence.text = sentence

        lblDivider.text = "___"
        lblDivider.hidden = false
        
        lblInfoMediaYear.text = info + " " + media + " " + year
        lblInfoMediaYear.hidden = false
        
    }
    
}
