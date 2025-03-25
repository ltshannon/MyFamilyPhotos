//
//  PublicFolders.swift
//  MyFamilyPhotos
//
//  Created by Larry Shannon on 3/17/25.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct PublicFoldersView: View {
    @EnvironmentObject var appNavigationState: AppNavigationState
    @EnvironmentObject var firebaseService: FirebaseService
    @EnvironmentObject var settingsService: SettingsService
    @State var selectedItem: PublicFolderInfo = PublicFolderInfo(name: "", ownerId: "")
    @State var showingGetNameAlert = false
    @State var showingNameEmptyAlert = false
    @State var showingErrorAlert: Bool = false
    @State var showingDeleteAlert = false
    @State var showingEditDescriptionAlert = false
    @State var showingFullScreenCover = false
    @State var newFolderName: String = ""
    @State var errorString: String = ""
    @State var newName = ""
    let database = Firestore.firestore()
    
    var body: some View {
        NavigationStack(path: $appNavigationState.photosPublicNavigation) {
            List {
                ForEach(firebaseService.publicFolderInfos, id: \.id) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if settingsService.carouseAutomaticDisplayState == true {
                            selectedItem = item
                            showingFullScreenCover = true
                        }
                        else {
                            let parameters = PublicPhotosCarouselParameters(item: item)
                            appNavigationState.publicPhotosCarouselView(parameters: parameters)
                        }
                    }
                    .swipeActions(allowsFullSwipe: false) {
                        if item.ownerId == Auth.auth().currentUser!.uid {
                            Button(role: .destructive) {
                                selectedItem = item
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                            Button {
                                selectedItem = item
                                newName = item.name
                                showingEditDescriptionAlert = true
                            } label: {
                                Text("Edit Description")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Public Photos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingGetNameAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.app")
                                .resizable()
                                .scaledToFit()
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            settingsService.toggleCarouseAutomaticDisplay()
                        } label: {
                            Label("Automatic Display Photos", systemImage: settingsService.carouseAutomaticDisplayState == true ? "checkmark.circle" : "circle")
                        }
                        Menu("Time interval") {
                            Button {
                                settingsService.setTimerInterval(timerInterval: TimerInterval.twoSeconds)
                            } label: {
                                Label("\(TimerInterval.twoSeconds.rawValue) Seconds", systemImage: settingsService.timerInterval == TimerInterval.twoSeconds ? "checkmark.circle" : "circle")
                            }
                            Button {
                                settingsService.setTimerInterval(timerInterval: TimerInterval.fiveSeconds)
                            } label: {
                                Label("\(TimerInterval.fiveSeconds.rawValue) Seconds", systemImage: settingsService.timerInterval == TimerInterval.fiveSeconds ? "checkmark.circle" : "circle")
                            }
                            Button {
                                settingsService.setTimerInterval(timerInterval: TimerInterval.tenSeconds)
                            } label: {
                                Label("\(TimerInterval.tenSeconds.rawValue) Seconds", systemImage: settingsService.timerInterval == TimerInterval.tenSeconds ? "checkmark.circle" : "circle")
                            }
                        }
                        Button {
                            
                        } label: {
                            Text("Cancel")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .navigationDestination(for: PublicPhotosNavDestination.self) { state in
                switch state {
                case .publicPhotosTabCarouselView(let parameters):
                    PublicTabCarouselView(parameters: parameters)
                case .publicPhotosCarouselView(let parameters):
                    PublicCarouselView(parameters: parameters)
                }
            }
            .fullScreenCover(isPresented: $showingFullScreenCover) {
                let parameters = PublicPhotosTabCarouselParameters(item: selectedItem)
                PublicTabCarouselView(parameters: parameters)
            }
            .alert("Name of Public Folder", isPresented: $showingGetNameAlert) {
                TextField("", text: $newFolderName)
                    .keyboardType(.default)
                Button("OK") {
                    if newFolderName.isEmpty == true {
                        showingNameEmptyAlert = true
                        return
                    }
                    Task {
                        if let error = await firebaseService.createFolder(name: newFolderName, folderName: "publicFolders", isPublic: true) {
                            errorString = error
                            showingErrorAlert = true
                        }
                        newFolderName = ""
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter a name")
            }
            .alert("You need to add a name", isPresented: $showingNameEmptyAlert) {
                Button("Cancel", role: .cancel) {
                    showingGetNameAlert = true
                }
            }
            .alert(errorString, isPresented: $showingErrorAlert) {
                Button("Cancel", role: .cancel) { }
            }
            .alert("Are you sure you want to delete this?", isPresented: $showingDeleteAlert) {
                Button("OK", role: .destructive) {
                    Task {
                        await firebaseService.deleteFolder(item: selectedItem)
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .alert("Edit Description", isPresented: $showingEditDescriptionAlert) {
                TextField(selectedItem.name, text: $newName)
                    .keyboardType(.default)
                Button("OK") {
                    Task {
                        if let error = await firebaseService.editFolderDescription(item: selectedItem, newName: newName) {
                            errorString = error
                            showingErrorAlert = true
                        }
                        newName = ""
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter a new description")
            }
        }
    }
    
}

