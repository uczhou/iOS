//
//  DetailViewController.swift
//  Go Ask a Duck
//
//  Created by Honglei Zhou on 2/15/18.
//  Copyright © 2018 Honglei Zhou. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController, WKNavigationDelegate{
    
    // All apps have a standard place to write
    // defaults
    var defaults = UserDefaults.standard
    var size = CGSize()
    var origin = CGPoint.zero
    
    var webView: WKWebView!
    
    var uIActivittyIndicator: UIActivityIndicatorView?
    
    @IBAction func addFavorite(_ sender: UIBarButtonItem) {
        if let detail = self.detailItem {
            // Check if value is in array
            addURL(detail: detail)
        }else {
            if let url = webView.url {
                let detail = "\(url.absoluteString)\nurl\nurl"
                addURL(detail: detail as AnyObject)
            }
        }
    }
    
    func addURL(detail: AnyObject) {
        if let urlArray = defaults.array(forKey: "myURL"){
            var tmp = urlArray
            var flag = false
            let result = detail.components(separatedBy: "\n")
            for data in tmp as! [String] {
                if !data.contains(result[0]) {
                    flag = true
                }
            }
            if tmp.count == 0 || flag {
                tmp.append(detail)
                defaults.set(tmp, forKey: "myURL")
            }
        } else {
            var urlArray = [AnyObject]()
            urlArray.append(detail)
            defaults.set(urlArray, forKey: "myURL")
        }
    }
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    /// -Attribution: https://developer.apple.com/documentation/webkit/wkwebview
    func configureView() {
        // Update the user interface for the detail item.
        
        // Create WKWebView
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: CGRect(origin: origin, size: size), configuration: webConfiguration)
        
        webView.navigationDelegate = self
        webView.isUserInteractionEnabled = true
        webView.scrollView.isScrollEnabled = true
        webView.allowsBackForwardNavigationGestures = true
        
        // Add UIActivityIndicator
        uIActivittyIndicator = UIActivityIndicatorView(frame: CGRect(x: webView.frame.width/2.5, y: webView.frame.height/2.5, width: webView.frame.width/6, height: webView.frame.width/6 ))
        uIActivittyIndicator?.backgroundColor = UIColor.gray
        uIActivittyIndicator?.color = UIColor.black
        
        webView.addSubview(uIActivittyIndicator!)
        
        self.view.addSubview(webView)
        
    }
    
    func loadWebView(url: String) {
        self.configureView()
        if let myURL = URL(string: url) {
            let request = URLRequest(url: myURL)
            print(url)
            webView.load(request)
        }
    }
    
    /// - Attribution: https://stackoverflow.com/questions/44408420/getting-the-link-url-tapped-in-wkwebview
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping ((WKNavigationActionPolicy) -> Void)) {
        switch navigationAction.navigationType {
        case .linkActivated:
            if navigationAction.targetFrame == nil {
                self.webView?.load(navigationAction.request)
                
            }
        default:
            break
        }
        
        decisionHandler(.allow)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        size = self.view.frame.size
        origin = CGPoint.zero
        // Do any additional setup after loading the view, typically from a nib.
        if let detail = self.detailItem {
            let result = detail.components(separatedBy: "\n")
            loadWebView(url: result[0])
        }else {
            if let lasturl = defaults.string(forKey: "lastVisited"){
                loadWebView(url: lasturl)
            } else {
                let url = "https://duckduckgo.com/Apple?ia=news"
                loadWebView(url: url)
            }
        }
        
        if let url = webView.url {
            print(url.absoluteString)
            defaults.set(url.absoluteString, forKey: "lastVisited")
        }
        
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        
        uIActivittyIndicator?.startAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
       
        uIActivittyIndicator?.stopAnimating()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    //
    // MARK: - Navigation
    //
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // When segueing to the `BookmarkViewController` set the delegate
        if segue.identifier == "segueToBookmarks" {
            let bvc = segue.destination as! BookmarkViewController
            bvc.delegate = self
        }
    }
    
}

//
// Implement the `DetailBookmarkDelegate` methods
//
extension DetailViewController: DetailBookmarkDelegate {
    
    func bookmarkPassedURL(_ url: String) {
        loadWebView(url: url)
    }
    
}



