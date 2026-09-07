//
//  DashboardView.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 07.09.26.
//
import SwiftUI


struct DashboardView: View {
    
    @State var currentTabIndex: Int = 0
    @State var pnFilter: PushNotificationFilter = .unread
    
    
    var body: some View {
        NavigationStack {
            TabView(selection: $currentTabIndex) {
                Tab("Received", systemImage: "tray.and.arrow.down.fill", value: 0) {
                    PushNotificationListView(showingRead: false)
                }
                                
                Tab("Read", systemImage: "checkmark", value: 1) {
                    PushNotificationListView(showingRead: true)
                }
            } /// TabView
            .navigationTitle("Helios")
            .navigationBarTitleDisplayMode( .inline)
        } /// NavigationStack
    }
}


#Preview {
    DashboardView()
}
