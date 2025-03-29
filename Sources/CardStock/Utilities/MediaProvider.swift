//
//  MediaProvider.swift
//  CardStock
//
//  Created by Jason Jobe on 1/31/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

public enum MediaType: Hashable, Equatable {
    case image, video
    case slideshow
    case text
    case markdown
    case color
}

public enum ResourceLocation: Hashable, Equatable {
    case system(String)
    case module(String, Bundle?)
    case remote(URL)
}

public struct Media: Hashable, Equatable {
    var host: String?
    var mediaType: MediaType
    var location: ResourceLocation
    var resizable: Bool
}

public extension Media {
    
    init(_ name: String, bundle: Bundle = .main) {
        self = Media(mediaType: .image, location: .module(name, bundle), resizable: true)
    }

    func resizable(_ resizable: Bool = true) -> Media {
        var media = self
        media.resizable = resizable
        return media
    }
}

extension Media: View {
    public var body: some View {
        switch mediaType {
        case .image:
            Image(systemName: "ladybug")
                .resizable()
                .aspectRatio(contentMode: .fit)
        default:
            EmptyView()
        }
//        case .video:
//            VideoPlayer(player: AVPlayer(url: url))
//                .frame(height: 300)
//        }
    }
    
//    private func loadImage() -> Image? {
//        do {
//            let data = try Data(contentsOf: url)
//            return UIImage(data: data)
//        } catch {
//            print("Failed to load image from URL: \(url)")
//            return nil
//        }
//    }
}

/**
 Examples:
 ```
 color:orange
 color:#hex
 image:/module/ocean
 image:/system/ladybug
 ```
 */
//public extension Media {
//    init(uri: String) {
//        self.uri = uri
//        self.mediaType = .color
//        self.location = .color("")
//    }
//}

// MARK:

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

    static let sample =
    """
    You can almost feel the calming sea breeze and the refreshing ocean mist as you take in the wonder of the vast Pacific Ocean.
    """

    static let long = """
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
                AdaptiveLockupView(model: .portrait, presentationAspect: .portrait)
                    .frame(width: 180)
//                    .layoutPriority(0.5)
                AdaptiveLockupView(model: .preview, presentationAspect: .landscape)
//                    .layoutPriority(1)
            }
            AdaptiveLockupView(model: .preview, presentationAspect: .tableRow)
        }
        .frame(height: 600)
        .padding(20)
    }
}

//enum PresentationAspect {
//    case square, portrait, landscape, tableRow
//}
public enum PresentationAspect: CaseIterable, Hashable {
    case tableRow, tile, poster, hero, portrait, landscape
}

struct AdaptiveLockupView: View {
    var model: Card
    var presentationAspect: PresentationAspect
    
    var body: some View {
        switch presentationAspect {
        case .tile, .portrait, .poster, .hero:
            Portrait(card: model)
        case .landscape:
            Landscape(card: model)
        case .tableRow:
            CardTableRow(card: model)
        }
    }
}


struct Card: Identifiable, Codable {
    var id: Int64
    var title: String
    var subtitle: String?
    var hero: String?
    var body: String?
}

//extension Card: Transferable {    
//    
//}

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

struct CardTableRow: View {
    var card: Card
    @State var size: CGSize = .zero
    
    @ViewBuilder
    func image(hero: String) -> some View {
        Image(hero, bundle: .mediaImages)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: size.height)
//            .background(ContainerRelativeShape())
//            .cornerRadius(5)
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
            }
            .padding(.vertical)
        }
        .onGeometryChange(for: CGSize.self, of: \.size) {
            self.size = $0
        }
//        .padding(8)
        .background(.thickMaterial)
//        .background(.tertiary)
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
                if let body = card.body {
                    Text(body)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(card.subtitle ?? "")
                    .font(.caption)
            }
            .frame(width: size.width - 4, alignment: .leading)
            .padding(.leading, 4)
        }
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
    }
}
