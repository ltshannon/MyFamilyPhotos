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

struct PublicPhotosCarouselParameters: Identifiable, Hashable, Encodable {
    var id = UUID().uuidString
    var item: PublicFolderInfo
}

struct PublicPhotosTabCarouselParameters: Identifiable, Hashable, Encodable {
    var id = UUID().uuidString
    var item: PublicFolderInfo
}

enum PublicPhotosNavDestination: Hashable {
    case publicPhotosTabCarouselView(PublicPhotosTabCarouselParameters)
    case publicPhotosCarouselView(PublicPhotosCarouselParameters)
}

class AppNavigationState: ObservableObject {
    @Published var photosNavigation: [PhotosNavDestination] = []
    @Published var photosPublicNavigation: [PublicPhotosNavDestination] = []
    
    func photosDetailView(parameters: PhotosDetailParameters) {
        photosNavigation.append(PhotosNavDestination.photosDetailView(parameters))
    }
    
    func publicPhotosCarouselView(parameters: PublicPhotosCarouselParameters) {
        photosPublicNavigation.append(PublicPhotosNavDestination.publicPhotosCarouselView(parameters))
    }
    
    func publicPhotosTabCarouselView(parameters: PublicPhotosTabCarouselParameters) {
        photosPublicNavigation.append(PublicPhotosNavDestination.publicPhotosTabCarouselView(parameters))
    }
}
