//
//  ViewController.swift
//  GiphySharer
//
//  Created by Michael on 07/03/19.
//  Copyright © 2019 Michael. All rights reserved.
//

import UIKit
import GiphyCoreSDK
import GiphyUISDK
import Branch

class MainViewController: UIViewController {
    
    private let table: UITableView
    private var dataSource = [GPHMedia]()
    private var cartButton:UIBarButtonItem!
    private var registerButton: UIBarButtonItem!
    private var cart = [GPHMedia]()
    
    init() {
        table = UITableView(frame: CGRect.zero, style: .plain)
        super.init(nibName: nil, bundle: nil)
        table.dataSource = self
        table.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        table.backgroundColor = .white
        view.addSubview(table)
        GiphyService.shared.trending { [weak self] (media, error) in
            guard let media = media else {
                return
            }
            self?.dataSource.removeAll()
            self?.dataSource += media
            self?.table.reloadData()
        }
        cartButton = UIBarButtonItem(title: "Cart", style: .plain, target: self, action: #selector(viewCart))
//        registerButton = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(register))
        self.navigationItem.setRightBarButtonItems([cartButton], animated: true)
//        self.navigationItem.setLeftBarButtonItems([registerButton], animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        table.frame = view.bounds
    }
    
    @objc func viewCart() {
        let products = self.cart.map { item -> BranchUniversalObject in
            return item.product
        }
        if products.isEmpty {
            return
        }
        // Create a BranchEvent:
        let event = BranchEvent.standardEvent(.addToCart)

        // Add the BranchUniversalObject with the content (do not add an empty branchUniversalObject):
        event.contentItems = NSMutableArray(array: products)

        // Add relevant event data:
        event.alias            = "Add to Basket"
        event.eventDescription = "When the user adds to cart we trigger this event"
        event.customData       = [
            "key1": "value1",
            "key2": "value2"
        ]
        event.logEvent()
    }
    
}

extension MainViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let media = self.dataSource[indexPath.row]
        navigationController?.pushViewController(ImageViewController(giphyID: media.id), animated: true)
    }
}

extension MainViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = GifCell(style: .default, reuseIdentifier: GifCell.reuseIdentifier)
        let media = self.dataSource[indexPath.row]
        cell.delegate = self
        cell.setMedia(media)
        return cell
    }
}

extension MainViewController: GifCellDelegate {
    func addToCart(_ media: GPHMedia?) {
        guard let media = media else {
            return
        }
        self.cart.append(media)
        let event = BranchEvent(name: BranchStandardEvent.addToCart.rawValue)
        event.contentItems = [media.product]
        event.logEvent()
        refreshCart()
    }
    
    private func refreshCart() {
        cartButton.title = "Cart (\(self.cart.count))"
        cartButton.isEnabled = !self.cart.isEmpty
    }
    
    func showShareSheet(for media: GPHMedia?) {
        print("imageID: \(String(describing: media?.id))")
        guard let media = media else {
            return
        }
        let lp: BranchLinkProperties = BranchLinkProperties()
        lp.channel = "app"
        lp.feature = "referral"
        lp.campaign = "app campaign"
        lp.alias = "mgaylord"
        
        lp.addControlParam("$desktop_url", withValue: media.bitlyUrl)
        lp.addControlParam("$android_url", withValue: media.bitlyUrl)
        
        let buo = BranchUniversalObject.init(canonicalIdentifier: media.id)
        buo.title = media.title
        buo.contentDescription = media.description
        buo.imageUrl = media.images?.downsizedStill!.stillGifUrl
        buo.publiclyIndex = true
        buo.locallyIndex = true
        buo.contentMetadata.customMetadata["imageID"] = media.id
        
        buo.showShareSheet(with: lp,
                           andShareText: "Check out this gif",
                           from: self) { (activityType, success) in
                            debugPrint("Shared to: \(String(describing: activityType)) with success: \(success)")
                            if let activityType = activityType, success {
                                let event = BranchEvent.standardEvent(.share)
                                event.eventDescription = String(describing: activityType)
                                event.logEvent()
                            }
        }
        
    }
}

protocol GifCellDelegate : class {
    func showShareSheet(for media: GPHMedia?)
    func addToCart(_ media: GPHMedia?)
}

class GifCell: UITableViewCell {
    static let reuseIdentifier = "GifCell"
    private let gifImage = GPHMediaView(frame: CGRect.zero)
    private let shareButton = UIButton(type: UIButton.ButtonType.infoLight)
    private let addButton = UIButton(type: UIButton.ButtonType.contactAdd)
    private var media: GPHMedia?
    
    weak var delegate: GifCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        addSubview(gifImage)
        addSubview(shareButton)
        addSubview(addButton)
        shareButton.tintColor = .white
        shareButton.addTarget(self, action: #selector(showShareSheet), for: .touchUpInside)
        addButton.tintColor = .white
        addButton.addTarget(self, action: #selector(addToCart), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gifImage.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200)
        shareButton.sizeToFit()
        shareButton.frame = CGRect(
            origin: CGPoint(x: UIScreen.main.bounds.width - shareButton.bounds.size.width - 10, y: 10),
            size: shareButton.frame.size)
        addButton.sizeToFit()
        addButton.frame = CGRect(origin: CGPoint(x: 10, y: 10), size: addButton.frame.size)
    }
    
    func setMedia(_ media: GPHMedia) {
        self.media = media
        gifImage.setMedia(media, rendition: .fixedHeight, shouldQueueOriginalRendition: false)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    @objc func showShareSheet() {
        debugPrint("Show share sheet...")
        self.delegate?.showShareSheet(for: self.media)
    }
    
    @objc func  addToCart() {
        self.delegate?.addToCart(self.media)
    }
}

extension GPHMedia {
    public var product: BranchUniversalObject {
        
        let branchUniversalObject = BranchUniversalObject.init()

        branchUniversalObject.canonicalIdentifier = id
        branchUniversalObject.canonicalUrl        = url
        branchUniversalObject.title               = title ?? "Untitled"

        branchUniversalObject.contentMetadata.contentSchema     = .commerceProduct
        branchUniversalObject.contentMetadata.quantity          = 2
        branchUniversalObject.contentMetadata.price             = NSDecimalNumber(integerLiteral: Int.random(in: 0 ..< 1000))
        branchUniversalObject.contentMetadata.currency          = .USD
        branchUniversalObject.contentMetadata.sku               = "sku_\(id)"
        branchUniversalObject.contentMetadata.productCategory   = .media
        branchUniversalObject.contentMetadata.condition         = .new
        return branchUniversalObject
    }
}
