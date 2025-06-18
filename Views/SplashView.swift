import SwiftUI

struct SplashView: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 32) {
                // Placeholder for Disney-style logo
                Image(systemName: "sparkles")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .foregroundColor(.white)
                    .shadow(color: .blue.opacity(0.5), radius: 20, x: 0, y: 10)
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animate)
                // Pixie trail animation (placeholder)
                PixieTrailView(animate: animate)
            }
        }
        .onAppear { animate = true }
    }
}

struct PixieTrailView: View {
    var animate: Bool
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<7) { i in
                Circle()
                    .fill(Color.blue.opacity(0.7 - Double(i) * 0.1))
                    .frame(width: CGFloat(16 - i * 2), height: CGFloat(16 - i * 2))
                    .offset(y: animate ? CGFloat.random(in: -10...10) : 0)
                    .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(Double(i) * 0.1), value: animate)
            }
        }
    }
}

struct PixieBurstTransitionView: View {
    var onComplete: (() -> Void)? = nil
    @State private var animate = false
    let particleCount = 12
    let duration: Double = 1.0

    var body: some View {
        ZStack {
            // Faint white flash
            Circle()
                .fill(Color.white.opacity(animate ? 0.0 : 0.3))
                .frame(width: animate ? 400 : 0, height: animate ? 400 : 0)
                .scaleEffect(animate ? 1.5 : 0.1)
                .opacity(animate ? 0 : 0.5)
                .animation(.easeOut(duration: duration * 0.6), value: animate)
            // Pixie particles
            ForEach(0..<particleCount, id: \ .self) { i in
                PixieParticle(angle: Double(i) / Double(particleCount) * 2 * .pi, animate: animate, duration: duration)
            }
            // Center sparkle
            Image(systemName: "sparkles")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: animate ? 0 : 80, height: animate ? 0 : 80)
                .opacity(animate ? 0 : 1)
                .scaleEffect(animate ? 0.1 : 1)
                .animation(.easeIn(duration: duration * 0.4), value: animate)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .onAppear {
            withAnimation {
                animate = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                onComplete?()
            }
        }
    }
}

private struct PixieParticle: View {
    let angle: Double
    let animate: Bool
    let duration: Double
    var body: some View {
        let radius: CGFloat = animate ? 180 : 0
        let x = cos(angle) * radius
        let y = sin(angle) * radius
        return Circle()
            .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.white.opacity(0.8)]), startPoint: .top, endPoint: .bottom))
            .frame(width: animate ? 0 : 24, height: animate ? 0 : 24)
            .offset(x: animate ? x : 0, y: animate ? y : 0)
            .opacity(animate ? 0 : 1)
            .scaleEffect(animate ? 0.1 : 1)
            .shadow(color: Color.blue.opacity(0.5), radius: 8, x: 0, y: 0)
            .animation(.easeOut(duration: duration * 0.8).delay(Double.random(in: 0...0.2)), value: animate)
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
} 