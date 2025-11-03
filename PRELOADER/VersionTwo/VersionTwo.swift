import SwiftUI

struct VersionTwo: View {
    
    @State private var rotation: Double = 0
    @State private var trimEnd: CGFloat = 0.1
    @State private var trimStart: CGFloat = 0
    @State private var isBlinking: Bool = false
    
    var body: some View {
        ZStack {
            image
            text
            shieldLoaderWithSpinner
        }
        .onAppear {
            startAnimations()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                
            }
        }
    }
    
    private var image: some View {
        GeometryReader { geo in
            Image(.simpleArrowBG)
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
    }
    
    private var text: some View {
        VStack {
            Image(.arrowSimpleText)
                .resizable()
                .scaledToFit()
                .padding()
                .opacity(isBlinking ? 0.8 : 1.0)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top)
    }
    
    private var shieldLoaderWithSpinner: some View {
        VStack {
            ZStack {
                Image(.arrowSimpleShield)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                
                Circle()
                    .trim(from: trimStart, to: trimEnd)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [.white, .white.opacity(0.3)]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 115, height: 115)
                    .rotationEffect(.degrees(rotation))
            }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 100)
    }
    
    private func startAnimations() {
        withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        
        let trimAnimation = Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)
        withAnimation(trimAnimation) {
            trimEnd = 0.8
        }
        
        let blinkAnimation = Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
        withAnimation(blinkAnimation) {
            isBlinking.toggle()
        }
    }
    
    private func triggerAction() {
        NotificationCenter.default.post(name: .loaderActionTriggered, object: nil)
    }
}

struct ArrowSimpleLoader_Previews: PreviewProvider {
    static var previews: some View {
        VersionTwo()
    }
}
