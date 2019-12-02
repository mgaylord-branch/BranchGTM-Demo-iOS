//
//  ImageViewController.swift
//  GiphySharer
//
//  Created by Michael on 08/03/19.
//  Copyright © 2019 Michael. All rights reserved.
//

import UIKit
import GiphyCoreSDK
import GiphyUISDK
import Branch

class ImageViewController: UIViewController {
    
    private let imageView = GPHMediaView(frame: CGRect.zero)
    private let giphyID: String
    private var media: GPHMedia?
    
    init(giphyID: String) {
        self.giphyID = giphyID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        view.backgroundColor = .white
        let button = UIBarButtonItem(title: "Purchase", style: .plain, target: self, action: #selector(purchase))
        let webButton = UIBarButtonItem(title: "Show Web", style: .plain, target: self, action: #selector(showWeb))
        if #available(iOS 13.0, *) {
            let backButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(back))
            self.navigationItem.setLeftBarButtonItems([backButton, webButton], animated: true)
        } else {
            self.navigationItem.setLeftBarButtonItems([webButton], animated: true)
        }
        self.navigationItem.setRightBarButtonItems([button], animated: true)
        GiphyService.shared.get(byID: giphyID) { [weak self] (media, error) in
            self?.navigationItem.title = media?.title
            self?.media = media
        }
        imageView.setMediaWithID(giphyID, rendition: .fixedHeight)
        navigationItem.title = "Loading..."
        BranchEvent.standardEvent(.viewItem).logEvent()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imageView.bounds = CGRect(origin: CGPoint.zero,
                                  size: CGSize(width: UIScreen.main.bounds.width, height: 200))
        imageView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }
    
    
    @objc func purchase() {
        let event = BranchEvent.standardEvent(.purchase)
        
        // Add the BranchUniversalObjects with the content:
        // Add relevant event data:
        event.transactionID    = "928734747"
        event.currency         = .USD
        event.revenue          = 3434
        event.shipping         = 10.2
        event.tax              = 12.3
        event.coupon           = "test_coupon"
        event.affiliation      = "test_affiliation"
        event.eventDescription = "Event_description"
        event.searchQuery      = "item 123"
        if let product = media?.product {
            event.contentItems = [product]
        }
        event.logEvent() // Log the event.
    }
    
    @objc func showWeb() {
        let webview = WebviewController(url: URL(string: "https://deeplinkeverything.firebaseapp.com/webview.html")!)
        let popupNav = UINavigationController(rootViewController: webview)
        navigationController?.present(popupNav, animated: true)
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }

}
