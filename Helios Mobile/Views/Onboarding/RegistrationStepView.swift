//
//  RegistrationStepView.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import SwiftUI


struct RegistrationStepView: View {
    var onRegistered: () -> Void

    @Environment(PushRegistrationManager.self) private var manager

    @State private var deviceName = UIDevice.current.name
    @State private var registrationToken = ""
    @State private var serverURL = ""
    @State private var isShowingScanner = false

    private var canSubmit: Bool {
        !registrationToken.trimmingCharacters(in: .whitespaces).isEmpty
        && !serverURL.trimmingCharacters(in: .whitespaces).isEmpty
        && manager.state != .working
    }

    var body: some View {
        Form {
            Section("Device") {
                TextField("Device name", text: $deviceName)
            }

            Section("Registration") {
                HStack {
                    TextField("Registration token", text: $registrationToken)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button {
                        isShowingScanner = true
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                    }
                    .buttonStyle(.borderless)
                }
                TextField("Server URL", text: $serverURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.URL)
            }

            if case let .failure(message) = manager.state {
                Section {
                    Text(message).foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    Task {
                        await manager.register(
                            name: deviceName,
                            registrationToken: registrationToken,
                            serverURLString: serverURL
                        )
                        if manager.state == .success {
                            onRegistered()
                        }
                    }
                } label: {
                    HStack {
                        if manager.state == .working {
                            ProgressView()
                        }
                        Text("Register device").frame(maxWidth: .infinity)
                    }
                }
                //.buttonStyle(.borderedProminent)
                .disabled(!canSubmit)
            }
        }
        .navigationTitle("Connect device")
        .sheet(isPresented: $isShowingScanner) {
            QRScannerSheet { scanned in
                registrationToken = scanned
                isShowingScanner = false
            }
        }
    }
}


#Preview {
    RegistrationStepView(onRegistered: {})
        .environment(PushRegistrationManager.shared)
}
