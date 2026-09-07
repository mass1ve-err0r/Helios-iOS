//
//  NotificationCardView.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import CoreData
import SwiftUI


struct NotificationCardView: View {
    
    @ObservedObject var notification: StoredNotification

    private var isUnread: Bool {
        notification.readAt == nil
    }

    
    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            icon

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(notification.title ?? "Notification")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    if isUnread {
                        Circle()
                            .fill( .red)
                            .frame(width: 8, height: 8)
                            .shadow(color: .blue.opacity(0.35), radius: 4)
                    }
                }

                if let body = notification.body,
                   !body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(body)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 6) {
                    if let receivedAt = notification.receivedAt {
                        Image(systemName: "clock")
                            .font(.caption2)

                        Text(
                            receivedAt,
                            format: .dateTime
                                .day()
                                .month(.abbreviated)
                                .hour()
                                .minute()
                        )
                        .font(.caption)
                    }

                    if let topic = notification.topic,
                       !topic.isEmpty {
                        Text("•")
                            .font(.caption)

                        Text(topic)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            glassBackground
        }
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var icon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.16),
                            Color.indigo.opacity(0.10),
                            Color.white.opacity(0.7)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.9), lineWidth: 1)

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 17, weight: .semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.blue)
        }
        .frame(width: 46, height: 46)
        .shadow(
            color: Color.blue.opacity(0.10),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    private var glassBackground: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(isUnread ? 0.075 : 0.035),
                            Color.indigo.opacity(isUnread ? 0.045 : 0.020),
                            Color.white.opacity(0.62)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color.blue.opacity(0.14),
                            Color.white.opacity(0.75)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            if isUnread {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.blue.opacity(0.07), lineWidth: 3)
                    .blur(radius: 5)
                    .padding(2)
            }
        }
        .shadow(
            color: Color.black.opacity(0.055),
            radius: 14,
            x: 0,
            y: 7
        )
        .shadow(
            color: Color.blue.opacity(0.045),
            radius: 22,
            x: 0,
            y: 8
        )
    }
}


#Preview {
    PushNotificationListView(showingRead: false)
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
