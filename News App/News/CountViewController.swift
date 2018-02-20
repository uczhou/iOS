//
//  CountViewController.swift
//  News
//
//  Created by Honglei Zhou on 2/2/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit

class CountViewController: UIViewController {
    
    // Mark: Properties
    var news: News?
    var parser: ParseFeed!
    @IBOutlet weak var countNumber: UILabel!
    @IBOutlet weak var countImage: UIImageView!
    @IBOutlet weak var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parser = ParseFeed()
        var count = 0
        parser.getNews(url: getURL()) { (news) in
            if let news = news {
                count = news.totalResults
            }
            
            DispatchQueue.main.async {
                self.countNumber.text = String(count)
            }
        }
            
        drawCircle()
        self.countLabel.text = "Apple Articles"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Draw red circle out of count number
    /// - Attribution: https://www.hackingwithswift.com/example-code/core-graphics/how-to-draw-a-circle-using-core-graphics-addellipsein
    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 180, height: 180))
        
        let img = renderer.image { ctx in
                ctx.cgContext.setStrokeColor(UIColor.red.cgColor)
                ctx.cgContext.setFillColor(UIColor.white.cgColor)
                ctx.cgContext.setLineWidth(5)
                let rectangle = CGRect(x: 10, y: 10, width: 150, height: 150)
                ctx.cgContext.addEllipse(in: rectangle)
                ctx.cgContext.drawPath(using: .fillStroke)
            }
        
        self.countImage.image = img
    }
    
    /// Get URL
    func getURL() -> String {
        //let now = Date()
        //let hour:TimeInterval = 3600.0
        //let prev = now - 24*hour
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let nowString = parser.getDateString(date: yesterday!)
        let prevString = parser.getDateString(date: yesterday!)
        return "https://newsapi.org/v2/everything?q=apple&from=\(prevString)&to=\(nowString)&sortby=popularity&apiKey=9a37d9a5a8b8452e9338d0d4cdd3ad62"
    }
    
}
