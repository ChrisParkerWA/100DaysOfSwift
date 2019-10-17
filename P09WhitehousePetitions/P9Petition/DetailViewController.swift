//
//  DetailViewController.swift
//  P9Petition
//
//  Created by Chris Parker on 6/3/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    var webView: WKWebView!
    var detailItem: Petition?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let detailItem = detailItem else { return }
        
        let myNumber = detailItem.signatureCount as NSNumber?
        let formater = NumberFormatter()
        formater.groupingSeparator = ","
        formater.numberStyle = .decimal
        guard let formattedNumber = formater.string(from: myNumber!) else { return }
        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style> body { font-size: 130%; } h1 { background-color:#32c864 }  </style>
        </head>
        <body>
        <h1><p><b>Petititon Title:</b> \(detailItem.title)</p></h1>
        <p align=right><b>Signature Count: </b> \(formattedNumber)</p>
        <p><b>Petititon:</b> \(detailItem.body)</p>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
}
