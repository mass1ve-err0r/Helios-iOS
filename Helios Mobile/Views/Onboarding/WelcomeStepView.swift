//
//  WelcomeStepView.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import SwiftUI


struct WelcomeStepView: View {
    var onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 64))
                .foregroundStyle(.tint)
            Text("Welcome to Helios")
                .font(.largeTitle.bold())
            Text("Helios keeps you up to date with push notifications. Next, you will connect this device so it can receive them.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Spacer()
            Button(action: onContinue) {
                Text("Get started").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}


#Preview {
    WelcomeStepView(onContinue: {
        
    })
}
