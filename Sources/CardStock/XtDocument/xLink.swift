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
    public var customIcon: SwiftUI.Image?
    
    public var icon: SwiftUI.Image {
        customIcon ??
            .init(systemName: commonFavicon ?? defaultIcon)
    }
}

public extension xLink {
    
    init?(_ link: Markdown.Image) {
        guard let urlString = link.source,
             let url = URL(string: urlString)
        else { return nil }
        self.url = url
        self.label = link.title ?? url.host ?? urlString
        self.customIcon = nil
    }

    init?(_ link: Markdown.Link) {
        guard let urlString = link.destination,
             let url = URL(string: urlString)
        else { return nil }
        self.url = url
        self.label = link.title ?? url.host ?? urlString
        self.customIcon = nil
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
        switch url.host {
        case "apple.com":
            "apple.logo"
        default:
             nil
        }
    }
}

public struct LinkView: View {
    public enum Style { case iconOnly, iconAndLabel, labelOnly }
    public var model: xLink
    public var style: Style = .iconAndLabel
    @Environment(\.openURL) var openURL
    
    public var body: some View {
        Group {
            switch style {
            case .iconOnly:
                model.icon.resizable()
                    .frame(width: 16, height: 16)
            case .iconAndLabel:
                HStack(alignment: .center) {
                    model.icon.resizable()
                        .frame(width: 16, height: 16)
                    Text(model.label)
                }
            case .labelOnly:
                Text(model.label)
            }
        }
        .contentShape(.rect)
        .onTapGesture {
            openURL(model.url)
        }
    }
}
