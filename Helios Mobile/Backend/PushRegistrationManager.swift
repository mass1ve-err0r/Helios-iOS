//
//  PushRegistrationManager.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import Foundation
import UIKit
import UserNotifications
import Observation


@MainActor
@Observable
final class PushRegistrationManager {

    static let shared = PushRegistrationManager()

    enum RegistrationState: Equatable {
        case idle
        case working
        case success
        case failure(String)
    }

    private(set) var state: RegistrationState = .idle

    private var tokenContinuation: CheckedContinuation<String, Error>?

    // ASSUMPTION: adjust to your actual controller route.
    private static let registrationPath = "/api/devices/register"

    private init() { }

    // MARK: - Called from AppDelegate

    func didRegisterForRemoteNotifications(deviceTokenHex: String) {
        tokenContinuation?.resume(returning: deviceTokenHex)
        tokenContinuation = nil
    }

    func didFailToRegisterForRemoteNotifications(error: Error) {
        tokenContinuation?.resume(throwing: error)
        tokenContinuation = nil
    }

    // MARK: - Public API

    func register(name: String, registrationToken: String, serverURLString: String) async {
        state = .working
        do {
            guard let endpoint = Self.makeEndpoint(from: serverURLString) else {
                state = .failure("The server URL is not valid.")
                return
            }
            let deviceToken = try await obtainDeviceToken()
            try await postRegistration(
                endpoint: endpoint,
                name: name,
                registrationToken: registrationToken,
                deviceToken: deviceToken
            )
            state = .success
        } catch {
            state = .failure(Self.message(for: error))
        }
    }

    // MARK: - Device token

    private func obtainDeviceToken() async throws -> String {
        let center = UNUserNotificationCenter.current()
        let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        guard granted else { throw RegistrationError.authorizationDenied }
        guard tokenContinuation == nil else { throw RegistrationError.alreadyInProgress }

        return try await withCheckedThrowingContinuation { continuation in
            tokenContinuation = continuation
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    // MARK: - Networking

    private func postRegistration(
        endpoint: URL,
        name: String,
        registrationToken: String,
        deviceToken: String
    ) async throws {
        let payload = RegisterReceiverRequest(
            name: name,
            token: deviceToken,
            registrationToken: registrationToken
        )

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
        request.setBasicAuth(username: "device-registration-ios", password: "some-secret")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw RegistrationError.server("The server did not return an HTTP response.")
        }
        guard (200..<300).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw RegistrationError.server("The server returned status \(http.statusCode). \(body)")
        }
    }

    // MARK: - Helpers

    private static func makeEndpoint(from urlString: String) -> URL? {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, var url = URL(string: trimmed) else { return nil }
        url.append(path: registrationPath)
        return url
    }

    private static func message(for error: Error) -> String {
        if let registrationError = error as? RegistrationError {
            return registrationError.errorDescription ?? "Registration failed."
        }
        return error.localizedDescription
    }

    enum RegistrationError: LocalizedError {
        case authorizationDenied
        case alreadyInProgress
        case server(String)

        var errorDescription: String? {
            switch self {
            case .authorizationDenied:
                return "Notifications are turned off. Allow notifications to register this device."
            case .alreadyInProgress:
                return "A registration attempt is already in progress."
            case .server(let message):
                return message
            }
        }
    }
    
}
