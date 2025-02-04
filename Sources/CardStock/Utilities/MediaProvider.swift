//
//  MediaProvider.swift
//  CardStock
//
//  Created by Jason Jobe on 1/31/25.
//

import Foundation
import SwiftUI

public struct MediaProvider: Sendable {
    public static let shared: MediaProvider = .init()
}


public extension MediaProvider {
    func resolve(url : URL) throws -> URL {
        if url.isFileURL {
            guard let fileURL = Bundle.mediaImages
                .url(forResource: url.host(), withExtension: nil)
            else {
                throw MediaProviderError.cannotResolove(url.description)
            }
            return fileURL
        } else {
            return url
        }
    }

    static let sample = """
    You can almost feel the calming sea breeze and the refreshing 
    ocean mist as you take in the wonder of the vast Pacific Ocean.
    The perfect collection of videos for those that feel the call 
    of the ocean.
    """
}

// MARK: Media Bundle hooks
public extension Bundle {
    static let mediaImages: Bundle = .module
}

public enum MediaProviderError: Error {
    case cannotResolove(String)
    case missing(String)
}


struct MediaView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 8) {
            HStack {
                Portrait(card: .portrait)
                    .frame(width: 180)
                Landscape(card: .preview)
            }
//                .border(.red)

            TableRow(card: .preview)
        }
        .frame(height: 600)
        .padding(20)
    }
}

struct Card: Identifiable {
    var id: Int64
    var title: String
    var subtitle: String?
    var hero: String?
    var body: String?
}

extension Card {
    static let preview: Card = Card(
        id: 1,
        title: "Ocean View",
        hero: "ocean_landscape",
        body: MediaProvider.sample
    )
    
    static let portrait: Card = Card(
        id: 1,
        title: "Ocean View",
        hero: "ocean_portrait",
        body: MediaProvider.sample
    )

}


struct TableRow: View {
    var card: Card
    @State var size: CGSize = .zero
    
    @ViewBuilder
    func image(hero: String) -> some View {
        Image(hero, bundle: .mediaImages)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: size.height)
            .clipped()
            .cornerRadius(8)
    }
    
    var body: some View {
        HStack {
            if let hero = card.hero {
                image(hero: hero)
            }
            VStack(alignment: .leading) {
                Text(card.title)
                    .font(.headline)
                if let body = card.body {
                    Text(body)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.trailing)
                }
//                Text(card.subtitle ?? "")
//                    .font(.caption)
            }
            .padding(.vertical)
        }
        .onGeometryChange(for: CGSize.self, of: \.size) {
            self.size = $0
        }
        .padding(8)
        .background(.tertiary)
            .cornerRadius(8)
    }
}

struct Portrait: View {
    var card: Card
    var overlayAlignment: Alignment = .top
    
    var body: some View {
        ZStack {
            if let hero = card.hero {
                Image(hero, bundle: .mediaImages)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
        .overlay(alignment: overlayAlignment) {
            VStack(alignment: .leading) {
                Spacer().frame(height: 10)
                Text(card.title)
                    .frame(maxWidth: .infinity)
                    .font(.headline)
                Text(card.subtitle ?? "")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            .background(.ultraThinMaterial)
        }
            .cornerRadius(8)
    }
}

struct Landscape: View {
    var card: Card
    @State var size: CGSize = .zero
    
    var body: some View {
        VStack(alignment: .leading) {
            if let hero = card.hero {
                Image(hero, bundle: .mediaImages)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onGeometryChange(for: CGSize.self, of: \.size, action: {
                        self.size = $0
                    })
            }
            VStack(alignment: .leading) {
                Text(card.title)
                    .font(.headline)
//                    .alignmentGuide(.leading) { $0.width - 20 }
                if let body = card.body {
                    Text(body)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(card.subtitle ?? "")
                    .font(.caption)
            }
            .frame(width: size.width - 4, alignment: .leading)
//            .border(.red)
            .padding(.leading, 4)
        }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}
