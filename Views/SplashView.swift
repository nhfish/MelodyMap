import SwiftUI

struct SplashView: View {
    @State private var textOpacity: Double = 0.6
    @State private var scale: CGFloat = 0.9
    
    var body: some View {
        ZStack {
            Color.appAccent.ignoresSafeArea()
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: 2) {
                    Text("THE")
                        .font(.system(size: 45, weight: .bold, design: .rounded))
                        .foregroundColor(.appGreen)
                        .textCase(.uppercase)
                    Text("MELODY")
                        .font(.system(size: 45, weight: .bold, design: .rounded))
                        .foregroundColor(.appGreen)
                        .textCase(.uppercase)
                    Text("MAP")
                        .font(.system(size: 45, weight: .bold, design: .rounded))
                        .foregroundColor(.appGreen)
                        .textCase(.uppercase)
                }
                .opacity(textOpacity)
                .scaleEffect(scale)
                .onAppear {
                    // Animate opacity
                    withAnimation(
                        .easeInOut(duration: 1.2)
                    ) {
                        textOpacity = 1.0
                    }
                    // Animate scale up and stay
                    withAnimation(
                        .easeOut(duration: 2.0)
                    ) {
                        scale = 1.1
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(alignment: .center)
        }
    }
}

struct PageCurlTransitionView: View {
    let snapshotImage: Image
    var onComplete: (() -> Void)? = nil
    @State private var curlProgress: CGFloat = 0.0
    let duration: Double = 1.2

    var body: some View {
        ZStack {
            // Background that will be revealed (SearchView background)
            Color.appBackground
                .ignoresSafeArea()
            
            // Page curl effect
            GeometryReader { geometry in
                ZStack {
                    // The "page" being curled (snapshot image)
                    snapshotImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipShape(
                            PageCurlShape(
                                size: geometry.size,
                                progress: curlProgress
                            )
                        )
                        .overlay(
                            // Curl shadow
                            CurlShadow(progress: curlProgress, size: geometry.size)
                        )
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: duration)) {
                curlProgress = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                onComplete?()
            }
        }
    }
}

struct PageCurlShape: Shape {
    let size: CGSize
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let width = size.width
            let height = size.height
            
            // Start from top-left
            path.move(to: CGPoint(x: 0, y: 0))
            
            // Top edge with curl
            let curlHeight = height * 0.4 * progress
            let curlWidth = width * 0.3 * progress
            
            path.addLine(to: CGPoint(x: width - curlWidth, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: width, y: curlHeight),
                control: CGPoint(x: width - curlWidth * 0.3, y: curlHeight * 0.6)
            )
            
            // Right edge
            path.addLine(to: CGPoint(x: width, y: height))
            
            // Bottom edge
            path.addLine(to: CGPoint(x: 0, y: height))
            
            // Left edge
            path.closeSubpath()
        }
    }
}

struct CurlShadow: View {
    let progress: CGFloat
    let size: CGSize
    
    var body: some View {
        Path { path in
            let width = size.width
            let height = size.height
            
            // Create shadow path for the curled area
            let curlHeight = height * 0.4 * progress
            let curlWidth = width * 0.3 * progress
            
            path.move(to: CGPoint(x: width, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: width - curlWidth, y: curlHeight),
                control: CGPoint(x: width, y: curlHeight * 0.6)
            )
            path.addLine(to: CGPoint(x: width, y: height))
            path.closeSubpath()
        }
        .fill(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black.opacity(0.4),
                    Color.black.opacity(0.1),
                    Color.clear
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .offset(x: -size.width * 0.05, y: -size.height * 0.05)
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

struct SplashSnapshotView: View {
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .leading, spacing: 2) {
                Text("THE")
                    .font(.system(size: 45, weight: .bold, design: .rounded))
                    .foregroundColor(.appGreen)
                    .textCase(.uppercase)
                Text("MELODY")
                    .font(.system(size: 45, weight: .bold, design: .rounded))
                    .foregroundColor(.appGreen)
                    .textCase(.uppercase)
                Text("MAP")
                    .font(.system(size: 45, weight: .bold, design: .rounded))
                    .foregroundColor(.appGreen)
                    .textCase(.uppercase)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(alignment: .center)
        .background(Color.appAccent.ignoresSafeArea())
    }
} 