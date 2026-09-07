//
//  Persistence.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import CoreData


final class PersistenceController {

    static let shared = PersistenceController()

    private static let appGroupID = "group.software.baig.helios"

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        for _ in 0..<10 {
            let sample = StoredNotification(context: viewContext)
            sample.id = UUID().uuidString
            sample.receivedAt = Date()
            sample.readAt = nil
            sample.title = "Sample error"
            sample.body = "java.lang.NullPointerException at ..."
        }

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }

        return result
    }()

    let container: NSPersistentContainer

    private var historyToken: NSPersistentHistoryToken?
    private var remoteChangeObserver: NSObjectProtocol?

    private lazy var historyContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Helios_Mobile")

        let description: NSPersistentStoreDescription

        if inMemory {
            description = NSPersistentStoreDescription(
                url: URL(fileURLWithPath: "/dev/null")
            )
        } else {
            guard let groupURL = FileManager.default
                .containerURL(
                    forSecurityApplicationGroupIdentifier: Self.appGroupID
                )
            else {
                fatalError(
                    "App Group container not found: \(Self.appGroupID)"
                )
            }

            description = NSPersistentStoreDescription(
                url: groupURL.appending(path: "Helios_Mobile.sqlite")
            )
        }

        description.setOption(
            true as NSNumber,
            forKey: NSPersistentHistoryTrackingKey
        )

        description.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )

        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError(
                    "Unresolved error \(error), \(error.userInfo)"
                )
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy =
            NSMergeByPropertyObjectTrumpMergePolicy

        observeRemoteChanges()
    }

    deinit {
        if let remoteChangeObserver {
            NotificationCenter.default.removeObserver(remoteChangeObserver)
        }
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }

    private func observeRemoteChanges() {
        remoteChangeObserver = NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: nil
        ) { [weak self] _ in
            self?.processPersistentHistory()
        }
    }

    func processPersistentHistory() {
        historyContext.perform { [weak self] in
            guard let self else {
                return
            }

            do {
                let request =
                    NSPersistentHistoryChangeRequest.fetchHistory(
                        after: self.historyToken
                    )

                guard
                    let result = try self.historyContext.execute(request)
                        as? NSPersistentHistoryResult,
                    let transactions =
                        result.result
                        as? [NSPersistentHistoryTransaction],
                    !transactions.isEmpty
                else {
                    return
                }

                for transaction in transactions {
                    guard
                        let userInfo =
                            transaction.objectIDNotification().userInfo
                    else {
                        continue
                    }

                    NSManagedObjectContext.mergeChanges(
                        fromRemoteContextSave: userInfo,
                        into: [self.container.viewContext]
                    )
                }

                self.historyToken = transactions.last?.token
            } catch {
                print(
                    "Failed to process persistent history: \(error)"
                )
            }
        }
    }
    
}
