//
//  MediaItemViewController.swift
//  InstaDude
//
//  Created by Ashley Robinson on 20/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import MediaPlayer

enum ImageType: String {
    case MainImage = "Main Image"
    case ProfileImage = "Profile Image"
}

extension UIColor {
    
    class func niceBlue() -> UIColor {
        return UIColor(red: 25.0/255.0, green: 80.0/255.0, blue: 123.0/255.0, alpha: 1)
    }
}

class MediaItemViewController: UIViewController, MediaFetcherDelegate {
    
    var mediaItem: MediaItem?
    var mediaFetcher: MediaFetcher?
    @lazy var mediaPlayerController: MPMoviePlayerController = MPMoviePlayerController()
    
    @IBOutlet var profilePicture : UIImageView
    @IBOutlet var usernameLabel : UILabel
    @IBOutlet var imageView : UIImageView
    @IBOutlet var likesLabel : UILabel
    @IBOutlet var tagsLabel : UILabel
    @IBOutlet var spinner : UIActivityIndicatorView
    @IBOutlet var scrollView : UIScrollView
    @IBOutlet var container : UIView
    
    override func viewDidLoad() {
        
        spinner.startAnimating()
        mediaFetcher!.delegate = self
        scrollView.contentSize  = CGSizeMake(view.frame.size.width, 2000)
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.niceBlue()]

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "mediaReady:", name: MPMoviePlayerReadyForDisplayDidChangeNotification, object: nil)
        
        if let item: MediaItem = mediaItem {
            
            mediaFetcher?.fetchImageAtURL(item.profilePictureURL!, forTag: ImageType.ProfileImage.toRaw())
            
            if item.mediaType == "image" {
                title = "Photo"
                mediaFetcher?.fetchImageAtURL(item.sourceURL!, forTag: ImageType.MainImage.toRaw())
            } else {
                title = "Video"
                imageView.alpha = 0
                playClipAtURL(item.sourceURL!)
            }
            
            usernameLabel.text = item.username
            likesLabel.text = "\(item.likes) likes"
            var tagString = ""
            
            if let tagsArray = item.tags {
                var nsArray = tagsArray.bridgeToObjectiveC()
                tagString = nsArray.componentsJoinedByString(", ")
            }
            
            tagsLabel.text = tagString
        }
        
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width/2
    }
    
    func playClipAtURL(urlString: String){
        
        var url = NSURL.URLWithString(urlString)
        mediaPlayerController.contentURL = url
         mediaPlayerController.prepareToPlay()
        mediaPlayerController.view.frame = imageView.frame
        mediaPlayerController.movieSourceType = .File
        mediaPlayerController.view.alpha = 0
        
        container.addSubview(mediaPlayerController.view)
        mediaPlayerController.play()
    }
    
    func didFetchImage(image: UIImage, tag: String) {
        switch tag {
            
            case ImageType.MainImage.toRaw():
                imageView.image = image
                self.spinner.stopAnimating()
                
            case ImageType.ProfileImage.toRaw():
                profilePicture.image = image
                
            default:
                NSLog("Tag not recognised")
            }

    }
    
    func didFailToFetchImage(error: NSError) {
        self.spinner.stopAnimating()
    }
    
    func mediaReady(note: NSNotification) {
        mediaPlayerController.view.alpha = 1
        spinner.stopAnimating()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}