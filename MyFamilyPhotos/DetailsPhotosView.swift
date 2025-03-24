//
//  DetailsPhotosView.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/16/25.
//

import SwiftUI

struct DetailsPhotosView: View {
    var item: PhotoInfo
    
    init(parameters: PhotosDetailParameters) {
        item = parameters.item
    }
    
    var body: some View {
        ZStack {
            Color("Background-grey").edgesIgnoringSafeArea(.all)
            VStack {
                AsyncImage(url: item.imageURL) { phase in
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
                .cornerRadius(8.0)
                
                List {
                    Section {
                        Text(item.description)
                    } header: {
                        Text("Description")
                    }
                    Section {
                        ForEach(item.publicFolders, id: \.self) { folder in
                            Text(folder)
                        }
                    } header: {
                        Text("Public Folders")
                    }
                }
            }
            .padding([.leading, .trailing], 20)
        }
    }
}
