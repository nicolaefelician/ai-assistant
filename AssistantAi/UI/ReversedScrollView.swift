import SwiftUI

struct ReversedScrollView<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder builder: ()->Content) {
        self.content = builder()
    }
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                HStack {
                    Spacer()
                    content
                }
                .frame(minWidth: proxy.size.width)
            }
        }
    }
}
