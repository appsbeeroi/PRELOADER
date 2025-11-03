import SwiftUI

struct StrokedText: View {
    
    let text: String
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Group {
                Text(text)
                    .offset(x: 1, y: 0)
                
                Text(text)
                    .offset(x: 0, y: 1)
                
                Text(text)
                    .offset(x: 1, y: -1)
                
                Text(text)
                    .offset(x: -1, y: -1)
                
                Text(text)
                    .offset(x: -1, y: 1)
            }
            .font(.grandstander(size: size))
            .foregroundStyle(LinearGradient.defaultGradient)
            
            Text(text)
                .font(.grandstander(size: size))
                .foregroundStyle(Color(hex: "FFBB00"))
        }
    }
}


