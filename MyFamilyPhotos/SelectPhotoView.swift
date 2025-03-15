//
//  SelectPhotoView.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/14/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import PhotosUI

struct SelectPhotoView: View {
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var fileUploadFailedMessage = ""
    @State private var showUploadError = false
    @State private var showSuccess = false
    @State var progress: Double?
    @State private var image: Image? = Image(systemName: "photo.artframe")
    @State var imageData: Data?
    private var db = Firestore.firestore()
    
    var body: some View {
        VStack {
            image?
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, alignment: .center)
                .cornerRadius(8.0)

            if let progress = progress {
                ProgressView(value: progress, total: 1) {
                    Text("Uploading...")
                } currentValueLabel: {
                    Text(progress.formatted(.percent.precision(.fractionLength(0))))
                }
            }
            PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                Text("Get a photo from your library")
                    .DefaultTextButtonStyle()
            }
            Button {
                guard let imageData else { return }
                Task {
                    guard let user = Auth.auth().currentUser else {
                        return
                    }
                    var selectPhoto = PhotoInfo(userId: user.uid)
                    let imageReference = Storage.storage().reference(withPath: "\(user.uid)/\(selectPhoto.cloudStoreId).png")
                    
                    let metaData = StorageMetadata()
                    metaData.contentType = "image/png"
                    
                    do {
                        let resultMetaData = try await imageReference.putDataAsync(imageData, metadata: metaData) { progress in
                            if let progress {
                                self.progress = progress.fractionCompleted
                                if progress.isFinished {
                                    self.progress = nil
                                }
                            }
                        }
                        debugPrint("Upload finished.")
                        showSuccess = true
                        selectPhoto.imageURL = try await imageReference.downloadURL()
                        let imageReference = Storage.storage().reference(withPath: "\(user.uid)/thumbNails/\(selectPhoto.cloudStoreId)_200x200.png")
                        let storage = Storage.storage()
                        let path = "\(user.uid)/thumbNails/\(selectPhoto.cloudStoreId)_200x200.png"
                        try await Task.sleep(for: .seconds(5), tolerance: .seconds(5))
                        let url = try await storage.reference().child(path).downloadURL()
                        selectPhoto.thumbnailURL = url
                        let documentReference = try db.collection("userPhotos").document(user.uid).collection("photos").addDocument(from: selectPhoto)
                    }
                    catch {
                        debugPrint("An error ocurred while uploading: \(error.localizedDescription)")
                    }
                    self.imageData = nil
                }
            } label: {
                Text("Upload photo")
            }
                .DefaultTextButtonStyle()
        }
        .task(id: selectedPhoto) {
            let data = try? await selectedPhoto?.loadTransferable(type: Data.self)
            if let imageData = data, let uiImage = UIImage(data: imageData) {
                image = Image(uiImage: uiImage)
                
            }
            imageData = data
        }
        .alert("Upload File", isPresented: $showUploadError) {
            Button("Ok", role: .cancel) {  }
        } message: {
            Text(fileUploadFailedMessage)
        }
        .alert("File Uploaded", isPresented: $showSuccess) {
            Button("Ok", role: .cancel) {  }
        } message: {
            Text("Succeeded")
        }
    }
}

#Preview {
    SelectPhotoView()
}
