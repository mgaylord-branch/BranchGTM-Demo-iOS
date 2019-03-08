//
//  ImageViewController.swift
//  GiphySharer
//
//  Created by Michael on 08/03/19.
//  Copyright © 2019 Michael. All rights reserved.
//

import UIKit
import GiphyCoreSDK
import SwiftyGif

class ImageViewController: UIViewController {
    
    private let imageView = UIImageView(frame: CGRect.zero)
    private let giphyID: String
    
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
        GiphyService.shared.get(byID: giphyID) { [weak self] (media, error) in
            guard let image = media?.images?.downsized?.gifUrl,
                    let url = URL(string: image) else {
                return
            }
            self?.navigationItem.title = media?.title
            self?.imageView.setGifFromURL(url)
        }
        navigationItem.title = "Loading..."
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imageView.bounds = CGRect(origin: CGPoint.zero,
                                  size: CGSize(width: UIScreen.main.bounds.width, height: 200))
        imageView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }
}
