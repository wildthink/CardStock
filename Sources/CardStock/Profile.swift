//
//  Profile.swift
//  CardStock
//
//  Created by Jason Jobe on 2/5/25.
//

import SwiftUI
@preconcurrency import Markdown
import UniformTypeIdentifiers

public struct Profile: Identifiable, @unchecked Sendable {
    public var id: Int64
    public var name: String
    public var hero: UTL?
    public var links: [UxLink]
    public var actions: [any Action]
    public var content: Tree<String>
    
    public init(
        id: Int64? = nil,
        name: String,
        hero: UTL? = nil,
        links: [UxLink] = [],
        actions: [any Action] = [],
        content: Tree<String>
    ) {
        self.id = id ?? Int64(name.hashValue)
        self.name = name
        self.hero = hero
        self.links = links
        self.actions = actions
        self.content = content
    }
}

public protocol Action<Model>: Identifiable, Sendable {
    associatedtype Model: Sendable
    var id: Int64 { get }
    var name: String { get }
    var model: Model { get }
}

public struct UxAction: Action {
    public var id: Int64
    public var name: String
    public var model: String
}

public struct UxLink: Identifiable {
    public var id: Int { url.absoluteString.hashValue }
    public var url: URL
    public var headline: String
    public var byline: String
}

extension UxLink: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: StringLiteralType) {
        self = .init(parse: value)
    }
    
    // parse example "[Gravatar](https://jasonjobe.link)"    
    public init(parse value: StringLiteralType) {
        let pattern = /^\[(.*?)\]\((.*?)\)$/
        if let result = try? pattern.wholeMatch(in: value) {
            self.headline = result.1.description
            self.url = URL(string: result.2.description)!
            self.byline = ""
        } else {
            self.url = URL(string: value)!
            self.headline = value
            self.byline = ""
        }
    }
}

/// Uniform Type Link/Resource
public struct UTL: Identifiable, Sendable, Codable {
    public var id: Int64
    public var name: String
    public var uti: UTType
    public var proposedSize: ProposedViewSize
    public var content: URL
    public var preview: URL {_preview ?? content }
    private var _preview: URL?

    init(
        id: Int64? = nil,
        name: String,
        uti: UTType,
        proposedSize: ProposedViewSize = .unspecified,
        preview: URL? = nil,
        content: URL
    ) {
        self.id = id ?? Int64(content.hashValue)
        self.name = name
        self.uti = uti
        self.proposedSize = proposedSize
        self._preview = preview
        self.content = content
    }
}

extension ProposedViewSize: Codable {
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let size = try container.decode(CGSize?.self)
        self = size.map { ProposedViewSize($0) } ?? .unspecified
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.width != nil && self.height != nil ? CGSize(width: self.width!, height: self.height!) : nil)
    }
}

extension Color {
    var spec: String {
        String(describing: self)
    }
}

let skyBlue = Color(red: 0.4627, green: 0.8392, blue: 1.0)
let lemonYellow = Color(hue: 0.1639, saturation: 1, brightness: 1)
let steelGray = Color(white: 0.4745)

let colors: [Color] = [
    skyBlue, lemonYellow, steelGray,
    Color.blue,
    Color("AppColor", bundle: .main),
    Color("blue")
]

func info(color: Color) -> String {
    guard let base = Mirror(reflecting: color).descendant("provider", "base")
    else { return "" }
    return String(describing: base)
}

func info(image: SwiftUI.Image) -> String {
    guard let base = Mirror(reflecting: image).descendant("provider", "base")
    else { return "" }
    return String(describing: base)
}

#Preview {
    VStack(alignment: .leading) {
        ForEach (colors, id: \.self) { color in
            let _ = print(color.description)
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .frame(width: 32, height: 32)
//                Text("Color: \(color.spec)")
                Text("Info: \(info(color: color))")
            }
        }
        HStack {
            let img = Image(systemName: "apple.logo")
//            let p = ImageProvider(for: img)
            let p = info(image: img)
            img
            Text(String(describing: p))
        }
