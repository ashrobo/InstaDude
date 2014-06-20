//
//  PhotoFetcher.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation
import UIKit

@objc protocol MediaFetcherDelegate {
    @optional func didFetchMediaItems(items: NSArray)
    @optional func didFailToFetchMediaItems(error: NSError)
    
    @optional func didFetchImage(image: UIImage, tag: String)
    @optional func didFailToFetchImage(error: NSError)
}

class MediaFetcher {
    
    let baseURL = "https://api.instagram.com/v1/"
    let popularEndpoint = "media/popular"
    let clientID = "YOUR_ID"
    
    var lastSearchURL: String?
    
    var delegate: MediaFetcherDelegate?

    init(delegate:MediaFetcherDelegate){
        self.delegate = delegate
    }
    
    func get(path: String) {
        let url = NSURL(string: path)
        lastSearchURL = path
        NSLog("Base URL is %@", url)
        
        var session = NSURLSession.sharedSession()
        var task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
            println("Task completed")
            if(error) {
                self.delegate?.didFailToFetchMediaItems?(error!)
            }
            
            var err: NSError?
            var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
            if(err?) {
                self.delegate?.didFailToFetchMediaItems?(err!)
            }
            
            var results: NSArray = jsonResult["data"] as NSArray
            self.delegate?.didFetchMediaItems?(results)
            })
        
        task.resume()
    }
    
    func fetchImageAtURL(imageURL: NSString, forTag tag: String) {
        
        var url = NSURL.URLWithString(imageURL)
        var request: NSURLRequest = NSURLRequest(URL: url?)
        var urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if !error? {
                let image: UIImage = UIImage(data: data)
                self.delegate?.didFetchImage?(image, tag: tag)
                
            } else {
               self.delegate?.didFailToFetchImage?(error)
            }
        })
    }
    
    func fetchPopularPhotos() {
        get("\(baseURL)\(popularEndpoint)?client_id=\(clientID)&count=18")
    }
    
    func searchForItemsByTag(tag: String){
        get("\(baseURL)/tags/\(tag)/media/recent?client_id=\(clientID)&count=18")
    }
    
    
    func refresh() {
        if let url = lastSearchURL {
            get(url)
        }
    }
    
}