//
//  NotificationListView.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 07.09.26.
//
import SwiftUI


struct PushNotificationListView: View {
    
    @FetchRequest private var notifications: FetchedResults<StoredNotification>

    init(showingRead: Bool) {
        let predicate = showingRead
            ? NSPredicate(format: "readAt != nil")
            : NSPredicate(format: "readAt == nil")

        let sortKey = showingRead ? "readAt" : "receivedAt"

        _notifications = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(key: sortKey, ascending: false)
            ],
            predicate: predicate,
            animation: .default
        )
    }

    var body: some View {
        Group {
            if notifications.isEmpty {
                ContentUnavailableView("No Notifications", systemImage: "bell.slash")
            } else {
                List(notifications) { notification in
                    NavigationLink {
                        NotificationDetailView(notification: notification)
                    } label: {
                        NotificationCardView(notification: notification)
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(
                        EdgeInsets(
                            top: 7,
                            leading: 16,
                            bottom: 7,
                            trailing: 16
                        )
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.white)
            }
        }
    }
    
}
