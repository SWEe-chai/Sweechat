import SwiftUI

struct ScrollViewOffset<Content: View>: View {
    @Binding var offset: CGFloat
    @Binding var height: CGFloat
    let content: () -> Content
    var body: some View {
        ScrollView {
            offsetReader
            content()
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear { height = proxy.size.height }
                            .onChange(of: proxy.size.height) {
                                if height != 0 {
                                    let dHeight = proxy.size.height - height
                                    offset += dHeight
                                }
                                height = $0
                            }
                    }
                )
                .padding(.top, -8)
        }
        .coordinateSpace(name: "frameLayer")
        .onPreferenceChange(OffsetPreferenceKey.self, perform: { offset = $0 })
    }

    var offsetReader: some View {
        GeometryReader { proxy in
            Color.clear.preference(
                key: OffsetPreferenceKey.self,
                value: -proxy.frame(in: .named("frameLayer")).minY
            )
        }
        .frame(height: 0)
    }
}

private struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

private struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
