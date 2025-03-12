import Foundation
import SwiftUI

final class AiTask {
    enum Position {
        case bottom
        case rightTop
        case rightBottom
        case right
    }
    
    let title: String
    let subTitle: String
    let image: String
    let backgroundColor: Color
    let cardHeight: CGFloat
    let position: Position
    let onTap: () -> Void
    
    init(title: String, subTitle: String, image: String, backgroundColor: Color, cardHeight: CGFloat, position: Position, onTap: @escaping () -> Void) {
        self.title = title
        self.subTitle = subTitle
        self.image = image
        self.backgroundColor = backgroundColor
        self.cardHeight = cardHeight
        self.position = position
        self.onTap = onTap
    }
}
