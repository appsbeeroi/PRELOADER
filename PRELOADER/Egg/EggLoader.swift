import SwiftUI

struct EggLoader: View {
    @State private var eggs: [EggState] = []
    @State private var isGameActive = true
    @State private var isShowResult = false
    @State private var correctEggIndex = Int.random(in: 0..<3)
    
    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                let now = timeline.date.timeIntervalSinceReferenceDate
                
                ZStack {
                    Image(.BG)
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                    
                    if isShowResult {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                            .transition(.opacity)
                    }
                    
                    ForEach(eggs.indices, id: \.self) { i in
                        let egg = eggs[i]
                        
                        Image(.eggLight)
                            .resizable()
                            .scaledToFit()
                            .frame(width: i == correctEggIndex && !isGameActive ? 120 : 100,
                                   height: i == correctEggIndex && !isGameActive ? 144 : 120)
                            .rotationEffect(.degrees(egg.angle))
                            .position(egg.position)
                            .opacity(!isGameActive && i != correctEggIndex ? 0.8 : 1)
                            .shadow(radius: 6)
                            .onTapGesture {
                                if isGameActive { stopGame(in: geo.size) }
                            }
                    }
                    
                    if isShowResult {
                        result
                            .transition(.scale.combined(with: .opacity))
                            .offset(y: -150)
                    }
                }
                .onChange(of: now) { time in
                    guard isGameActive else { return }
                    for i in eggs.indices {
                        eggs[i] = eggs[i].updated(at: time, in: geo.size)
                    }
                }
                .onAppear {
                    if eggs.isEmpty {
                        eggs = (0..<3).map { _ in EggState.random(in: geo.size) }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.6), value: isShowResult)
    }
    
    // MARK: - Result View
    
    private var result: some View {
        VStack {
            Spacer(minLength: 100)
            
            VStack {
                Image(.result)
                    .resizable()
                    .scaledToFit()
                
                Button {
                    restartGame()
                } label: {
                    Text("Collect")
                        .frame(height: 52)
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                        .background(
                            LinearGradient(colors: [.lightGreen, .baseGreen],
                                           startPoint: .top,
                                           endPoint: .bottom)
                        )
                        .cornerRadius(20)
                }
            }
            .padding()
            .background(
                RadialGradient(colors: [.baseRed, .darkRed],
                               center: .center,
                               startRadius: 0,
                               endRadius: 250)
            )
            .cornerRadius(20)
            .padding(30)
            
            Spacer(minLength: 220) // 🟩 место, где будут яйца
        }
    }
    
    // MARK: - Game Control
    
    private func stopGame(in size: CGSize) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isGameActive = false
            
            let baseY = size.height * 0.7 // 🟩 ниже окна result
            
            for i in eggs.indices {
                let spacing: CGFloat = 140
                let totalWidth = spacing * CGFloat(eggs.count - 1)
                let startX = size.width / 2 - totalWidth / 2
                
                eggs[i].position = CGPoint(
                    x: startX + spacing * CGFloat(i),
                    y: baseY
                )
                eggs[i].angle = 0
            }
            
            isShowResult = true
        }
    }
    
    private func restartGame() {
        withAnimation {
            isShowResult = false
            isGameActive = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let size = UIApplication.shared.connectedScenes
                .compactMap({ ($0 as? UIWindowScene)?.screen.bounds.size })
                .first {
                correctEggIndex = Int.random(in: 0..<3)
                eggs = (0..<3).map { _ in EggState.random(in: size) }
            }
        }
    }
}

// MARK: - Egg Model

private struct EggState {
    var position: CGPoint
    var velocity: CGSize
    var angle: Double
    var angleSpeed: Double
    var angleDirection: Double
    var lastUpdate: TimeInterval
    
    static func random(in size: CGSize) -> EggState {
        EggState(
            position: CGPoint(
                x: CGFloat.random(in: 60...size.width - 60),
                y: CGFloat.random(in: 100...size.height - 100)
            ),
            velocity: CGSize(
                width: CGFloat.random(in: -200...200),
                height: CGFloat.random(in: -200...200)
            ),
            angle: Double.random(in: -15...15),
            angleSpeed: Double.random(in: 25...40),
            angleDirection: Bool.random() ? 1 : -1,
            lastUpdate: Date().timeIntervalSinceReferenceDate
        )
    }
    
    func updated(at time: TimeInterval, in size: CGSize) -> EggState {
        let dt = time - lastUpdate
        var pos = position
        var vel = velocity
        var ang = angle
        var dir = angleDirection
        
        pos.x += vel.width * dt
        pos.y += vel.height * dt
        
        // теперь движение по всему экрану
        if pos.x < 50 || pos.x > size.width - 50 { vel.width *= -1 }
        if pos.y < 50 || pos.y > size.height - 50 { vel.height *= -1 }
        
        ang += dir * angleSpeed * dt
        if abs(ang) > 15 { dir *= -1 }
        
        return EggState(
            position: pos,
            velocity: vel,
            angle: ang,
            angleSpeed: angleSpeed,
            angleDirection: dir,
            lastUpdate: time
        )
    }
}

#Preview {
    EggLoader()
}
