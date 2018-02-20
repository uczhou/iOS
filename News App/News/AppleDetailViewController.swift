//
//  ArticleDetailViewController.swift
//  News
//
//  Created by Honglei Zhou on 2/2/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit

class AppleDetailViewController: UIViewController {
    
    // Mark: Properties
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsDate: UILabel!
    @IBOutlet weak var newsDesc: UITextView!
    @IBOutlet weak var newsSource: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    
    var url: URL?
    var ttl: String?
    var date: String?
    var desc: String?
    var image: UIImage?
    var source: String?
    
    @IBAction func openAction(_ sender: UIBarButtonItem) {
        if let link = url {
            UIApplication.shared.open(link, options: [:], completionHandler: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        newsTitle.text = ttl
        newsDate.text = date
        newsDesc.text = desc
        newsImage.image = image
        newsSource.text = source
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
}
