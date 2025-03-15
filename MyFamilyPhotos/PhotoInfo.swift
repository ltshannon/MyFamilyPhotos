//
//  PhotoInfo.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/14/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct PhotoInfo: Codable, Identifiable {
    @DocumentID var id: String?
    var cloudStoreId = UUID().uuidString
    var isPublic: Bool = false
    var imageURL: URL?
    var thumbnailURL: URL?
    var videoURL: URL?
    var userId: String
}
