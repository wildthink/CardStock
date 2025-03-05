import SwiftUI

struct Lockup<Header: View, Footer: View> {
    var title, subtitle: String?
    var hero: Image?
    var header: (Self) -> Header
    var footer: (Self) -> Footer
}

@MainActor let lockup = Lockup(
    title: "Sample Title",
    subtitle: "Sample Subtitle",
    hero: Image("ocean_portrait", bundle: .mediaImages),
    header: { _ in EmptyView() },
    footer: { _ in EmptyView() }
)

struct LockupRow<Header: View, Footer: View>: View {
    var lockup: Lockup<Header, Footer>

    var body: some View {
        HStack {
            if let hero = lockup.hero {
                hero
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            }
            VStack(alignment: .leading) {
                if let title = lockup.title {
                    Text(title)
                        .font(.headline)
                }
                if let subtitle = lockup.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            lockup.header(lockup)
            lockup.footer(lockup)
        }
    }
}

struct LockupCard<Header: View, Footer: View>: View {
    var lockup: Lockup<Header, Footer>

    var body: some View {
        VStack {
            if let hero = lockup.hero {
                hero
                    .resizable()
                    .aspectRatio(contentMode: .fill)
//                    .frame(width: lockup.size.width, height: lockup.size.width)
                    .clipped()
                    .cornerRadius(16)
            }
            VStack(alignment: .leading) {
                if let title = lockup.title {
                    Text(title)
                        .font(.headline)
                }
                if let subtitle = lockup.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            lockup.header(lockup)
            lockup.footer(lockup)
        }
//        .frame(width: lockup.size.width, height: lockup.size.height)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(radius: 4)
    }
}

struct LockupPortrait<Header: View, Footer: View>: View {
    var lockup: Lockup<Header, Footer>

    var body: some View {
        LockupCard(lockup: lockup)
    }
}

struct LockupLandscape<Header: View, Footer: View>: View {
    var lockup: Lockup<Header, Footer>

    var body: some View {
        LockupRow(lockup: lockup)
    }
}

struct LockupAdaptive<Header: View, Footer: View>: View {
    var lockup: Lockup<Header, Footer>

    var body: some View {
        GeometryReader { geometry in
            if geometry.size.width > geometry.size.height {
                LockupLandscape(lockup: lockup)
            } else {
                LockupPortrait(lockup: lockup)
            }
        }
    }
}

struct __ContentView: View {
    var body: some View {
        VStack {
            LockupAdaptive(lockup: Lockup(
                title: "Sample Title",
                subtitle: "Sample Subtitle",
                hero: Image("ocean_portrait", bundle: .mediaImages),
//                size: CGSize(width: 200, height: 200),
                header: { _ in EmptyView() },
                footer: { _ in EmptyView() }
            ))
        }
        .padding()
    }
}

struct LockupRow_Previews: PreviewProvider {
    static var previews: some View {
        LockupRow(lockup: lockup)
            .previewLayout(.sizeThatFits)
            .border(Color.red)
    }
}

struct LockupCard_Previews: PreviewProvider {
    static var previews: some View {
        LockupCard(lockup: lockup)
            .previewLayout(.sizeThatFits)
            .border(Color.red)
    }
}

struct LockupPortrait_Previews: PreviewProvider {
    static var previews: some View {
        LockupPortrait(lockup: lockup)
            .previewLayout(.sizeThatFits)
            .border(Color.red)
    }
}

struct LockupLandscape_Previews: PreviewProvider {
    static var previews: some View {
        LockupLandscape(lockup: lockup)
            .previewLayout(.sizeThatFits)
            .border(Color.red)
    }
}

struct LockupAdaptive_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Portrait Mode")
                .font(.headline)
            LockupAdaptive(lockup: lockup)
                .frame(width: 375, height: 812) // Example portrait dimensions
                .border(Color.red)

            Text("Landscape Mode")
                .font(.headline)
            LockupAdaptive(lockup: lockup)
                .frame(width: 812, height: 375) // Example landscape dimensions
                .border(Color.red)
        }
        .padding()
    }
}
