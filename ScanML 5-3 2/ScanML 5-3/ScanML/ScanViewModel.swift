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
    @Published var isSaving = false
    @Published var message: String?
    @Published var error: String?

    private let api = APIClient()
    let userId: String

    init(userId: String) { self.userId = userId }

    func uploadAndCreate(image: UIImage, diagnostico: String) async {
        isSaving = true; defer { isSaving = false }
        message = nil; error = nil
        do {
            let up = try await api.uploadImage(image, userId: userId)
            let created = try await api.createDiagnostic(idUsuario: userId, diagnostico: diagnostico, imagenURL: up.image_url)
            message = created.message
        } catch {
            self.error = error.localizedDescription
        }
    }
}


