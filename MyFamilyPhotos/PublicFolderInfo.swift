//
//  PublicFolderInfo.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/17/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct PublicFolderInfo: Codable, Identifiable, Equatable, Hashable {
    @DocumentID var id: String?
    var name: String = ""
    var count: Int?
    var ownerId: String
}
