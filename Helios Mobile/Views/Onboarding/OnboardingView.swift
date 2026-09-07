//
//  OnboardingView.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import SwiftUI


struct OnboardingView: View {
    
    @AppStorage("shouldShowOnboarding") private var shouldShowOnboarding = true
    @State private var step: Step = .welcome

    private enum Step { case welcome, registration, success }

    
    var body: some View {
        NavigationStack {
            switch step {
            case .welcome:
                WelcomeStepView { step = .registration }
            case .registration:
                RegistrationStepView { step = .success }
            case .success:
                SuccessStepView { shouldShowOnboarding = false }
            }
        }
    }
}


#Preview {
    OnboardingView()
}
