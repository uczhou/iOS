//
//  MasterViewController.swift
//  Go Ask a Duck
//
//  Created by Honglei Zhou on 2/15/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var defaults = UserDefaults.standard
    
    var topics: Topics?
    
    
    /// Search bar to filter the table
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet { searchBar.delegate = self }
    }
    
    /// Data source and delegate object for our table
    let tableDataSourceDelegate = TableDataSourceDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        // Set the table source and delegate object
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.delegate = tableDataSourceDelegate
        self.tableView.dataSource = tableDataSourceDelegate
        
        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        // Set the table content
        if let lastQuery = defaults.string(forKey: "lastQuery"){
            let result = lastQuery.components(separatedBy: "\n")
            let urlString: String = "http://api.duckduckgo.com/?q=\(result[2])&format=json&pretty=1"
            searchHelper(urlString: urlString, searchText: result[2])
        } else {
            let urlString: String = "http://api.duckduckgo.com/?q=apple&format=json&pretty=1"
            searchHelper(urlString: urlString, searchText: "apple")
        }
        
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Verify we are using the correct segue
        if segue.identifier == "showDetail" {
            
            // Get the index for the selected row
            if let indexPath = self.tableView.indexPathForSelectedRow {
                
                // Retrieve the object from the data array
                let object = tableDataSourceDelegate.objects[indexPath.row]
                
                // Navigate the hierarchy to find the detail view controller
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                // Set the detail view controller's detailItem property
                controller.detailItem = object as AnyObject?
                
                // Set the bar button appropriately (depending on the preferences)
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                
                // Show the back button on the compact size
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

}

/// - Attribution: iOS class
extension MasterViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //
        
        let urlString: String = "http://api.duckduckgo.com/?q=\(searchBar.text!)&format=json&pretty=1"
        
        searchHelper(urlString: urlString, searchText: searchBar.text!)

    }
    
    /// Access the text of the search bar as it is being typed
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText.count > 0 {
            let urlString: String = "http://api.duckduckgo.com/?q=\(searchText)&format=json&pretty=1"
            searchHelper(urlString: urlString, searchText: searchText)
        }
        
    }
    
    func searchHelper(urlString: String, searchText: String) {
        // Live search
        tableDataSourceDelegate.allObjects = [String]()
        tableDataSourceDelegate.objects = [String]()
        
        let result = "\(urlString)\nurl\n\(searchText)"
        defaults.set(result, forKey: "lastQuery")
        
        // Search the text
        SearchUtils.sharedInstance.getTopics(url: urlString) { (topics) in
            self.topics = topics
            //self.tableDataSourceDelegate.allObjects = [String]()
            if let topics = topics {
                for topic in topics.RelatedTopics {
                    if topic.Result != nil {
                        let result = topic.Result!
                        let text = result.components(separatedBy: "</a>")
                        print(text[0])
                    }
                }
            }
            
        }
        if let topics = topics {
            for topic in topics.RelatedTopics {
                if topic.Result != nil && topic.FirstURL != nil {
                    let result = topic.Result!
                    let text = result.components(separatedBy: "</a>")
                    self.tableDataSourceDelegate.allObjects.append(topic.FirstURL! + "\n" + text[1] + "\n" + searchText)
                }
            }
        }
        
        tableDataSourceDelegate.filterContainsWithSearchText(searchText)
        self.tableView.reloadData()
    }
    
}
