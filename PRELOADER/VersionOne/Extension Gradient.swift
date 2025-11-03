import SwiftUI

extension LinearGradient {
    static var defaultGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "FC9512"),
                Color(hex: "FED319"),
                Color(hex: "FC9512"),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
