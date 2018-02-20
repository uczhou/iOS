//
//  ViewController.swift
//  It's A Zoo in There
//
//  Created by Honglei Zhou on 1/24/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

/// Figure-Dog: http://channel.nationalgeographic.com/wild/pet-talk/articles/how-long-is-too-long-to-leave-your-dog-alone/
/// Figure-Cat: http://www.themalaysiantimes.com.my/cat-hotel-and-spa-in-kota-bharu/
/// Figure-Pig: https://www.youtube.com/watch?v=0HKvBh-W1tg
/// Sounds: http://www.animal-sounds.org/animal-sounds-free-download.html
/// Icon: https://i2.wp.com/webdesignledger.com/wp-content/uploads/scary-stories-app-icon.jpeg?resize=863%2C647

import UIKit
import AVFoundation

// Extension array to provide shuffle function
extension Array {
    // Learn from: https://gist.github.com/ijoshsmith/5e3c7d8c2099a3fe8dc3
    mutating func shuffle() {
        
        if count < 2 {return}
        
        for i in 0..<count {
            
            let j = Int(arc4random_uniform(UInt32(count-i))) + i
            
            if i != j {
                
                swapAt(i,j)
                
            }
        }
    }
}

class ViewController: UIViewController, UIScrollViewDelegate{
    
    // MARK: Properties
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    // Animal Array
    var animals: [Animal]!
    
    var player: AVAudioPlayer?
    
    // scrollView contentOffset from last time
    var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create animal instances
        let dog: Animal = Animal(name: "Dog", species: "Dog", age: 2, image: UIImage(named: "dog.jpg")!, soundPath: "dog.wav")
        let cat: Animal = Animal(name: "Cat", species: "Cat", age: 2, image: UIImage(named: "cat.jpg")!, soundPath: "cat.wav")
        let pig: Animal = Animal(name: "Pig", species: "Pig", age: 2, image: UIImage(named: "piglet.jpg")!, soundPath: "pig.wav")
        
        animals = [dog, cat, pig]
        
        // Shuffle array every time the view is loaded
        animals.shuffle()
        
        // Set scrollView content size and background color
        scrollView.contentSize = CGSize(width: 1125, height: 500)
        scrollView.backgroundColor = .lightGray
        self.view.addSubview(scrollView)
        
        // Create buttons and add buttons to scrollView
        var buttons = [UIButton]()
        
        for i in 0..<3 {
            buttons.append(UIButton())
            buttons[i].tag = i
            buttons[i].frame = CGRect(x: 375*i+150, y: 400, width: 75, height: 50)
            buttons[i].setTitle(animals[i].name, for: .normal)
            buttons[i].setTitleColor(.black, for: .normal)
            buttons[i].addTarget(self, action: #selector(buttonTapped), for: UIControlEvents.touchUpInside)
            buttons[i].backgroundColor = .gray
            self.scrollView.addSubview(buttons[i])
        }
        
        // Create imageViews and add imageViews to scrollView
        var imageViews = [UIImageView]()
        
        for i in 0..<3 {
            imageViews.append(UIImageView())
            imageViews[i].image = animals[i].image
            imageViews[i].frame = CGRect(x: 375*i+12, y: 70, width: 350, height: 300)
            self.scrollView.addSubview(imageViews[i])
        }
        
        // Set the initial Label text
        nameLabel.text = animals[0].name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Function triggered when button is tapped.
    @objc func buttonTapped(sender: UIButton) {
        
        // Retrieve information corresponded to button tag
        let species = animals[sender.tag].species
        let age = animals[sender.tag].age
        let name = animals[sender.tag].name
        let soundPath = animals[sender.tag].soundPath
        let message = "This \(name) is \(age) years old"
        
        // Create alert and action
        let alert = UIAlertController(title: species, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
        // Play sound
        // Learn from: https://www.hackingwithswift.com/example-code/media/how-to-play-sounds-using-avaudioplayer
        let path = Bundle.main.path(forResource: soundPath, ofType:nil)!
        let url = URL(fileURLWithPath: path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Could not play the sound")
        }
        
        animals[sender.tag].dumpAnimalObject()
    }
    
    // Show label text with the name of the animal showed on the screen
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        // Get current scrollView contentOffset x position
        let xOffset: CGFloat = scrollView.contentOffset.x
        
        // Calculate the idex of animal within array on the subview
        let idx: Int = Int(xOffset / 375)
        
        // Show animal name
        nameLabel.text = animals[idx].name
        
    }
    
    // Fade in and out the label when scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Get the current scrollView contentOffset x position
        let xOffset: CGFloat = scrollView.contentOffset.x
        
        var alpha: CGFloat = 1
        
        // Change the alpha value based on lastContentOffset and current contentOffset
        if lastContentOffset <= xOffset {
            if xOffset < 375 {
                alpha = 1 - xOffset / 375
            }
            else if xOffset < 750 {
                alpha = 1 - (xOffset - 375) / 375
            }
            else if xOffset < 1125 {
                alpha = 1 - (xOffset - 750) / 375
            }
            else {
                alpha = 1
            }
        }
        else {
            if xOffset > 750 {
                alpha = (xOffset - 750) / 375
            }
            else if xOffset > 375 {
                alpha = (xOffset - 375) / 375
            }
            else if xOffset > 0 {
                alpha = xOffset / 375
            }
            else {
                alpha = 1
            }
        }
        
        // Update label color with respective alpha value
        nameLabel.textColor = UIColor.black.withAlphaComponent(alpha)
        
        // Update lastContentOffset
        lastContentOffset = xOffset
    }
}


