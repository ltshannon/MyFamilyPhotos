//
//  DisplayPhotoView.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/14/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct DisplayPhotoView: View {
    @State var photosListener: ListenerRegistration?
    @State var photoInfos: [PhotoInfo] = []
    @State var firstTime = true
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(photoInfos, id: \.id) { item in
                    AsyncImage(url: item.thumbnailURL) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                        } else if phase.error != nil {
                            Color.red
                        } else {
                            Image(systemName: "photo.artframe")
                                .resizable()
                        }
                    }
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50, alignment: .leading)
                    .cornerRadius(8.0)
                    Divider()
                }
            }
            .padding([.leading, .trailing], 20.0)
        }
        .onAppear {
            if firstTime == true {
                Task {
                    await listenerForUserPhotos()
                }
            }
        }
    }
    
    func listenerForUserPhotos() async {
        let database = Firestore.firestore()

        guard let user = Auth.auth().currentUser else {
            return
        }
        
        var uid = user.uid
        
        let listener = database.collection("userPhotos").document(uid).collection("photos").addSnapshotListener({ querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                debugPrint("🧨", "Error listenerForUserPhotos: \(error!)")
                return
            }
            var results: [PhotoInfo] = []
            do {
                for document in documents {
                    let data = try document.data(as: PhotoInfo.self)
                    results.append(data)
                }
                
                DispatchQueue.main.async {
                    self.photoInfos = results
                    debugPrint("count: \(results.count)")
                }
            }
            catch {
                debugPrint("🧨", "Error reading listenerForUserPhotos: \(error.localizedDescription)")
            }

        })

        self.photosListener = listener

    }
}

#Preview {
    DisplayPhotoView()
}
