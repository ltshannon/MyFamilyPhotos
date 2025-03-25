//
//  PublicTabCarouselView.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/24/25.
//

import SwiftUI

struct PublicTabCarouselView: View {
    @EnvironmentObject var firebaseService: FirebaseService
    @EnvironmentObject var settingsService: SettingsService
    @Environment(\.dismiss) var dismiss
    var publicFolder: PublicFolderInfo
    @State var photoInfos: [PhotoInfo] = []
    @State var currentPage = 0
    @State var timer = Timer.publish(every: 0, on: .main, in: .common).autoconnect()
    
    init(parameters: PublicPhotosTabCarouselParameters) {
        publicFolder = parameters.item
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentPage) {
                ForEach(0..<photoInfos.count, id: \.self) { index in
                    VStack {
                        AsyncImage(url: photoInfos[index].imageURL) { image in
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
                        Text(photoInfos[index].description)
                            .font(.title)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
//            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .onReceive(timer, perform: { _ in
                currentPage = (currentPage + 1) % photoInfos.count
            })
            .onAppear {
                timer = Timer.publish(every: TimeInterval(settingsService.timerInterval.rawValue), on: .main, in: .common).autoconnect()
                Task {
                    photoInfos = await firebaseService.getPhotosForPublicFolder(name: publicFolder.name)
                }
            }
        }
    }
}
