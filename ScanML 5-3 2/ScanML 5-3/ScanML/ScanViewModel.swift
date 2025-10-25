//
//  ScanViewModel.swift
//  ScanML
//
//  Created by Alumno on 25/10/25.
//

import Foundation
import UIKit

@MainActor
final class ScanViewModel: ObservableObject {
    @Published var isUploading = false
    @Published var lastError: String?
    @Published var serverMessage: String?

    private let api = APIClient()
    let userId: String

    init(userId: String) { self.userId = userId }

    /// Llama esto cuando YA tienes la foto y el diagnóstico (string exacto).
    func sendCapture(image: UIImage, diagnostico: String) async {
        isUploading = true; defer { isUploading = false }
        lastError = nil; serverMessage = nil
        do {
            let up = try await api.uploadImage(image, userId: userId)              // 1) sube y obtiene URL
            let created = try await api.createDiagnostic(idUsuario: userId,        // 2) guarda en DB + alertas
                                                         diagnostico: diagnostico,
                                                         imagenURL: up.image_url)
            serverMessage = created.message
        } catch {
            lastError = error.localizedDescription
        }
    }
}

