//
//  VideoPlayerViewController.swift
//  AVPlayer
//
//  Created by Dzmitry Noska on 10/23/19.
//  Copyright © 2019 Dzmitry Noska. All rights reserved.
//

import UIKit



class VideoPodcastsViewController: UITableViewController {

    let VPVC_TITLE: String = "Video Podcasts"
    let TED_TALKS_VIDEO_RESOURCE_URL: String = "https://feeds.feedburner.com/tedtalks_video"
    let VIDEO_CELL_IDENTIFIER: String = "Cell"
    
    private var videoItems: [RSSVideoItem]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = VPVC_TITLE
        fetchData()
        setUpTableView()
        setUpNavigationItem()
    }

    private func fetchData() {
        let feedParser = FeedParser()
        feedParser.parseFeed(url: TED_TALKS_VIDEO_RESOURCE_URL) { (videoItems) in
            self.videoItems = videoItems
            OperationQueue.main.addOperation {
                self.tableView.reloadSections(IndexSet(integer: 0), with: .left)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let videoItems = videoItems else {
            return 0
        }
        return videoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VIDEO_CELL_IDENTIFIER, for: indexPath) as! PodcastTableViewCell
        
        if let item = videoItems?[indexPath.row] {
            cell.item = item
        }
        cell.layoutSubviews()
        return cell
    }
    
    //MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
                videoItems?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetails", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showDetails" {
            let destinationVC: DetailsViewController = segue.destination as! DetailsViewController
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let cell = self.tableView.cellForRow(at: indexPath) {
                    let customCell = cell as? PodcastTableViewCell
                    if let item = customCell!.item {
                        destinationVC.podcastImage = customCell!.videoImageView.image
                        destinationVC.podcastTitle = item.itemTitle
                        destinationVC.podcastDescription = item.itemDescription
                        destinationVC.podcastPubDate = item.itemPubDate
                        destinationVC.podcastDuration = item.itemDuration
                        destinationVC.podcastAuthor = item.itemAuthor
                        destinationVC.podcastURL = item.itemVideoURL
                    }
                }
            }
        }
    }
    
    // Mark: - SetUp's
    
    func setUpTableView() {
        self.tableView.decelerationRate = .normal
        self.tableView.separatorStyle = .none
        self.tableView.register(PodcastTableViewCell.self, forCellReuseIdentifier: VIDEO_CELL_IDENTIFIER)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 200
    }
    
    func setUpNavigationItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshData))
    }
    
    @objc func refreshData() {
        self.videoItems?.removeAll()
        fetchData()
    }
    
}
