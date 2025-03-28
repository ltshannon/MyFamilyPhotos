//
//  PublicFoldersDetailView.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/17/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct PublicFoldersDetailView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    var publicFolder: PublicFolderInfo
    @State var photoInfos: [PhotoInfo] = []
    let database = Firestore.firestore()
    
    var body: some View {
        List {
            ForEach(photoInfos, id: \.id) { item in
                HStack {
                    AsyncImage(url: item.thumbnailURL) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                        } else if phase.error != nil {
                            Color.red
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                        }
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 75)
                    .cornerRadius(8.0)
                    Text(item.description)
                }
                .contentShape(Rectangle())
//                .swipeActions(allowsFullSwipe: false) {
//                    Button {
//                        selectedItem = item
//                        newDescription = item.description
//                        showingEditDescriptionAlert = true
//                    } label: {
//                        Text("Edit Description")
//                    }
//                    .tint(.indigo)
//                    Button(role: .destructive) {
//                        selectedItem = item
//                        showingDeleteAlert = true
//                    } label: {
//                        Label("Delete", systemImage: "trash.fill")
//                    }
//                }
//                .onTapGesture {
//                    let parameters = PhotosDetailParameters(item: item)
//                    appNavigationState.photosDetailView(parameters: parameters)
//                }
            }
        }
        .navigationTitle("Public Folder: \(publicFolder.name)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                photoInfos = await firebaseService.getPhotosForPublicFolder(name: publicFolder.name)
            }
        }
    }
    
}
