import SwiftUI
import PhotosUI

struct ProfilePhotoView: View {
    @StateObject private var viewModel = ProfilePhotoViewModel()
    let onDismiss: () -> Void
    let currentPhotoData: String?
    let onChooseFromGallery: () -> Void
    let onRemovePhoto: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Buttons Container
            VStack(spacing: 0) {
                ProfileButton(
                    icon: "photo.badge.arrow.down.fill",
                    title: "Choose from Gallery",
                    isDisabled: currentPhotoData != nil
                ) {
                    onDismiss()
                    onChooseFromGallery()
                }
                
                ProfileButton(
                    icon: "trash",
                    title: "Remove Profile Photo",
                    isDisabled: currentPhotoData == nil
                ) {
                    onDismiss()
                    onRemovePhoto()
                }
            }
            .background(Color(white: 0.2))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.bottom, 16)
            
            // Cancel Button
            Button("Cancel") {
                onDismiss()
            }
            .font(.body.bold())
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .transition(.move(edge: .bottom))
    }
} 
