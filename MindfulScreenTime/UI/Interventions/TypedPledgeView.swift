import SwiftUI

public struct TypedPledgeView: View {
    public let targetPledge: String
    public let onSuccess: () -> Void
    public let onCancel: () -> Void

    @State private var userInput: String = ""
    @FocusState private var isTextFieldFocused: Bool

    private let frictionManager = FrictionManager.shared

    public init(
        targetPledge: String = FrictionManager.defaultPledgeText,
        onSuccess: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.targetPledge = targetPledge
        self.onSuccess = onSuccess
        self.onCancel = onCancel
    }

    private var isValid: Bool {
        frictionManager.validatePledge(input: userInput)
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "hand.raised.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.orange)

            Text("Cam Kết Ý Thức")
                .font(.title2.weight(.bold))
                .foregroundColor(.white)

            Text("Bạn đã gia hạn nhiều lần liên tiếp. Hãy gõ lại chính xác câu dưới đây để xác nhận sự lựa chọn của bạn:")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 24)

            // Quote target container
            Text("\"\(targetPledge)\"")
                .font(.callout.italic().weight(.medium))
                .foregroundColor(.cyan)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal, 24)

            // Text input box
            TextField("Gõ lại câu trên vào đây...", text: $userInput)
                .focused($isTextFieldFocused)
                .padding()
                .background(Color.white.opacity(0.12))
                .cornerRadius(12)
                .foregroundColor(.white)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .padding(.horizontal, 24)

            Spacer()

            VStack(spacing: 12) {
                Button(action: {
                    if isValid {
                        onSuccess()
                    }
                }) {
                    Text("Xác nhận mở thêm 5 phút")
                        .font(.headline)
                        .foregroundColor(isValid ? .black : .white.opacity(0.4))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isValid ? Color.cyan : Color.white.opacity(0.15))
                        .cornerRadius(14)
                }
                .disabled(!isValid)

                Button(action: onCancel) {
                    Text("Dừng lại, quay về làm việc")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.vertical, 10)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.08, green: 0.1, blue: 0.14).ignoresSafeArea())
        .onAppear {
            isTextFieldFocused = true
        }
    }
}
