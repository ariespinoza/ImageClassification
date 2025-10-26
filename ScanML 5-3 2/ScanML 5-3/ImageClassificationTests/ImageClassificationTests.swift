//
//  ImageClassificationTests.swift
//  ImageClassificationTests
//
//  Created by Alumno on 24/10/25.
//

import Foundation
import Testing
import UIKit
@testable import ScanML

// MARK: - Helpers (lógica pura)
fileprivate func normalize(_ s: String) -> String {
    s.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
}


fileprivate func mapToDBLabel(_ raw: String) -> String {
    switch normalize(raw) {
    case "broca": return "Broca"
    case "ojo de gallo": return "Ojo de gallo"
    case "roya": return "Roya"
    case "antracnosis": return "Antracnosis"
    case "sano": return "Sano"
    case "desconocido": return "Desconocido"
    default: return raw
    }
}

/// Genera una imagen mínima 1x1 para pruebas
fileprivate func tinyTestImage() -> UIImage {
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: 2, height: 2))
    return renderer.image { ctx in
        UIColor.systemGreen.setFill()
        ctx.fill(CGRect(x: 0, y: 0, width: 2, height: 2))
    }
}

// MARK: - Tests de integración LIVE contra Render
struct ImageClassificationLiveTests {

    // Reutiliza tu APIClient “real”
    let api = APIClient()

    // ---------- Lógica: normalize & map ----------
    @Test("normalize y mapToDBLabel convierten etiquetas al texto exacto de la BD")
    func testLabelMapping() async throws {
        #expect(normalize("  RoYa ") == "roya")
        #expect(mapToDBLabel("broca") == "Broca")
        #expect(mapToDBLabel("Ojo de gallo") == "Ojo de gallo")
        #expect(mapToDBLabel("Antracnosis") == "Antracnosis")
        #expect(mapToDBLabel("Sano") == "Sano")
        #expect(mapToDBLabel("Desconocido") == "Desconocido")
    }

    // ----------  POST /upload_image ----------
    @Test("LIVE /upload_image — retorna image_url y path")
    func testLiveUploadImage() async throws {
        let img = tinyTestImage()
        // Para no depender de FK, usamos un “user_id” libre (solo organiza carpeta de Storage)
        let userId = "integration-tests-\(UUID().uuidString.prefix(8))"

        let res = try await api.uploadImage(img, userId: String(userId))
        #expect(res.image_url.contains("/CoffeeDiagnosisPhotos/"))
        #expect(res.path.hasPrefix(String(userId) + "/"))
    }

    // ---------- POST /diagnostic (requiere usuario válido) ----------
    @Test("LIVE /diagnostic — crea diagnóstico con usuario válido")
    func testLiveCreateDiagnostic() async throws {
        // Intenta leer la variable; si no existe, usa un fallback conocido
        let envUser = ProcessInfo.processInfo.environment["PEARCO_TEST_USER_ID"]
        let testUserId = (envUser?.trimmingCharacters(in: .whitespacesAndNewlines)).flatMap { $0.isEmpty ? nil : $0 }
            ?? "2dc443aa-fdfb-4265-8130-53a39cdd57e0" // <-- TU UUID válido

        // 1) Subimos imagen
        let img = tinyTestImage()
        let up = try await api.uploadImage(img, userId: testUserId)

        // 2) Creamos diagnóstico (usa un valor EXACTO de diagnostico.enfermedad)
        let created = try await api.createDiagnostic(
            idUsuario: testUserId,
            diagnostico: "Roya",
            imagenURL: up.image_url
        )

        #expect(created.message.localizedCaseInsensitiveContains("diagnóstico"))
    }

    // ---------- POST /diagnostic (error 400 por imagen_url faltante) ----------
    @Test("LIVE /diagnostic — 400 si falta imagen_url (JSON)")
    func testLiveCreateDiagnosticMissingImageURL() async throws {
        // Para validar el 400 no necesitamos usuario real (el backend valida antes de FK)
        do {
            _ = try await api.createDiagnostic(
                idUsuario: "00000000-0000-0000-0000-000000000000",
                diagnostico: "Roya",
                imagenURL: "" // provoca el 400
            )
            Issue.record("Se esperaba error 400 por imagen_url vacía, pero la llamada no falló")
        } catch {
            // Esperamos un NSError con code = 400 desde throwIfBad
            let ns = error as NSError
            #expect(ns.code == 400)
        }
    }
}
