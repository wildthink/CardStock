//
//  ContentView.swift
//  CardStock
//
//  Created by Jason Jobe on 4/27/25.
//

import SwiftUI

struct Majid_i: View {
    @State private var selectedImage: String?
    @Namespace private var hero

    let images: [String] = [
        "pencil",
        "trash",
        "lock.doc",
        "person",
        "figure.run"
    ]

    var body: some View {
        NavigationStack {
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3)) {
                ForEach(images, id: \.self) { image in
                    Image(systemName: selectedImage == image ? "" : image)
                        .resizable()
                        .scaledToFit()
                        .background(Material.regular)
                        .matchedGeometryEffect(id: image, in: hero)
                        .onTapGesture {
                            selectedImage = image
                        }
                }
            }
            .overlay {
                if let image = selectedImage {
                    Image(systemName: image)
                        .resizable()
                        .scaledToFill()
                        .background(Material.thin)
                        .matchedGeometryEffect(id: image, in: hero)
                        .animation(.easeInOut, value: selectedImage)
                        .onTapGesture {
                            selectedImage = nil
                        }
                }
            }
        }
        .animation(.default, value: selectedImage)
    }
}

#Preview {
    Majid_i()
        .padding()
        .frame(width: 300, height: 400)
}
