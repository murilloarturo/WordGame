//
//  ViewController.swift
//  WordGame
//
//  Created by Arturo on 3/2/16.
//  Copyright © 2016 Kogimobile. All rights reserved.
//

import UIKit
import GameplayKit;

class ViewController: UIViewController {

    @IBOutlet weak var cluesLabel: UILabel!
    @IBOutlet weak var answersLabel: UILabel!
    @IBOutlet weak var currentAnswerTextField: UITextField!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var letterButtons = [UIButton]()
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var score: Int = 0 {
        
        didSet {
            
            scoreLabel.text = "Score: \(score)"
        }
    }
    var level = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        for subview in view.subviews where subview.tag == 1001 {
            
            let btn  = subview as! UIButton
            letterButtons.append(btn)
            btn.addTarget(self, action: "letterTapped:", forControlEvents: .TouchUpInside)
        }
        
        loadLevel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Load Level
    
    func loadLevel() {
        
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()
        
        if let levelFilePath = NSBundle.mainBundle().pathForResource("level\(level)", ofType: "txt") {
            if let levelContents = try? String(contentsOfFile: levelFilePath, usedEncoding: nil) {
                var lines = levelContents.componentsSeparatedByString("\n")
                lines = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(lines) as! [String]
                
                for (index, line) in lines.enumerate() {
                    
                    let parts = line.componentsSeparatedByString(": ")
                    let answer = parts[0]
                    let clue = parts[1]
                    
                    clueString += "\(index+1). \(clue)\n"
                    
                    let solutionWord = answer.stringByReplacingOccurrencesOfString("|", withString: "")
                    solutionString += "\(solutionWord.characters.count) letters\n"
                    solutions.append(solutionWord)
                    
                    let bits = answer.componentsSeparatedByString("|")
                    letterBits += bits
                }
            }
        }
        
        cluesLabel.text = clueString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        answersLabel.text = solutionString.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
        
        letterBits = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(letterBits) as! [String]
        letterButtons = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(letterButtons) as! [UIButton]
        
        if letterBits.count == letterButtons.count {
            for i in 0 ..< letterButtons.count {
                letterButtons[i].setTitle(letterBits[i], forState: .Normal)
            }
        }
    }
    
    //MARK: Actions
    
    func letterTapped(sender: UIButton) {
        
        currentAnswerTextField.text = currentAnswerTextField.text! + sender.titleLabel!.text!
        activatedButtons.append(sender)
        sender.hidden = true
    }
    
    @IBAction func submitTapped(sender: UIButton) {
        
        if let solutionPosition = solutions.indexOf(currentAnswerTextField.text!) {
            
            activatedButtons.removeAll()
            
            var splitClues = answersLabel.text?.componentsSeparatedByString("\n")
            splitClues![solutionPosition] = currentAnswerTextField.text!
            answersLabel.text = splitClues?.joinWithSeparator("\n")
            
            currentAnswerTextField.text = ""
            score += 1
            
            if score % 7 == 0 {
                let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .Default, handler: levelUp))
                presentViewController(ac, animated: true, completion: nil)
            }
        }
    }

    func levelUp(action: UIAlertAction) {
        
        level += 1
        solutions.removeAll(keepCapacity: true)
        
        loadLevel()
        
        for button in letterButtons {
            button.hidden = false
        }
    }
    
    @IBAction func clearTapped(sender: UIButton) {
        
        currentAnswerTextField.text = ""
        
        for button in activatedButtons {
            button.hidden = false
        }
        activatedButtons.removeAll()
    }
}

