//
//  TenorGIF.swift
//  TenorTrialTask
//
//  Created by Vasyl Mytko on 26.06.2022.
//

import Foundation

struct TenorGIF: Decodable {
    struct MediaFormats: Decodable {
        let gif: MediaObject
        struct MediaObject: Decodable {
            let dims: [Int]
        }
    }
    let id: String
    let itemURL: URL
    let mediaFormats: MediaFormats
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.itemURL = try values.decode(URL.self, forKey: .itemURL).appendingPathExtension("gif")
        self.mediaFormats = try values.decode(MediaFormats.self, forKey: .mediaFormats)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case itemURL = "itemurl"
        case mediaFormats = "media_formats"
    }
}

extension TenorGIF {
    func toDomain() -> GIF {
        return .init(
            id: id,
            url: itemURL,
            dimensions: mediaFormats.gif.dims,
            isFavourite: false
        )
    }
}
