//
//  Animal.swift
//  It's A Zoo in There
//
//  Created by Honglei Zhou on 1/24/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import Foundation
import UIKit

class Animal {
    
    let name: String
    let species: String
    let age: Int
    let image: UIImage
    let soundPath: String
    
    init(name: String, species: String, age: Int, image: UIImage, soundPath: String) {
        
        self.name = name
        
        self.species = species
        
        self.age = age
        
        self.image = image
        
        self.soundPath = soundPath
    }
    
    func dumpAnimalObject() {
        
        print("Animal Object: name=\(name), species=\(species), age=\(age), image=\(image)")
    
    }
}
