import SwiftUI

struct PaywallView: View {
    @StateObject private var purchaseService = PurchaseService.shared
    @State private var showingAlert = false
    @State private var selectedPeriod: SubscriptionPeriod = .monthly
    var onClose: (() -> Void)? = nil
    
    enum SubscriptionPeriod: String, CaseIterable {
        case monthly = "Monthly"
        case yearly = "Yearly"
        
        var price: String {
            switch self {
            case .monthly: return "$4.99"
            case .yearly: return "$39.99"
            }
        }
        
        var savings: String? {
            switch self {
            case .monthly: return nil
            case .yearly: return "Save 33%"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Close button at top
            HStack {
                Spacer()
                if let onClose = onClose {
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                            .foregroundColor(.appAccent)
                            .padding(8)
                    }
                    .accessibilityLabel("Close Paywall")
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        #if SUBS_ENABLED
                        // PixieParticle animation would go here
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundColor(.appGreen)
                        #else
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.appGreen)
                        #endif
                        
                        Text("Unlock Unlimited Access")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.appBackground)
                            .multilineTextAlignment(.center)
                        
                        Text("Enjoy unlimited song views and premium features")
                            .font(.body)
                            .foregroundColor(.appBackground)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Benefits list
                    VStack(alignment: .leading, spacing: 16) {
                        Text("What you'll get:")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.appBackground)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            BenefitRow(icon: "infinity", text: "Unlimited daily song views")
                            BenefitRow(icon: "star.fill", text: "Premium song recommendations")
                            BenefitRow(icon: "heart.fill", text: "Unlimited favorites")
                            BenefitRow(icon: "arrow.down.circle.fill", text: "Offline song downloads")
                            BenefitRow(icon: "person.2.fill", text: "Family sharing support")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Subscription period toggle
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            ForEach(SubscriptionPeriod.allCases, id: \.self) { period in
                                Button(action: {
                                    selectedPeriod = period
                                }) {
                                    VStack(spacing: 4) {
                                        Text(period.rawValue)
                                            .font(.headline)
                                            .fontWeight(selectedPeriod == period ? .bold : .medium)
                                            .foregroundColor(.appBackground)
                                        
                                        Text(period.price)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.appBackground)
                                        
                                        if let savings = period.savings {
                                            Text(savings)
                                                .font(.caption)
                                                .foregroundColor(.appGreen)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 80)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedPeriod == period ? Color.appGreen.opacity(0.2) : Color.appAccent.opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(selectedPeriod == period ? Color.appGreen : Color.clear, lineWidth: 2)
                                            )
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // CTA Button
                    VStack(spacing: 12) {
                        Button(action: {
                            #if SUBS_ENABLED
                            if selectedPeriod == .monthly {
                                purchaseService.purchaseMonthly()
                            } else {
                                // TODO: Implement purchaseYearly() when StoreKit is enabled
                                purchaseService.purchaseMonthly()
                            }
                            #else
                            showingAlert = true
                            #endif
                        }) {
                            HStack {
                                Text("Start Free Trial")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                if selectedPeriod == .yearly {
                                    Text("(7 days)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appGreen)
                            .foregroundColor(.appBackground)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        Text("Cancel anytime. Terms apply.")
                            .font(.caption)
                            .foregroundColor(.appBackground.opacity(0.7))
                    }
                    
                    // Restore purchases
                    Button("Restore Purchases") {
                        #if SUBS_ENABLED
                        purchaseService.restorePurchases()
                        #else
                        showingAlert = true
                        #endif
                    }
                    .font(.subheadline)
                    .foregroundColor(.appGreen)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color.appText.ignoresSafeArea())
        .alert("Purchases Disabled", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text("Purchases are disabled in development builds. Enable SUBS_ENABLED to test StoreKit functionality.")
        }
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.appAccent)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundColor(.appBackground)
            
            Spacer()
        }
    }
}

struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(onClose: {})
    }
} 