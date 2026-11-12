import SwiftUI

public struct BreathingExerciseView: View {
    public let seconds: Int
    public let onComplete: () -> Void

    @State private var remainingSeconds: Int
    @State private var isExhaling: Bool = false
    @State private var timer: Timer?

    private let haptic = UIImpactFeedbackGenerator(style: .soft)

    public init(seconds: Int = 5, onComplete: @escaping () -> Void) {
        self.seconds = seconds
        self._remainingSeconds = State(initialValue: seconds)
        self.onComplete = onComplete
    }

    public var body: some View {
        VStack(spacing: 36) {
            Text("Dừng lại và hít thở sâu")
                .font(.title2.weight(.semibold))
                .foregroundColor(.white)

            ZStack {
                // Background ambient glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color.cyan.opacity(0.35), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 130
                        )
                    )
                    .frame(width: 260, height: 260)

                // Animated pulsing breathing circle
                Circle()
                    .stroke(LinearGradient(colors: [.teal, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 4)
                    .frame(width: isExhaling ? 110 : 200, height: isExhaling ? 110 : 200)
                    .animation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true), value: isExhaling)

                VStack(spacing: 6) {
                    Text("\(remainingSeconds)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(isExhaling ? "Thở ra chậm..." : "Hít vào sâu...")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            Text("Hãy dành một khoảnh khắc tĩnh tâm trước khi tiếp tục")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.08, green: 0.1, blue: 0.14).ignoresSafeArea())
        .onAppear {
            haptic.prepare()
            haptic.impactOccurred()
            isExhaling = false

            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                if remainingSeconds > 1 {
                    remainingSeconds -= 1
                    // Alternate breathing phase every 3-4s
                    if remainingSeconds % 4 == 0 {
                        isExhaling.toggle()
                    }
                    haptic.impactOccurred(intensity: 0.6)
                } else {
                    timer?.invalidate()
                    timer = nil
                    haptic.impactOccurred(intensity: 1.0)
                    onComplete()
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}
