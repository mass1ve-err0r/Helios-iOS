//
//  NotificationRepository.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import CoreData


enum NotificationRepository {

    // Sets readAt once. An already-read record keeps its original timestamp.
    static func markReadIfNeeded(_ notification: StoredNotification, in context: NSManagedObjectContext) {
        guard notification.readAt == nil else { return }
        notification.readAt = Date()
        do { try context.save() } catch { context.rollback() }
    }
    
}
