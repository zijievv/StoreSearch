//
//  SearchResult.swift
//  StoreSearch
//
//  Created by zijie vv on 13/04/2019.
//  Copyright © 2019 zijie vv. All rights reserved.
//

import Foundation


private let typeForKind = [
    "album": NSLocalizedString("Album", comment: "Localized kind: Album"),
    "audiobook": NSLocalizedString("Audio Book",
                                   comment: "Localized kind: Audio Book"),
    "book": NSLocalizedString("Book", comment: "Localized kind: Book"),
    "ebook": NSLocalizedString("E-Book", comment: "Localized kind: E-Book"),
    "feature-movie": NSLocalizedString("Movie", comment: "Localized kind: Movie"),
    "music-video": NSLocalizedString("Music Video",
                                     comment: "Localized kind: Music Video"),
    "podcast": NSLocalizedString("Podcast", comment: "Localized kind: Podcast"),
    "software": NSLocalizedString("App", comment: "Localized kind: Software"),
    "song": NSLocalizedString("Song", comment: "Localized kind: Song"),
    "tv-episode": NSLocalizedString("TV Episode",
                                    comment: "Localized kind: TV Episode")
]

class ResultArray: Codable {
    var resultCount = 0
    var results = [SearchResult]()
}

func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
    return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}

class SearchResult: Codable, CustomStringConvertible {
    var artistName: String? = ""
    var trackName: String? = ""
    var kind: String? = ""
    var trackPrice: Double? = 0.0
    var currency = ""
    var imageSmall = ""
    var imageLarge = ""
    var trackViewUrl: String?
    var collectionName: String?
    var collectionViewUrl: String?
    var collectionPrice: Double?
    var itemPrice: Double?
    var itemGenre: String?
    var bookGenre: [String]?
    
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
        case itemPrice = "price"
        case kind, artistName, currency
        case trackName, trackPrice, trackViewUrl
        case collectionName, collectionViewUrl, collectionPrice
    }
    
    var name: String {
        return trackName ?? collectionName ?? ""
    }
    
    var storeURL: String {
        return trackViewUrl ?? collectionViewUrl ?? ""
    }
    
    var price: Double {
        return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
    }
    
    var genre: String {
        if let genre = itemGenre {
            return genre
        } else if let genres = bookGenre {
            return genres.joined(separator: ", ")
        }
        return ""
    }
    
    var type: String {
        let kind = self.kind ?? "audiobook"
        return typeForKind[kind] ?? kind
    }
    
//    var type: String {
//        let kind = self.kind ?? "audiobook"
//
//        switch kind {
//        case "album":
//            return NSLocalizedString("Album", comment: "Localized kind: Album")
//        case "audiobook":
//            return NSLocalizedString("Audio Book",
//                                     comment: "Localized kind: Audio Book")
//        case "book":
//            return NSLocalizedString("Book", comment: "Localized kind: Book")
//        case "ebook":
//            return NSLocalizedString("E-Book", comment: "Localized kind: E-Book")
//        case "feature-movie":
//            return NSLocalizedString("Movie", comment: "Localized kind: Feature Movie")
//        case "music-video":
//            return NSLocalizedString("Music Video", comment: "Localized kind: Music Video")
//        case "podcast":
//            return NSLocalizedString("Podcast", comment: "Localized kind: Podcast")
//        case "software":
//            return NSLocalizedString("App", comment: "Localized kind: Software")
//        case "song":
//            return NSLocalizedString("Song", comment: "Localized kind: Song")
//        case "tv-episode":
//            return NSLocalizedString("TV Episode", comment: "Localized kind: TV Episode")
//        default:
//            return kind
//        }
//    }
    
    var artist: String {
        return artistName ?? ""
    }
    
    var description: String {
        return "Kind: \(kind ?? "None"), Name: \(name), Artist Name: \(artistName ?? "None")\n"
    }
}


