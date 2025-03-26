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
    @EnvironmentObject var firebaseService: FirebaseService
    @State var selectedPhotos: [PhotosPickerItem] = []
    @State private var images: [UIImage] = []
    @State var imagesData: [Data] = []
    @State var fileUploadFailedMessage = ""
    @State var showingUploadError = false
    @State var showingSuccess = false
    @State var showingCanNotDownloadImage = false
    @State var showingUploadButton: Bool = false
    @State var showingUploadFolderMissing: Bool = false
    @State var isButtonDisabled: Bool = false
    @State var isUploadButtonDisabled: Bool = true
    @State var progress: Double?
    @State var newPhoto: PhotoInfo = PhotoInfo(userfolder: "", userId: "")
    @State var uploadPhotoCount: Int = 0
    @State var showingAddToFoldersSheet = false
    @State var selectedFolder: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background-grey").edgesIgnoringSafeArea(.all)
                VStack {
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(0..<images.count, id: \.self) { index in
                                Image(uiImage: images[index])
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                            }
                        }
                    }
                    
                    if let progress = progress {
                        ProgressView(value: progress, total: 1) {
                            Text("Uploading photo \(uploadPhotoCount) of \(images.count)")
                        } currentValueLabel: {
                            Text(progress.formatted(.percent.precision(.fractionLength(0))))
                        }
                    }
                    PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 10, matching: .images, photoLibrary: .shared()) {
                        Text("Get a photo from your library")
                            .DefaultTextButtonStyle()
                    }
                    .disabled(isButtonDisabled)
                    if showingUploadButton == true {
                        Button {
                            showingAddToFoldersSheet = true
                        } label: {
                            Text("Upload photo")
                        }
                        .DefaultTextButtonStyle()
                        .disabled(isButtonDisabled)
                    }
                }
                .task(id: selectedPhotos) {
                    var images: [UIImage?] = []
                    var imagesData: [Data?] = []
                    for selectedPhoto in selectedPhotos {
                        let data = try? await selectedPhoto.loadTransferable(type: Data.self)
                        if data != nil, let image = UIImage(data: data!) {
                            images.append(image)
                            imagesData.append(data)
                        } else {
                            imagesData.append(nil)
                            images.append(nil)
                        }
                    }
                    
                    self.images = images.compactMap { $0 }
                    self.imagesData = imagesData.compactMap { $0 }
                    if images.count > 0 {
                        showingUploadButton = true
                    }
                }
                .padding([.leading, .trailing], 20)
            }
            .navigationTitle("Upload Photo")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                isUploadButtonDisabled = true
            }
            .alert("Upload File", isPresented: $showingUploadError) {
                Button("Ok", role: .cancel) {  }
            } message: {
                Text(fileUploadFailedMessage)
            }
            .alert("File Uploaded", isPresented: $showingSuccess) {
                Button("Ok", role: .cancel) {  }
            } message: {
                Text("Succeeded")
            }
            .alert("Image can not be uploaded", isPresented: $showingCanNotDownloadImage ) {
                Button("Ok", role: .cancel) {  }
            } message: {
                Text("Error with image, please select another one.")
            }
            .alert("Please select a folder", isPresented: $showingUploadFolderMissing) {
                Button("Ok", role: .cancel) {  }
            } message: {
                Text("You need to select a folder to upload the photo too. If no folders are present, please create one on the Photos tab.")
            }
            .fullScreenCover(isPresented: $showingAddToFoldersSheet, onDismiss: uploadPhotos) {
                SelectFolderToUpload(selectedFolder: $selectedFolder)
            }
        }
    }
    
    func uploadPhotos() {
        uploadPhotoCount = 1
        if selectedFolder.isEmpty == false {
            if selectedFolder == "" {
                showingUploadFolderMissing = true
                return
            }
            isButtonDisabled = true
            Task {
                guard let user = Auth.auth().currentUser else {
                    return
                }

                do {
                    for imageData in imagesData {
                        newPhoto = PhotoInfo(userfolder: selectedFolder, userId: user.uid)
                        let imageReference = Storage.storage().reference(withPath: "\(user.uid)/\(newPhoto.cloudStoreId).png")
                        
                        let metaData = StorageMetadata()
                        metaData.contentType = "image/png"
                        
                        _ = try await imageReference.putDataAsync(imageData, metadata: metaData) { progress in
                            if let progress {
                                self.progress = progress.fractionCompleted / 2
                            }
                        }
                        newPhoto.imageURL = try await imageReference.downloadURL()
                        let storage = Storage.storage()
                        let path = "\(user.uid)/thumbNails/\(newPhoto.cloudStoreId)_200x200.png"
                        for _ in 1...5 {
                            try await Task.sleep(for: .seconds(1), tolerance: .seconds(1))
                            if progress! < 1 {
                                progress! += 0.1
                            }
                        }
                        let url = try await storage.reference().child(path).downloadURL()
                        newPhoto.thumbnailURL = url
                        await firebaseService.addPhotoToAllPhotos(photo: newPhoto)
                        progress = nil
                        uploadPhotoCount += 1
                    }
                    selectedPhotos = []
                    showingSuccess = true
                    isButtonDisabled = false
                    showingUploadButton = false
                    selectedFolder = ""
                    self.images = []
                    self.imagesData = []
                }
                catch {
                    debugPrint("An error ocurred while uploading: \(error.localizedDescription)")
                }
            }
        }
    }
}

#Preview {
    SelectPhotoView()
}
