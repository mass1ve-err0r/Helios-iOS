//
//  NotificationPersister.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import CoreData
import UserNotifications


enum NotificationPersister {

    // Upserts by id. An existing record is left untouched, so read state survives.
    @discardableResult
    static func persist(request: UNNotificationRequest, into context: NSManagedObjectContext) -> Bool {
        let content = request.content
        let userInfo = content.userInfo
        let id = (userInfo["id"] as? String) ?? request.identifier

        var didInsert = false
        context.performAndWait {
            let fetch = NSFetchRequest<StoredNotification>(entityName: "StoredNotification")
            fetch.predicate = NSPredicate(format: "id == %@", id)
            fetch.fetchLimit = 1

            if let existing = try? context.fetch(fetch), existing.first != nil {
                return
            }

            let record = StoredNotification(context: context)
            record.id = id
            record.receivedAt = Date()
            record.readAt = nil
            record.title = content.title.isEmpty ? nil : content.title
            record.subtitle = content.subtitle.isEmpty ? nil : content.subtitle
            record.body = content.body.isEmpty ? nil : content.body
            record.topic = userInfo["topic"] as? String
            record.payloadJSON = Self.jsonString(from: userInfo)

            do {
                try context.save()
                didInsert = true
            } catch {
                context.rollback()
            }
        }
        return didInsert
    }

    private static func jsonString(from userInfo: [AnyHashable: Any]) -> String? {
        let sanitized = userInfo.reduce(into: [String: Any]()) { result, pair in
            if let key = pair.key as? String { result[key] = pair.value }
        }
        guard JSONSerialization.isValidJSONObject(sanitized),
              let data = try? JSONSerialization.data(withJSONObject: sanitized, options: [.prettyPrinted]) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
}
