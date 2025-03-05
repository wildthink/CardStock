//
//  XmPresentation.swift
//  CardStock
//
//  Created by Jason Jobe on 2/23/25.
//

import SwiftUI
import Foundation

let x = 2021_02_15 // w07
let y = 0000_02_00 // w07

//struct ModelView<Model, Content: View>: View {
//    var model: Model
//    var content: Content
//
//    var body: some View {
//        content
//    }
//}
public protocol XmPresentable {
    
}

public protocol PresentationStyle {
    
}


struct XmPresentation: View {
    var card: Card
    //    @State var size: CGSize = .zero
    @State var ratio: CGFloat = 0.8
    
    var body: some View {
        VStack(alignment: .leading) {
            if let hero = card.hero {
                Image(hero, bundle: .mediaImages)
                    .resizable()
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
            .padding(.horizontal, 8)
        }
        .containerRelativeFrame(.horizontal) { len, ax in
            // Using the len itself in scrollView -> "paginated"
            len * ratio
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .aspectRatio(3/5, contentMode: .fit)
        .animation(.easeInOut(duration: 0.6), value: ratio)
        .onTapGesture {
            ratio = (ratio == 0.8) ? 0.6 : 0.8
        }
    }
}

#Preview {

    @Previewable @State var scrollPosition = ScrollPosition(idType: Item.self)
    
    VStack {
        Text("\(scrollPosition.viewID)").padding()
        Carousel(scrollPosition: $scrollPosition, items: Item.allItems) { it in
            XmPresentation(card: .portrait)
        }
        .border(.red)
        
        Carousel_ii {
            ForEach(Item.allItems) { it in
                XmPresentation(card: .portrait)
                    .id(it)
            }
        }
    }
    .padding()
}

struct CatalogTable<Element: Identifiable & Transferable>: TableRowContent {
//    typealias Element = Card
    @Binding var items: [Element]


    var tableRowBody: some TableRowContent<Element> {
        ForEach(items) { item in
            TableRow(item)
//                .itemProvider { item.itemProvider }
        }
        .dropDestination(for: Element.self) { destination, newItems in
            items.insert(contentsOf: newItems, at: destination)
        }
    }
}

struct Item: Identifiable, Hashable {
    var id: Int
    static let allItems: [Item] = (1...10).map(Item.init)
}

#Preview {
    XmPresentation(card: .preview)
        .padding()
}

//let xdoc = try! Bundle.module.xdocument("catalog")

extension XmDocument {
    convenience init(parseContentsOf url: URL) throws {
        let str = try String(contentsOf: url, encoding: .utf8)
        self.init(str)
    }
}

// MARK: Bundle Extensions

extension Bundle {
    static let surfboard: Bundle = .module
    
    func xdocument(_ name: String) throws -> XmDocument {
        guard let p = url(forResource: name, withExtension: "xmd")
        else { throw AppError.not_found(name) }
        return try XmDocument(parseContentsOf: p)
    }
}

// MARK: Errors
enum AppError: Error {
    case not_found(String)
}

let xdoc = XmDocument(doc_md)

let doc_md = """
@meta {
    baseURL: https://wildthink.com/apps/jason
}

@hero {
![Jason](https://wildthink.com/apps/jason/Jason_AI.jpeg)
}

# **Jason**
@profile(aka: jason, tags: [pro, public])
@index(hints_column: swift)

@caption {
- iOS Application Architect
- Amateur Social Scientist
- Tinker, Maker, Smith
}

@links {
    [Gravatar](https://jasonjobe.link)
    [](https://www.linkedin.com/in/jason-jobe-bb0b991/)
    [](https://medium.com/@jasonjobe)
    [](https://github.com/wildthink)
    [](https://www.instagram.com/jmj_02021/)
}

#### Elevator Pitch
@id(pitch, ax: b c 889)
Here is where I say a little bit about myself.
Perhaps, what I like to do for fun.
Or anything else.

##### Pitch Deck

## Section 1
Section one stuff

### Section 1.1
Some subsection stuff.
Line two.

## Section 2

# Top Section


"""
