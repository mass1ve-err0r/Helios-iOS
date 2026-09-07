//
//  NotificationDetailView.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import SwiftUI


struct NotificationDetailView: View {
    
    @Environment(\.managedObjectContext) private var context
    @ObservedObject var notification: StoredNotification

    
    var body: some View {
        List {
            Section("Metadata") {
                if let title = notification.title { LabeledContent("Title", value: title) }
                if let subtitle = notification.subtitle { LabeledContent("Subtitle", value: subtitle) }
            }
            
            Section("Timestamps") {
                if let receivedAt = notification.receivedAt {
                    LabeledContent("Received", value: receivedAt.formatted(.dateTime))
                }
                if let readAt = notification.readAt {
                    LabeledContent("Read", value: readAt.formatted(.dateTime))
                }
            }
            
            Section("Message") {
                if let body = notification.body {
                    Text(body)
                        .font(.system(.footnote, design: .monospaced))
                        .textSelection(.enabled)
                }
            }
            
            if let payload = notification.payloadJSON {
                Section("Raw APN Payload") {
                    Text(payload)
                        .font(.system(.footnote, design: .monospaced))
                        .textSelection(.enabled)
                }
            }
        }
        .navigationTitle(notification.title ?? "Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Stamps readAt once. Opening an already-read item does not change it — same call, both tabs.
            NotificationRepository.markReadIfNeeded(notification, in: context)
        }
    }
    
}
