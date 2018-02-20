//
//  StockTableViewController.swift
//  News
//
//  Created by Honglei Zhou on 2/2/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit
import Foundation



class StockTableViewController: UITableViewController {
    
    // Mark: Properties
    var market: Market?
    var refresher: UIRefreshControl!
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var curPrice: UILabel!
    @IBOutlet weak var openPrice: UILabel!
    @IBOutlet weak var fiftyTwoWKH: UILabel!
    @IBOutlet weak var fiftyTwoWKL: UILabel!
    
    /// - Attribution: https://stackoverflow.com/questions/24475792/how-to-use-pull-to-refresh-in-swift
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Assign values to the labels UIView in table view
        self.symbolLabel.text = "Symbol"
        self.curPrice.text = "Current"
        self.openPrice.text = "Open"
        self.fiftyTwoWKH.text = "52wkh"
        self.fiftyTwoWKL.text = "52wkl"
        
        // Retrieve stock data and show the data
        loadStockData()
        
        // Create refresher control and add action on the control
        refresher = UIRefreshControl()
        tableView.addSubview(refresher)
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.tintColor = .blue
        refresher.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let market = self.market {
            return market.results.count
        }else {
            return 0
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "StockTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StockTableViewCell
        else {
            fatalError("The dequeued cell is not an instance of StockTableViewCell.")
        }
        // Assign values to each cell
        if let market = self.market {
            let stock = market.results[indexPath.row]
            cell.symbolLabel.text = stock.symbol
            cell.curPriceLabel.text = String(stock.lastPrice)
            cell.opPriceLabel.text = String(stock.open)
            cell.wkHighLabel.text = String(stock.fiftyTwoWkHigh)
            cell.wkLowLabel.text = String(stock.fiftyTwoWkLow)
        }

        return cell
    }
    
    /// Retrieve stocks and pass back a `Market` object in the completion block `completion()`
    /// - Attributions: Assignment write-up
    /// - Parameter url: A `String` of the url
    /// - Parameter completion: A closure to run on the converted JSON
    func getStocks(url: String, completion:@escaping (Market?) -> Void) {
        
        // Transform the `url` parameter argument to a `URL`
        guard let url = NSURL(string: url) else {
            fatalError("Unable to create NSURL from string")
        }
        
        // Create a url session and data task
        let session = URLSession.shared
        let task = session.dataTask(with: url as URL, completionHandler: { (data, response, error) -> Void in
            
          // Ensure there were no errors returned from the request
            guard error == nil else {
                fatalError("Error: \(error!.localizedDescription)")
            }
            
            // Ensure there is data and unwrap it
            guard let data = data else {
                fatalError("Data is nil")
            }
            
            // Serialize the raw data into our custom structs
            do {
                // Covert JSON to `Market`
                let decoder = JSONDecoder()
                let market = try decoder.decode(Market.self, from: data)
                
                // Call the completion block closure and pass the News as argument to the completion block.
                completion(market)
            } catch {
                print("Error serializing/decoding JSON: \(error)")
            }
        })
        
        // Tasks start off in suspended state, we need to kick it off
        task.resume()
    }
    
    /// Retrieve stock data and assign the data to `Market` variable
    /// - Attribution: https://www.barchart.com/ondemand/free-market-data-api
    func loadStockData() {
    
        let symbols = ["AAPL", "GOOGL", "MSFT", "AMZN","FB", "BABA", "TSM", "INTC", "ORCL", "CSCO", "IBM", "NVDA", "BIDU"]
        var url = "https://marketdata.websol.barchart.com/getQuote.json?apikey=fc2cda3b355cfb52b76abda7550a9607&symbols="
        let endpoint = "&fields=fiftyTwoWkHigh%2CfiftyTwoWkHighDate%2CfiftyTwoWkLow%2CfiftyTwoWkLowDate&mode=I&jerq=false"
        var querySymbol = symbols[0]
    
        for i in 1..<symbols.count {
            querySymbol = querySymbol + "%2C" + symbols[i]
        }
        url = url + querySymbol + endpoint
    
        getStocks(url: url) { (market) in
            self.market = market
            // If the request was successful, the data is available in this closure through the `news` variable
            // Print out for debugging
            if let market = market {
                for stock in market.results {
                    print(stock.symbol)
                }
            }
    
            DispatchQueue.main.async {
                // Anything in here is execute on the main thread
                self.tableView.reloadData()
            }
        }
    }
    
    /// Action for refresher control
    @objc func refreshTable() {
        loadStockData()
        refresher.endRefreshing()
    }

}
