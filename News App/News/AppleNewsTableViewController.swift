//
//  AppleNewsTableViewController.swift
//  News
//
//  Created by Honglei Zhou on 2/1/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit
import Foundation


class AppleNewsTableViewController: UITableViewController {
    
    // Mark: Properties
    var refresher: UIRefreshControl!
    var news: News?
    var parser: ParseFeed!
    let t12 = UIImage(named: "t12.png")
    let tm = UIImage(named: "tm.png")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parser = ParseFeed()
        
        // Load apple news
        loadAppleNews(urlString: getURL())
        
        // Create refresh control
        refresher = UIRefreshControl()
        tableView.addSubview(refresher)
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.tintColor = .blue
        refresher.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let news = self.news {
            return news.articles.count
        }else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "AppleTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? AppleTableViewCell  else {
            fatalError("The dequeued cell is not an instance of AppleTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        if let news = self.news {
            let article = news.articles[indexPath.row]
            
            cell.newsTitle.text = article.title
            cell.newsSource.text = article.source.name
            
            let date = parser.getReadableDate(dateString: article.publishedAt)
            
            // Set the status image based on the publish time
            var timage: UIImage!
            let now = Date()
            let hour:TimeInterval = 3600.0
            if Date(timeInterval: 12*hour, since: date) >= now {
                timage = tm
            }
            else {
                timage = t12
            }
            cell.newsImage.image = timage
            
            cell.newsDate.text = parser.getDateString(date: date)
        }
        
        return cell
    }
    
    // Mark: Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as? AppleDetailViewController
        let cellIndex = tableView.indexPathForSelectedRow?.row
        if let news = self.news {
            vc?.ttl = news.articles[cellIndex!].title
            vc?.date = parser.getDateString(date: parser.getReadableDate(dateString: news.articles[cellIndex!].publishedAt))
            vc?.desc = news.articles[cellIndex!].description
            vc?.url = news.articles[cellIndex!].url
            vc?.source = news.articles[cellIndex!].source.name
            let now = Date()
            let hour:TimeInterval = 3600.0
            let date = parser.getReadableDate(dateString: news.articles[cellIndex!].publishedAt)
            
            if Date(timeInterval: 12*hour, since: date) >= now {
                vc?.image = tm
            }
            else {
                vc?.image = t12
            }
        }
    }
    
    /// Load apple news
    func loadAppleNews(urlString: String){
        /// Get the news fromt the API. The data will be accessible in the `news` variable in the closure.
        /// This would be a great place to update the table view showing the news.
        parser.getNews(url: urlString) { (news) in
            self.news = news
            // If the request was successful, the data is available in this closure through the `news` variable
            // Print out for debugging
            if let news = news {
                for article in news.articles {
                    print(article.title)
                }
            }
            
            DispatchQueue.main.async {
                // Anything in here is execute on the main thread
                self.tableView.reloadData()
                
            }
        }
    }
    
    /// Get the URL
    /// -Parameter:
    /// -Return: `String` URL, contains query of the specific information
    func getURL() -> String {
        let now = Date()
        let hour:TimeInterval = 3600.0
        let prev = now - 24*hour
        
        let nowString = parser.getDateString(date: now)
        let prevString = parser.getDateString(date: prev)
        return "https://newsapi.org/v2/everything?q=apple&from=\(prevString)&to=\(nowString)&sortby=popularity&apiKey=9a37d9a5a8b8452e9338d0d4cdd3ad62"
    }
    
    @objc func refreshTable() {
        loadAppleNews(urlString: getURL())
        refresher.endRefreshing()
    }
}
