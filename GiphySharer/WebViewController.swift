//
//  WebViewController.swift
//  GiphySharer
//
//  Created by Michael Gaylord on 29/11/19.
//  Copyright © 2019 Michael. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import Branch

class WebviewController : UIViewController, WKNavigationDelegate {
    
    private let url: URL
    private let webview = WKWebView()
    
    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webview)
        webview.load(URLRequest(url: self.url))
        webview.navigationDelegate = self
        let dismissButton = UIBarButtonItem(title: "Dismiss", style: .plain, target: self, action: #selector(dismissPopup))
        self.navigationItem.setRightBarButtonItems([dismissButton], animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        webview.frame = view.bounds
    }
    
    @objc func dismissPopup() {
        navigationController?.dismiss(animated: true)
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("link triggered...")
        let url = navigationAction.request.url
        let isDeepLink = Branch.getInstance()?.handleDeepLink(url) ?? false
        decisionHandler(isDeepLink ? WKNavigationActionPolicy.cancel : WKNavigationActionPolicy.allow)
        if (isDeepLink) {
            dismissPopup()
        }
    }
    
}

