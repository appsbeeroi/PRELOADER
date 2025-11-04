import SwiftUI

struct VersionOne: View {
    
    @State private var correctBallIndex = Int.random(in: 0..<3)
    @State private var selectedBallIndex: Int? = nil
    
    @State private var ballCenters: [CGPoint] = Array(repeating: .zero, count: 3)
    @State private var gunCenter: CGPoint = .zero
    
    @State private var arrowPosition: CGPoint = .zero
    @State private var arrowAngle: Angle = .zero
    @State private var showArrow: Bool = false
    @State private var isArrowFlying: Bool = false
    
    @State private var scores: [Int?] = [nil, nil, nil]
    
    @State private var isGameOver = false
    @State private var didWin: Bool? = nil
    @State private var hasInteracted = false
    @State private var gunScale: CGFloat = 1.0
    
    @State private var gameTimer: DispatchWorkItem? = nil
    
    private let flightDuration: Double = 2.0
    
    var body: some View {
        GeometryReader { rootGeo in
            ZStack {
                background
                    .overlay {
                        if isGameOver {
                            Color.black.opacity(0.4)
                                .ignoresSafeArea()
                        }
                    }
                
                VStack {
                    helpText
                    
                    Spacer().frame(height: 30)
                    
                    ballsRow(in: rootGeo.size.width)
                        .padding(.top, 10)
                    
                    Spacer()
                    
                    gunArea
                        .padding(.bottom, 40)
                }
                
                if showArrow {
                    Image(.arrow)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 150)
                        .rotationEffect(arrowAngle)
                        .position(arrowPosition)
                        .animation(.linear(duration: flightDuration), value: arrowPosition)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    for i in 0..<3 {
                        if ballCenters[i] == .zero {
                            let x = UIScreen.main.bounds.width / 4 * CGFloat(i + 1)
                            let y = 300.0
                            ballCenters[i] = CGPoint(x: x, y: y)
                        }
                    }
                    if gunCenter == .zero {
                        gunCenter = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - 150)
                    }
                    resetGame()
                }
            }
        }
    }
    
    private var background: some View {
        GeometryReader { geo in
            Image(.arrowBG)
                .resizable()
                .scaledToFill()
                .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
    }
    
    private var helpText: some View {
        VStack {
            if isGameOver {
                Text(didWin == true ? "Winner" : "Try again")
                    .font(.system(size: 68, weight: .medium))
                    .foregroundStyle(LinearGradient.defaultGradient)
                    .transition(.opacity)
            } else {
                Text("Click on any of the balls")
                    .font(.system(size: 27, weight: .medium))
                    .foregroundStyle(LinearGradient.defaultGradient)
            }
        }
        .padding(.top, 50)
        .animation(.easeInOut, value: isGameOver)
    }
    
    private func ballsRow(in totalWidth: CGFloat) -> some View {
        let spacing: CGFloat = 10
        let safeWidth = max(totalWidth, 1)
        let ballSize = min(130, (safeWidth - spacing * 2) / 3)
        
        return HStack(spacing: spacing) {
            ForEach(0..<3) { index in
                ZStack {
                    Button {
                        hasInteracted = true
                        onBallTapped(index)
                    } label: {
                        ballImage(for: index)
                            .resizable()
                            .scaledToFit()
                            .frame(width: ballSize, height: ballSize)
                            .opacity(ballOpacity(for: index))
                            .scaleEffect(scores[index] == 100 ? 0.8 : 1.5)
                    }
                    .disabled(isArrowFlying || isGameOver)

                    if let _ = scores[index] {
                        Text("+100FS")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .shadow(radius: 4)
                            .scaleEffect(1.2)
                            .opacity(1.0)
                    }
                }
                .frame(width: ballSize, height: ballSize)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private var gunArea: some View {
        HStack {
            Spacer()
            VStack {
                ZStack {
                    Image(.gun)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .scaleEffect(gunScale)
                    
                    Button {
                        if isGameOver {
                            resetGame()
                        } else {
                            hasInteracted = true
                            onArrowButtonPressed()
                        }
                    } label: {
                        Image(.buttonPlaceholder)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 210, height: 140)
                            .overlay {
                                StrokedText(text: isGameOver ? "Reset" : "ARROW", size: 35)
                            }
                            .offset(y: 50)
                    }
                    .disabled(isArrowFlying)
                }
            }
            .frame(width: 200, height: 200)
            Spacer()
        }
    }
    
    private func ballImage(for index: Int) -> Image {
        if scores[index] == 100 {
            return Image(.ball)
        } else {
            return Image(.inflate)
        }
    }
    
    private func ballOpacity(for index: Int) -> Double {
        if scores[index] == 10 {
            return 0.5
        }
        return 1.0
    }
    
    private func onBallTapped(_ index: Int) {
        guard !isArrowFlying, !isGameOver else { return }
        selectedBallIndex = index
        triggerGunAnimation {
            shootArrow(toward: ballCenters[index])
        }
        restartGameEndTimer()
    }
    
    private func onArrowButtonPressed() {
        if isGameOver {
            resetGame()
            return
        }
        
        guard !isArrowFlying, !isGameOver else { return }
        let randomIndex = Int.random(in: 0..<3)
        selectedBallIndex = randomIndex
        triggerGunAnimation {
            shootArrow(toward: ballCenters[randomIndex])
        }
        restartGameEndTimer()
    }
    
    private func triggerGunAnimation(completion: @escaping () -> Void) {
        withAnimation(.easeOut(duration: 0.1)) {
            gunScale = 0.9
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                gunScale = 1.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion()
        }
    }
    
    private func shootArrow(toward target: CGPoint) {
        let start = gunCenter == .zero
            ? CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - 150)
            : gunCenter
        
        arrowPosition = start
        showArrow = true
        isArrowFlying = true
        
        let dx = target.x - start.x
        let dy = target.y - start.y
        arrowAngle = Angle(radians: atan2(dy, dx) + .pi / 2)
        
        withAnimation(.linear(duration: flightDuration)) {
            arrowPosition = target
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + flightDuration + 0.02) {
            withAnimation(.easeOut(duration: 0.15)) {
                showArrow = false
            }
            isArrowFlying = false
            evaluateHit()
        }
    }
    
    private func evaluateHit() {
        guard let index = selectedBallIndex else { return }
        
        if index == correctBallIndex {
            withAnimation {
                scores[index] = 100
            }
            didWin = true
        } else {
            withAnimation {
                scores[index] = 10
            }
            didWin = false
        }
        
        withAnimation {
            isGameOver = true
        }
        cancelGameTimer()
    }
    
    private func restartGameEndTimer() {
        hasInteracted = true
        cancelGameTimer()
        scheduleGameEndCheck()
    }
    
    private func scheduleGameEndCheck() {
        cancelGameTimer()
        let delay = hasInteracted ? 3.0 : 5.0
        let workItem = DispatchWorkItem {
            if !self.isGameOver && !self.isArrowFlying {
                withAnimation {
                    self.didWin = false
                    self.isGameOver = true
                }
            }
        }
        gameTimer = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
    
    private func cancelGameTimer() {
        gameTimer?.cancel()
        gameTimer = nil
    }
    
    private func resetGame() {
        cancelGameTimer()
        correctBallIndex = Int.random(in: 0..<3)
        scores = [nil, nil, nil]
        showArrow = false
        isArrowFlying = false
        selectedBallIndex = nil
        isGameOver = false
        didWin = nil
        hasInteracted = false
        scheduleGameEndCheck()
    }
}

#Preview {
    VersionOne()
}


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

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

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
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(LinearGradient.defaultGradient)
            
            Text(text)
                .font(.system(size: size, weight: .medium))
                .foregroundStyle(Color(hex: "FFBB00"))
        }
    }
}


