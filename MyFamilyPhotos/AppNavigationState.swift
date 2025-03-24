//
//  AppNavigationState.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/15/25.
//

import Foundation

struct PhotosDetailParameters: Identifiable, Hashable, Encodable {
    var id = UUID().uuidString
    var item: PhotoInfo
}

struct PhotosIsPublicParameters: Identifiable, Hashable, Encodable {
    var id = UUID().uuidString
    var item: PhotoInfo
}

enum PhotosNavDestination: Hashable {
    case photosDetailView(PhotosDetailParameters)
}

class AppNavigationState: ObservableObject {
    @Published var photosNavigation: [PhotosNavDestination] = []
    
    func photosDetailView(parameters: PhotosDetailParameters) {
        photosNavigation.append(PhotosNavDestination.photosDetailView(parameters))
    }
    
}