//        Text("Color blue: \(Color.blue.spec)")
//        Text("Color skyBlue: \(skyBlue.spec)")
//        Text("Color blue: \(Color.blue.description)")
//        Text("Color AppColor: \(Color("AppColor"))")
//        Text("Color AppColor: \(Color("blue"))")
    }
    .padding()
}

extension URL {
    init(scheme: String, path: String) {
        var parts = URLComponents()
        parts.scheme = scheme
        parts.path = path
        self = parts.url!
    }
    
    static func file(_ path: String) -> URL {
        URL(fileURLWithPath: path)
    }
    static func app(_ path: String) -> URL {
        URL(scheme: "app", path: path)
    }
}

extension UTL {
    static func image(_ name: String, url: URL) -> UTL {
        UTL(name: name, uti: .image, content: url)
    }
}

// MARK: Preview
let j_profile = Profile(
    name: "jason jobe",
    hero: .image("hero", url: URL(string: "https://wildthink.com/apps/jason/Jason_noir.jpeg")!),
    links: [
        "[Gravatar](https://jasonjobe.link)",
        "[](https://www.linkedin.com/in/jason-jobe-bb0b991/)",
        "[](https://medium.com/@jasonjobe)",
        "[](https://github.com/wildthink)",
        "[](https://www.instagram.com/jmj_02021/)",
    ],
    actions: [],
    content: Tree<String>(
        tag: "body",
        element: "Ain't got no body...")
)

extension UTL {
    static let preview: UTL = UTL(name: "preview",
                uti: .image, content: .app("image/preview"))
}

struct xText: ModelView {
    var model: AttributedString
    
    init(_ model: Model) {
        self.model = model
    }

    var body: some View {
        Text(model)
    }
}

extension [AttributedString] {
    mutating func append(_ new: AttributedSubstring) {
        self.append(AttributedString(new))
    }
}

struct UxProfileView: View {
    let profile: Profile
    
    var body: some View {
        BentoBox {
            BentoBox {
                VStack {
                    VStack(spacing: 4) {
                        UxImage(utl: profile.hero)
                        Text(profile.name.capitalized)
                            .font(.largeTitle)
                    }
                    .listStyle(.plain)
                    //                .padding(.trailing)
                    Spacer()
                    SchoolOfThoughtLogo(scale: 0.5, agreement: .iAgree)
                }
            }
//            .border(Color.gray)
            .layoutWeight(0.5)
            BentoBox {
                GroupBox {
                    UxCopy(copy: profile.content)
                }
                List(profile.links) { link in
                    UxLinkView(link: link)
                }
//                Spacer()
//                SchoolOfThoughtLogo(scale: 0.5, agreement: .iAgree)
//                    .scaleEffect(0.75)
            }
//            .border(.red)
        }
//        .bentoBox(axis: .vertical)
    }
}

struct UxCopy: View {
    let copy: Tree<String>
    
    var body: some View {
        Text(copy.element)
    }
}


struct UxLinkView: View {
    let link: UxLink
    
    var body: some View {
        HStack (spacing: 8) {
            Favicon(url: link.url)
                .frame(width: 24)
            VStack(alignment: .leading) {
                if !link.headline.isEmpty {
                    Text(link.headline)
                        .font(.headline)
                } else {
                    Text(link.url.path)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct UxImage: View {
    let utl: UTL?
    
    var body: some View {
        AsyncImage(url: utl?.preview) { image in
               image
                   .resizable()
                   .scaledToFit()
           } placeholder: {
               ProgressView()
           }
           .background(Color.gray)
           .clipShape(.rect(cornerRadius: 8))
    }
}

#Preview {
    UxProfileView(profile: j_profile)
        .frame(width: 500, height: 600, alignment: .leading)
        .padding()
}
