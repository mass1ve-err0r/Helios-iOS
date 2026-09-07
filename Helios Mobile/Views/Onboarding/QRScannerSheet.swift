//
//  QRScannerSheet.swift
//  Helios Mobile
//
//  Created by Saadat Baig on 05.09.26.
//
import SwiftUI
import VisionKit
import AVFoundation
internal import Vision


struct QRScannerSheet: View {
    var onScan: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var cameraAuthorized = false
    @State private var unavailableReason: String?

    var body: some View {
        NavigationStack {
            Group {
                if let reason = unavailableReason {
                    ContentUnavailableView(
                        "Camera unavailable",
                        systemImage: "camera.fill",
                        description: Text(reason)
                    )
                } else if cameraAuthorized {
                    QRScannerView(onScan: onScan)
                        .ignoresSafeArea()
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Scan QR code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .task { await prepareCamera() }
    }

    private func prepareCamera() async {
        guard DataScannerViewController.isSupported else {
            unavailableReason = "This device cannot scan codes."
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraAuthorized = true
        case .notDetermined:
            cameraAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            if !cameraAuthorized {
                unavailableReason = "Camera access was not granted."
            }
        default:
            unavailableReason = "Camera access is turned off. Enable it in Settings to scan a code."
        }
    }
}

struct QRScannerView: UIViewControllerRepresentable {
    var onScan: (String) -> Void

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [ .qr])],
            qualityLevel: .balanced,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        try? uiViewController.startScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan)
    }

    final class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let onScan: (String) -> Void
        private var didScan = false

        init(onScan: @escaping (String) -> Void) {
            self.onScan = onScan
        }

        func dataScanner(
            _ dataScanner: DataScannerViewController,
            didAdd addedItems: [RecognizedItem],
            allItems: [RecognizedItem]
        ) {
            guard !didScan else { return }
            for item in addedItems {
                if case let .barcode(barcode) = item, let value = barcode.payloadStringValue {
                    didScan = true
                    dataScanner.stopScanning()
                    onScan(value)
                    break
                }
            }
        }
    }
}
