//
//  ViewController.swift
//  Game
//
//  Created by Honglei Zhou on 2/7/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {

    // Mark: Properties
    
    @IBOutlet weak var tictacO: UIView!
    @IBOutlet weak var tictacX: UIView!
    
    @IBOutlet weak var startOver: UIButton!
    @IBOutlet weak var howtoPlay: UIButton!
    @IBOutlet weak var grid: UIImageView!
    @IBOutlet weak var gameInstruction: UIView!
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var instructionText: UITextView!
    @IBOutlet weak var backtoGame: UIButton!
    
    var grids = [UIView]()
    let ticOImage = UIImage(named: "tictacO.png")
    let ticXImage = UIImage(named: "tictacX.png")
    var turnO = true
    
    var xGrids = [Int]()
    var oGrids = [Int]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize Game Instructions
        gameInstruction.isUserInteractionEnabled = false
        instructionLabel.text = "Instructions"
        instructionText.text = "1. The game is played on a grid that's 3 squares by 3 squares.\n\n2. You are X, your friend (or the computer in this case) is O. Players take turns putting their marks in empty squares.\n\n3. The first player to get 3 of her marks in a row (up, down, across, or diagonally) is the winner.\n\n4. When all 9 squares are full, the game is over. If no player has 3 marks in a row, the game ends in a tie."
        gameInstruction.frame.origin.y = -667
        
        // Load Grid and Initialize the x, o
        loadGrid(initial: true)
        
        // Add actions to buttons
        howtoPlay.addTarget(self, action: #selector(showGameInstruction), for: .touchUpInside)
        startOver.addTarget(self, action: #selector(startOverGame), for: .touchUpInside)
        backtoGame.addTarget(self, action: #selector(backGame), for: .touchUpInside)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Show Game Instruction button action
    /// - Attribution: https://www.raywenderlich.com/76200/basic-uiview-animation-swift-tutorial
    /// - Parameter: UIButton
    /// - Return:
    @objc func showGameInstruction(sender: UIButton!) {
        for i in 0..<grids.count {
            grids[i].isHidden = true
        }
        tictacX.isHidden = true
        tictacO.isHidden = true
        
        gameInstruction.isHidden = false
        UIView.animate(withDuration: 1, animations: {
            self.gameInstruction.frame.origin.y = 0
        }, completion: nil)
        
        gameInstruction.isUserInteractionEnabled = true
    }
    
    /// Restart Game button action
    /// - Parameter: UIButton
    /// - Return:
    @objc func startOverGame(sender: UIButton!) {
        startGame()
    }
    
    /// Return back to game button action
    /// - Attribution: https://www.raywenderlich.com/76200/basic-uiview-animation-swift-tutorial
    /// - Parameter: UIButton
    /// - Return:
    @objc func backGame(sender: UIButton!) {
        
        UIView.animate(withDuration: 1, animations: {
            self.gameInstruction.frame.origin.y = 667
        }){ (finished) in
            UIView.animate(withDuration: 0, animations: {
                self.gameInstruction.isHidden = true
                self.gameInstruction.frame.origin.y = -667
                self.gameInstruction.isUserInteractionEnabled = false
                for i in 0..<self.grids.count {
                    self.grids[i].isHidden = false
                }
                self.tictacX.isHidden = false
                self.tictacO.isHidden = false
            })
        }
    }
    
    /// Start game function, called when user press Start Over Game Button or OK button in alert
    /// - Parameter:
    /// - Return:
    func startGame() {
        
        UIView.animate(withDuration: 1, animations: {
            for i in 0..<self.grids.count {
                UIView.animate(withDuration: 0.5, animations:
                {self.grids[i].alpha = 0.0}, completion: nil)
            }
        }){ (finished) in
            UIView.animate(withDuration: 1, animations: {
                self.grids = [UIView]()
                self.xGrids = [Int]()
                self.oGrids = [Int]()
                for layer in self.view.layer.sublayers! {
                    if layer.name == "Line" {
                        layer.removeFromSuperlayer()
                    }
                }
                self.loadGrid(initial: false)
            })
        }
        
    }
    
    /// Load Grid, called every time the grid is loaded or reloaded
    /// - Parameter: Bool
    /// - Return:
    func loadGrid(initial: Bool) {
        
        let gridImage = UIImage(named: "grid.png")
        self.grid.image = gridImage
        
        // Initialize the grid views
        for _ in 0...8 {
            let gridView = UIView()
            grids.append(gridView)
        }
        
        // Initialize x, o UIImageView
        if initial {
            addUIImageView(tictac: tictacX, image: ticXImage!)
            addUIImageView(tictac: tictacO, image: ticOImage!)
        }
       
        // Initialize the turn
        self.turnO = false
        
        // Set the initial state based on self.turnO
        // if it's O's turn, set O with alpha = 1, X with alpha = 0.5
        if self.turnO {
            tictacO.subviews[0].isUserInteractionEnabled = true
            tictacX.subviews[0].isUserInteractionEnabled = false
            tictacX.subviews[0].alpha = 0.5
            tictacO.subviews[0].alpha = 1
            UIView.animate(withDuration: 1, animations: {
                self.tictacO.transform = CGAffineTransform(scaleX: 2, y: 2)
            }) { (finished) in
                UIView.animate(withDuration: 1, animations: {
                    self.tictacO.transform = CGAffineTransform.identity
                })
            }
        }else {
            tictacO.subviews[0].isUserInteractionEnabled = false
            tictacX.subviews[0].isUserInteractionEnabled = true
            tictacO.subviews[0].alpha = 0.5
            tictacX.subviews[0].alpha = 1
            UIView.animate(withDuration: 1, animations: {
                self.tictacX.transform = CGAffineTransform(scaleX: 2, y: 2)
            }) { (finished) in
                UIView.animate(withDuration: 1, animations: {
                    self.tictacX.transform = CGAffineTransform.identity
                })
            }
        }
        
        self.view.addSubview(tictacX)
        self.view.addSubview(tictacO)
    
    }
    
    /// Add UIImage View to UIView
    /// - Parameter: UIView
    /// - Parameter: UIImage
    /// - Return:
    func addUIImageView(tictac: UIView, image: UIImage) {
        
        let ticImageView = TicTac(image: image)
        ticImageView.tag = 100
        ticImageView.isUserInteractionEnabled = true
        tictac.addSubview(ticImageView)
        addGesturesToView(view: ticImageView)
        
    }
    
    /// Draw Line on the screen
    /// - Attribution: https://stackoverflow.com/questions/26662415/draw-a-line-with-uibezierpath
    /// - Parameter: startX start point x
    /// - Parameter: startY start point y
    /// - Parameter: endX end point x
    /// - Parameter: endY end point y
    /// - Return:
    func drawLine(startX: Int, startY: Int, endX: Int, endY: Int) {
        
        //design the path
        let path = UIBezierPath()
        let start = CGPoint(x: startX, y: startY)
        let end = CGPoint(x: endX, y: endY)
        path.lineWidth = 3
        path.move(to: start)
        path.addLine(to: end)
        
        //design path in layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.name = "Line"
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 1.0
        
        self.view.layer.addSublayer(shapeLayer)
    }
    
    /// Add gesture to view
    /// - Parameter: view, where the gesture will be added
    /// - Return:
    func addGesturesToView(view: UIImageView) {
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
    }
    
    /// Get the UI View position based on coordinate
    /// - Parameter: x
    /// - Parameter: y
    /// - Return: Int, UI View Position
    func getPosition(x: CGFloat, y: CGFloat) -> Int {
        
        if x > 57.5 && x < 192.5 {
            if y > 97.5 && y < 232.5 {
                return 4
            }else if y <= 97.5 {
                return 1
            }else {
                return 7
            }
        }else if x <= 57.5 {
            if y > 97.5 && y < 232.5 {
                return 3
            }else if y < 97.5 {
                return 0
            }else {
                return 6
            }
        }else {
            if y > 97.5 && y < 232.5 {
                return 5
            }else if y < 97.5 {
                return 2
            }else {
                return 8
            }
        }
    }

    /// Add grid view to main view
    /// - Parameter: i grid view number
    /// - Return:
    func addGridView(i: Int) {
        
        self.view.addSubview(grids[i])
        let offx = 125 * (i % 3)
        let offy = 40 + 125 * (i / 3)
        grids[i].frame = CGRect(x: Double(offx), y: Double(offy), width: 115.0, height: 115.0)
    }
    
    /// Check if win solution has been achieved, and draw a line if win and return true
    /// - Parameter: grids contains o,x position information
    /// - Return: Bool, true if win solution is achieved
    func isWinSolution(grids: [Int]) -> Bool {
        if grids.count < 3 {
            return false
        }
        if grids.contains(0) && grids.contains(1) && grids.contains(2){
            drawLine(startX: 0, startY: 100, endX: 375, endY: 100)
            return true
        }
        if grids.contains(0) && grids.contains(3) && grids.contains(6){
            drawLine(startX: 62, startY: 40, endX: 62, endY: 415)
            return true
        }
        if grids.contains(0) && grids.contains(4) && grids.contains(8){
            drawLine(startX: 0, startY: 40, endX: 375, endY: 415)
            return true
        }
        if grids.contains(1) && grids.contains(4) && grids.contains(7){
            drawLine(startX: 185, startY: 40, endX: 185, endY: 415)
            return true
        }
        if grids.contains(2) && grids.contains(5) && grids.contains(8){
            drawLine(startX: 375, startY: 40, endX: 0, endY: 415)
            return true
        }
        if grids.contains(2) && grids.contains(4) && grids.contains(6){
            drawLine(startX: 315, startY: 40, endX: 315, endY: 415)
            return true
        }
        if grids.contains(3) && grids.contains(4) && grids.contains(5){
            drawLine(startX: 0, startY: 225, endX: 375, endY: 225)
            return true
        }
        if grids.contains(6) && grids.contains(7) && grids.contains(8){
            drawLine(startX: 0, startY: 350, endX: 375, endY: 350)
            return true
        }
        return false
    }
    
    /// Show alert information when player wins or the game is in stale state
    /// - Attribution: https://stackoverflow.com/questions/24195310/how-to-add-an-action-to-a-uialertview-button-using-swift-ios
    /// - Parameter: title alert title
    /// - Parameter: message alert message
    func showAlert(title: String, message: String) {
        // Create the alert controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.startGame()
        }
        
        // Add the actions
        alertController.addAction(okAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// handlePan action
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        
        if let view = recognizer.view {
            
            // Set the position
            if recognizer.state != .ended{
                let newX = view.center.x + translation.x
                let newY = view.center.y + translation.y
                view.center = CGPoint(x: newX, y: newY)
            } else {
                // Check the position when is in ended state
                let location = view.center
                var x: CGFloat
                var y: CGFloat
                
                if self.turnO {
                    x = location.x + 16 - 57
                    y = location.y + 450 - 57
                }else {
                    x = location.x + 244 - 57
                    y = location.y + 450 - 57
                }
                
                let position = getPosition(x: x, y: y)
                
                // Check if position has been occupied
                if xGrids.contains(position) || oGrids.contains(position) {
                    // If position has been occupied.
                    SoundManager.sharedInstance.playBeep()
                    if self.turnO {
                        tictacO.addSubview(view)
                        view.frame = CGRect(x: 0, y: 0, width: 114, height: 114)
                    }else {
                        tictacX.addSubview(view)
                        view.frame = CGRect(x: 0, y: 0, width: 114, height: 114)
                    }
                }else {
                    // If position has not been occupied
                    SoundManager.sharedInstance.playTink()
                    grids[position].addSubview(view)
                    addGridView(i: position)
                    view.frame = CGRect(x: 5, y: 5, width: 114, height: 114)
                    
                    // Set up the next turn 
                    if self.turnO {
                        oGrids.append(position)
                        addUIImageView(tictac: tictacO, image: ticOImage!)
                        tictacO.subviews[0].isUserInteractionEnabled = false
                        tictacX.subviews[0].isUserInteractionEnabled = true
                        tictacO.subviews[0].alpha = 0.5
                        tictacX.subviews[0].alpha = 1
                        UIView.animate(withDuration: 1, animations: {
                            self.tictacX.transform = CGAffineTransform(scaleX: 2, y: 2)
                        }) { (finished) in
                            UIView.animate(withDuration: 1, animations: {
                                self.tictacX.transform = CGAffineTransform.identity
                            })
                        }
                        self.turnO = false
                    }else {
                        xGrids.append(position)
                        addUIImageView(tictac: tictacX, image: ticXImage!)
                        tictacX.subviews[0].isUserInteractionEnabled = false
                        tictacO.subviews[0].isUserInteractionEnabled = true
                        UIView.animate(withDuration: 1, animations: {
                            self.tictacO.transform = CGAffineTransform(scaleX: 2, y: 2)
                        }) { (finished) in
                            UIView.animate(withDuration: 1, animations: {
                                self.tictacO.transform = CGAffineTransform.identity
                            })
                        }
                        tictacX.subviews[0].alpha = 0.5
                        tictacO.subviews[0].alpha = 1
                        self.turnO = true
                    }
                    
                    // Check if anyone wins
                    if oGrids.count >= 3  && isWinSolution(grids: oGrids){
                        //Alert
                        SoundManager.sharedInstance.playWin()
                        let title = "Player O wins"
                        let message = "Sorry for player X."
                        showAlert(title: title, message: message)
                    }else if xGrids.count >= 3  && isWinSolution(grids: xGrids) {
                        //Alert
                        SoundManager.sharedInstance.playWin()
                        let title = "Player X wins"
                        let message = "Sorry for player O."
                        showAlert(title: title, message: message)
                    }else if xGrids.count + oGrids.count == 9 {
                        //Alert
                        SoundManager.sharedInstance.playWin()
                        let title = "It's a tie game"
                        let message = "Let's play again!"
                        showAlert(title: title, message: message)
                    }
                }
            }
        }
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }

}

