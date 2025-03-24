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
    @State var selectedPhoto: PhotosPickerItem? = nil
    @State var fileUploadFailedMessage = ""
    @State var showingUploadError = false
    @State var showingSuccess = false
    @State var showingCanNotDownloadImage = false
    @State var showingUploadButton: Bool = false
    @State var showingUploadFolderMissing: Bool = false
    @State var isButtonDisabled: Bool = false
    @State var progress: Double?
    @State private var image: Image? = Image(systemName: "photo.artframe")
    @State var imageData: Data?
    @State var newPhoto: PhotoInfo = PhotoInfo(userfolder: "", userId: "")
    @State var showingAddToFoldersSheet = false
    @State var selectedFolder: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background-grey").edgesIgnoringSafeArea(.all)
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
                    .disabled(isButtonDisabled)
                    if showingUploadButton == true {
                        List {
                            Section(header: Text("Select a folder to upload to:")) {
                                ForEach(firebaseService.userFolderNames, id: \.self) { folderName in
                                    HStack {
                                        Text(folderName)
                                        Spacer()
                                        Image(systemName: selectedFolder == folderName ? "checkmark.circle.fill" : "circle")
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedFolder = folderName
                                    }
                                }
                            }
                        }
                        Button {
                            if selectedFolder == "" {
                                showingUploadFolderMissing = true
                                return
                            }
                            guard let imageData else { return }
                            isButtonDisabled = true
                            Task {
                                guard let user = Auth.auth().currentUser else {
                                    return
                                }
                                newPhoto = PhotoInfo(userfolder: selectedFolder, userId: user.uid)
                                let imageReference = Storage.storage().reference(withPath: "\(user.uid)/\(newPhoto.cloudStoreId).png")
                                
                                let metaData = StorageMetadata()
                                metaData.contentType = "image/png"
                                
                                do {
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
                                    image = Image(systemName: "photo.artframe")
                                    progress = nil
                                    selectedPhoto = nil
                                    showingSuccess = true
                                    isButtonDisabled = false
                                    showingUploadButton = false
                                    selectedFolder = ""
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
                        .disabled(isButtonDisabled)
                        Spacer()
                    }
                }
                .task(id: selectedPhoto) {
                    if selectedPhoto != nil {
                        let data = try? await selectedPhoto?.loadTransferable(type: Data.self)
                        if data == nil {
                            showingCanNotDownloadImage = true
                            return
                        }
                        if let imageData = data, let uiImage = UIImage(data: imageData) {
                            image = Image(uiImage: uiImage)
                        }
                        imageData = data
                        showingUploadButton = true
                    }
                }
                .padding([.leading, .trailing], 20)
            }
            .navigationTitle("Upload Photo")
            .navigationBarTitleDisplayMode(.inline)
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
            .fullScreenCover(isPresented: $showingAddToFoldersSheet) {
                
            }
        }
    }
}

#Preview {
    SelectPhotoView()
}
