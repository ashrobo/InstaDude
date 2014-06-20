//
//  PhotosViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit

class PhotosViewController: UIViewController, MediaFetcherDelegate, UITextFieldDelegate {
    
    @IBOutlet var searchBackground: UIView
    @IBOutlet var collectionView: UICollectionView
    @IBOutlet var searchField: UITextField
    
    var dataSource: MediaItem[] = []
    @lazy var mediaFetcher:MediaFetcher = MediaFetcher(delegate: self)
    var imageCache = NSMutableDictionary()
    @lazy var refreshControl: UIRefreshControl = UIRefreshControl()

    
    override func viewDidLoad() {
        
        mediaFetcher.fetchPopularPhotos()
        searchField.delegate = self
        
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.niceBlue()]
        
        var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight)) as UIVisualEffectView
        visualEffectView.frame = searchBackground.bounds
        visualEffectView.layer.borderWidth = 1.0
        visualEffectView.layer.borderColor = UIColor(red:210.0/255.0, green: 210.0/255.0, blue: 210.0/255.0, alpha: 1.0).CGColor
        searchBackground.insertSubview(visualEffectView, belowSubview: searchField)
        
        searchBackground.backgroundColor = UIColor.clearColor()
        
        refreshControl.tintColor = UIColor.grayColor()
        refreshControl.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        collectionView.alwaysBounceVertical = true
        collectionView.insertSubview(refreshControl, aboveSubview: collectionView)
        
        self.extendedLayoutIncludesOpaqueBars = true
        
        collectionView.contentInset = UIEdgeInsetsMake(48, 0, 0, 0)
    }
    
    override func viewWillAppear(animated: Bool) {
            mediaFetcher.delegate = self
    }
    
    func didFetchMediaItems(items: NSArray) {
        
        dataSource.removeAll(keepCapacity: true)
        refreshControl.endRefreshing()
        
        for item: AnyObject in items {
            var newItem: MediaItem = MediaItem(item: item as NSDictionary)
            dataSource.append(newItem)
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.reloadData()
        })
    }
    
    
    func didFailToFetchMediaItems(error: NSError) {
        
    }

    func collectionView(collectionView: UICollectionView!, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView!, cellForItemAtIndexPath indexPath: NSIndexPath!) -> UICollectionViewCell! {
        
        var mediaCell = collectionView.dequeueReusableCellWithReuseIdentifier("MediaCell", forIndexPath: indexPath) as MediaCell
        var mediaItem = dataSource[indexPath.item]
        
        let urlString = mediaItem.thumbnailURL
        var image: UIImage? = self.imageCache.valueForKey(urlString) as? UIImage
        
        if ( !image? ) {
            var imgURL: NSURL = NSURL(string: urlString)
            
            var request: NSURLRequest = NSURLRequest(URL: imgURL)
            var urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
                    if !error? {
                        image = UIImage(data: data)
                        
                        self.imageCache[urlString!] = image
                        
                        if let albumCell: UICollectionViewCell? = collectionView.cellForItemAtIndexPath(indexPath) {
                            self.animateImage(image!, intoImageView: mediaCell.imageView)
                        }
                    } else {
                        NSLog(error.localizedDescription)
                    }
                })
        } else {
            animateImage(image!, intoImageView: mediaCell.imageView)
        }
        
        if mediaItem.mediaType != "video" {
            mediaCell.videoImageView.hidden = true
        }
        
        return mediaCell
    }
    
    func animateImage(image: UIImage, intoImageView imageView:UIImageView) {
        
        UIView.animateWithDuration(0.3, animations: {
            imageView.alpha = 0
            imageView.image = image
            imageView.alpha = 1
        })
    }
    
    @IBAction func refresh() {
        mediaFetcher.refresh()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if segue.identifier == "showMedia" {
            if segue.destinationViewController is MediaItemViewController {
                let mediaVC = segue.destinationViewController as MediaItemViewController
                if sender is UICollectionViewCell {
                    let cell = sender as UICollectionViewCell
                    let row = collectionView.indexPathForCell(cell).row
                    
                    mediaVC.mediaItem = dataSource[row] as MediaItem
                    mediaVC.mediaFetcher = self.mediaFetcher
                }
            }
        }
    }
    
    @IBAction func finishedEditing(sender : UITextField) {
        sender.resignFirstResponder()
        
        let length = sender.text.utf16count
        if length > 0 {
            mediaFetcher.searchForItemsByTag(sender.text)
        }
    }
    
    func textFieldShouldReturn(sender: UITextField) -> Bool {
        sender.resignFirstResponder()
        return true
    }
    
}