//
//  ViewController.swift
//  GiphySharer
//
//  Created by Michael on 07/03/19.
//  Copyright © 2019 Michael. All rights reserved.
//

import UIKit
import GiphyCoreSDK
import SwiftyGif
import Branch

class MainViewController: UIViewController {
    
    private let table: UITableView
    private var dataSource = [GPHMedia]()
    
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
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        table.frame = view.bounds
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
    func showShareSheet(for media: GPHMedia?) {
        guard let media = media else {
            return
        }
        let lp: BranchLinkProperties = BranchLinkProperties()
        lp.channel = "app"
        lp.feature = "sharing"
        lp.campaign = "app campaign"
        
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
        }
    }
}

protocol GifCellDelegate : class {
    func showShareSheet(for media: GPHMedia?)
}

class GifCell: UITableViewCell {
    static let reuseIdentifier = "GifCell"
    private let gifImage = UIImageView(frame: CGRect.zero)
    private let shareButton = UIButton(type: UIButton.ButtonType.infoLight)
    private var media: GPHMedia?
    
    weak var delegate: GifCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        addSubview(gifImage)
        addSubview(shareButton)
        shareButton.tintColor = .white
        shareButton.addTarget(self, action: #selector(showShareSheet), for: .touchUpInside)
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
    }
    
    func setMedia(_ media: GPHMedia) {
        self.media = media
        guard let url = media.images?.fixedHeight?.gifUrl else {
            return
        }
        gifImage.setGifFromURL(URL(string: url)!)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        gifImage.stopAnimating()
        gifImage.clear()
    }
    
    @objc func showShareSheet() {
        debugPrint("Show share sheet...")
        self.delegate?.showShareSheet(for: self.media)
    }
}
