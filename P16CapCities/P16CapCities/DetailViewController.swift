//
//  DetailViewController.swift
//  P16CapCities
//
//  Created by Chris Parker on 13/4/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit
import WebKit

/*
 Challenge Q3 - Modify the callout button so that pressing it shows a new view controller with a web view,
 taking users to the Wikipedia entry for that city.
*/
class DetailViewController: UIViewController {

    @IBOutlet var webView: WKWebView!
    var city: String = ""
    var selectedWebsite: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = city
        navigationItem.largeTitleDisplayMode = .never

        let url = URL(string: "https://" + selectedWebsite)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }

}
