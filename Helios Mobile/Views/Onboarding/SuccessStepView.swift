//
//  SuccessStepView.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import SwiftUI


struct SuccessStepView: View {
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.green)
            Text("You're all set")
                .font(.largeTitle.bold())
            Text("This device is registered and will now receive push notifications.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            Spacer()
            Button(action: onDone) {
                Text("OK").frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
}
