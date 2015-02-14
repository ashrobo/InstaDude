//
//  Photo.swift
//  InstaDude
//
//  Created by Ashley Robinson on 19/06/2014.
//  Copyright (c) 2014 Ashley Robinson. All rights reserved.
//

import Foundation

class MediaItem {
    
    var itemID: String?
    var username: String?
    var thumbnailURL: String?
    var mediaType: String?
    var tags: [String]?
    var sourceURL: String?
    var profilePictureURL: String?
    var likes: Int?
    
    init(item: NSDictionary){
        
        itemID = item.valueForKeyPath("user.id") as? String
        username = item.valueForKeyPath("user.username") as? String
        thumbnailURL = item.valueForKeyPath("images.thumbnail.url") as? String
        mediaType = item["type"] as? String
        if mediaType == "image" {
            sourceURL = item.valueForKeyPath("images.standard_resolution.url") as? String
        } else {
            sourceURL = item.valueForKeyPath("videos.standard_resolution.url") as? String
        }
        tags = item["tags"] as? [String]
        profilePictureURL = item.valueForKeyPath("user.profile_picture") as? String
        likes = item.valueForKeyPath("likes.count") as? Int
       
        NSLog("\(username), \(itemID), \(mediaType), \(sourceURL), \(tags), \(likes)")
    }
}