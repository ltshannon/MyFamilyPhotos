//
//  PublicCarouselView.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/22/25.
//

import SwiftUI

struct PublicCarouselView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    var publicFolder: PublicFolderInfo
    @State var photoInfos: [PhotoInfo] = []
    @State private var scrollID: Int?
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 0) {
                        ForEach(0..<photoInfos.count, id: \.self) { index in
                            let sampleImage = photoInfos[index]
                            VStack {
                                AsyncImage(url: sampleImage.imageURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(radius: 10)
                                        .padding()
                                } placeholder: {
                                    ProgressView()
                                }
                                Text(sampleImage.description)
                                    .font(.title)
                            }
                            .containerRelativeFrame(.horizontal)
                            .scrollTransition(.animated, axis: .horizontal) { content, phase in
                                content
                                    .opacity(phase.isIdentity ? 1.0 : 0.6)
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.6)
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $scrollID)
                .scrollTargetBehavior(.paging)
                IndicatorView(imageCount: photoInfos.count, scrollID: $scrollID)
                    .padding([.bottom], 20)
            }
            .navigationTitle("Public Folder: \(publicFolder.name)")
            .onAppear {
                Task {
                    photoInfos = await firebaseService.getPhotosForPublicFolder(name: publicFolder.name)
                }
            }
        }
    }
}

struct IndicatorView: View {
    let imageCount: Int
    @Binding var scrollID: Int?
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<imageCount, id: \.self) { indicator in
                    let index = scrollID ?? 0
                    Button {
                        withAnimation {
                            scrollID = indicator
                        }
                    } label: {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(indicator == index ? Color.white : Color(.lightGray))
                    }
                }
            }
            .padding(7)
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(.lightGray)).opacity(0.2))
        }
    }
}
