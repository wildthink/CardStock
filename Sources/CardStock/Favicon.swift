//
//  Favicon.swift
//  Letterpress
//
//  Created by Jason Jobe on 3/11/25.
//

import Foundation
import SwiftUI

/*
 https://blog.jim-nielsen.com/2021/displaying-favicons-for-any-domain/
 
 <img src="https://s2.googleusercontent.com/s2/favicons?domain=twitter.com&sz=32" alt="Twitter Icon"/>
 <img src="https://icons.duckduckgo.com/ip3/twitter.com.ico" alt="Twitter Icon"/>
 https://favicone.com/linkedin.com?s=128
 <img src="https://unavatar.now.sh/twitter.com" alt="Twitter Icon"/>
 middle-white-monkey.faviconkit.com/{website}/{size}
 */
public extension Favicon.Provider {
    static let google: Self = .init { size, domain in
        URL(string: "https://s2.googleusercontent.com/s2/favicons?domain=\(domain)&sz=\(size.rawValue)")!
    }
    
    static let faviconKit: Self = .init { size, domain in
        URL(string: "http://middle-white-monkey.faviconkit.com/\(domain)/\(size.rawValue)")!
    }

    static let duckDuckGo: Self = .init { size, domain in
        URL(string: "https://icons.duckduckgo.com/ip3/\(domain).ico")!
    }
}

public struct Favicon: View {
    
    public struct Provider: @unchecked Sendable {
        let _faviconURL: (Size, String) -> URL?
        
        func faviconURL(size: Size, domain: String?) -> URL? {
            guard let domain = domain else { return nil }
            return _faviconURL(size, domain)
        }
    }
    
    public init(
        url: URL,
        size: Size = .medium,
        defaultName: String = "questionmark.square.fill",
        provider: Provider = .duckDuckGo
    ) {
        self.url = url
        self.provider = provider
        self.size = size
        self.defaultName = defaultName
    }
    
    /// Stored constant for the favicon's URL
    public let url: URL
    public let provider: Provider
    public let defaultName: String
    public let size: Size
    
	/// Computed property returning the URL's domain
	private var domain: String? {
		return url.host(percentEncoded: false)
	}
	
    public var body: some View {
        AsyncImage(url: provider.faviconURL(size: size, domain: domain)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            Image(systemName: defaultName)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
    
	/// Function to get the favicon of a website
//    func favicon(size: Size, width: CGFloat, defaultSystemName: String = "questionmark.square.fill" ) -> some View {
//        AsyncImage(url: url) { image in
//            image
//                .aspectRatio(contentMode: .fit)
//                .frame(width: width)
//        } placeholder: {
//            Image(systemName: defaultSystemName)
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: width)
//        }
//	}
	
	public enum Size: Int, CaseIterable {
        case small = 16, medium = 32, large = 64, xlarge = 128, xxlarge = 256, xxxlarge = 512
//		case s = 16, m = 32, l = 64, xl = 128, xxl = 256, xxxl = 512
	}
	
}
