//
//  RootView.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import SwiftUI


struct RootView: View {
    @AppStorage("shouldShowOnboarding") private var shouldShowOnboarding = true

    var body: some View {
        if shouldShowOnboarding {
            OnboardingView()
        } else {
            DashboardView()
        }
    }
}
