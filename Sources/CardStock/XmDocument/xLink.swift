//
//  xLink.swift
//  CardStock
//
//  Created by Jason Jobe on 2/13/25.
//

import SwiftUI
@preconcurrency import Markdown

/*
 message (Apple)
 bubble
 envelope emailto:jane@jetsons.com
 phone tel:199999
 globe https: http:
 mappin.and.ellipse 􀎫 geo:25.245470,51.454009
 */

public struct xLink: Identifiable {
    public var id: Int { url.absoluteString.hashValue }
    public var label: String
    public var url: URL
    public var imageName: String {
        _imageName ?? commonFavicon ?? defaultIcon
    }
    var _imageName: String?
//    public var customIcon: SwiftUI.Image?
    
//    public var icon: SwiftUI.Image {
//        customIcon ??
//            .init(systemName: commonFavicon ?? defaultIcon)
//    }
}

public extension xLink {
    
    init?(_ link: Markdown.Image) {
        guard let urlString = link.source,
             let url = URL(string: urlString)
        else { return nil }
        self.url = url
        self.label = link.title ?? url.host ?? urlString
        self._imageName = nil
    }

    init?(_ link: Markdown.Link) {
        guard let urlString = link.destination,
             let url = URL(string: urlString)
        else { return nil }
        self.url = url
        self.label = link.title ?? url.host ?? urlString
        self._imageName = nil
    }
}

public extension xLink {
    var defaultIcon: String {
        switch url.scheme {
            case "https", "http": "globe"
        case "tel": "phone"
        case "geo": "mappin.and.ellipse"
        case "sms": "bubble"
            case "mailto": "envelope"
        default:
            "link"
        }
    }
    
    var commonFavicon: String? {
        guard let host = url.host else { return nil }
        let list = host.split(separator: ".")
        return list.count >= 2 ? String(list[list.count - 2]) : nil
    }
}

extension URL {
    var commonFavicon: String? {
        guard let host = host else { return nil }
        let list = host.split(separator: ".")
        return list.count >= 2 ? String(list[list.count - 2]) : nil
    }
}

public struct LinkView: View {
    @Environment(\.openURL) var openURL
    public var model: xLink
    
    public var body: some View {
        LabeledContent(model.label) {
            icon
                .frame(maxWidth: 24)
        }
        .contentShape(.rect)
        .onTapGesture {
            openURL(model.url)
        }
    }
    
    @ViewBuilder
    var icon: some View {
        if let img = Image(qname: model.imageName, bundle: .module)
            ?? Image(qname: model.defaultIcon, bundle: .module) {
            img
            .resizable()
            .aspectRatio(contentMode: .fit)
//            .frame(width: 24, height: 24)
        }
    }
}
