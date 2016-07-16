//
//  ViewController.swift
//  ShakeJobs
//
//  Created by Gabriel Tondin on 05/07/16.
//  Copyright © 2016 Caife Software. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var chapters = [
        "Sobre o começo",
        "Sobre o começo",
        "Sobre o começo",
        "Sobre o começo"
    ]
    
    var sentences = [
        "Nós começamos com uma perspectiva bastante idealista - de que fazer alguma coisa com a mais alta qualidade e acertar logo na primeira vez seria realmente mais barato do que ter que voltar e refazer.",
        "Todos aqui sentem que agora é um daqueles momentos em que estamos influenciando o futuro.",
        "Por que música? Bem, amamos música e é sempre bom fazer algo que se ama.",
        "E mais uma coisa..."
    ]
    
    var whereAndWhen = [
        "Newsweek, 1984",
        "Conference All Things Digital D5, 2007",
        "Apresentando o primeiro iPod em 2011",
        "Keynote"
    ]

    @IBOutlet weak var lblChapter: UILabel!
    
    @IBOutlet weak var lblSentences: UILabel!
    
    @IBOutlet weak var lblDivider: UILabel!
    
    @IBOutlet weak var lblWhereAndWhen: UILabel!
    
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
            let position = Int(arc4random_uniform(UInt32(sentences.count)))
            
            lblChapter.text = chapters[position]
            lblChapter.hidden = false
            
            lblSentences.text = sentences[position]
            
            lblDivider.text = "___"
            lblDivider.hidden = false
            
            lblWhereAndWhen.text = whereAndWhen[position]
            lblWhereAndWhen.hidden = false
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let position = randomizePosition()
            
        lblChapter.text = chapters[position]
        lblChapter.hidden = false
        
        lblSentences.text = sentences[position]
        
        lblDivider.text = "___"
        lblDivider.hidden = false
        
        lblWhereAndWhen.text = whereAndWhen[position]
        lblWhereAndWhen.hidden = false
    }
    
    func randomizePosition() -> Int {
        let position = Int(arc4random_uniform(UInt32(sentences.count)))
        
        return position
    }

}

