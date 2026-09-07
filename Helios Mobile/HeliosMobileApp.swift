//
//  HeliosMobileApp.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import SwiftUI
import CoreData


@main
struct Helios_MobileApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    let persistenceController = PersistenceController.shared
    
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(PushRegistrationManager.shared)
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
        }
    }
    
}
