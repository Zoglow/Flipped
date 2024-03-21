//
//  SaveAnimationPopup.swift
//  Flipped
//
//  Created by Zoe Olson on 3/21/24.
//

import SwiftUI
import Photos
import PencilKit
import GIFFromImages
import RealmSwift

struct SaveAnimationPopup: View {
    
    @ObservedRealmObject var animation: Animation
    @Binding var showSavePopup: Bool
    var gifManager = GIFFromImages()
    
    var body: some View {
        
        ZStack {
            
            Color(.black)
                .opacity(0.28)
                .ignoresSafeArea()
                .onTapGesture {
                    close()
                }
            
            VStack {
                Button {
                    
                    var images: [UIImage] = []
                    for frame in animation.frames {
                        let image = try! PKDrawing(data: frame.frameData).generateThumbnail(scale: 1)
                        images.append(image)
                    }

                    let gifURL = gifManager.makeFileURL(filename: "example.gif")
                    gifManager.generateGifFromImages(images: images, fileURL: gifURL, colorSpace: .rgb, delayTime: 0.1, loopCount: 0)
                    
                    // Check if the GIF file exists
                    if FileManager.default.fileExists(atPath: gifURL.path) {
                        print("GIF was generated successfully.")
                    } else {
                        print("Failed to generate GIF.")
                    }
                    
                    // Save the generated GIF to the Photos library
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: gifURL)
                    }) { success, error in
                        if success {
                            print("GIF saved successfully.")
                        } else {
                            print("Error saving GIF:", error ?? "Unknown error")
                        }
                    }
                    
                    close()
                    
                } label: {
                    
                    ZStack {
                        Rectangle()
                            .frame(width: 400, height: 100)
                            .foregroundColor(.accentColor)
                            .cornerRadius(30)
                        Text("Save GIF to Photos")
                            .foregroundStyle(.white)
                            .font(.title)
                            .bold()
                    }
                    
                        
                    
                    
                }
                
                ZStack {
                    Rectangle()
                        .frame(width: 400, height: 50)
                        .foregroundColor(.black.opacity(0.05))
                        .cornerRadius(20)
                    Text("More coming soon...")
                        .foregroundStyle(.gray)
                        .font(.title)
    //                        .bold()
                }

                
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(40)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            .overlay {
                
                HStack {
                    Spacer()
                    VStack {
                        Button {
                            close()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title2)
                        }
                        .tint(.black)
                        Spacer()
                    }
                }
                .padding(20)
        }
        }
    }
    
    func close() {
        withAnimation(.default) {
            showSavePopup = false
        }
    }
}

//#Preview {
//    SaveAnimationPopup(animation: Animation(), showSavePopup: true)
//}
