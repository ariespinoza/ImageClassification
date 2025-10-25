//
//  APIClient.swift
//  ScanML
//
//  Created by Alumno on 25/10/25.
//

import Foundation
import UIKit

// --- Respuestas del backend ---
struct UploadImageResponse: Codable { let image_url: String; let path: String }

struct DiagnosisInsertRow: Codable {
    let iddiagnostico: String?
    let imagen_url: String
    let diagnostico: String
    let idusuario: String?
}

struct CreateDiagnosticResponse: Codable {
    let message: String
    let diagnosis_details: DiagnosisInsertRow?
    let alerts_generated: Int?
}

// --- Cliente ---
struct APIClient {
    // Cambia por tu base real si la mueves
    let baseURL = URL(string: "https://pearcoflaskapi.onrender.com")!
    let session: URLSession = .shared

    // 1) POST /upload_image (multipart)
    func uploadImage(_ image: UIImage, userId: String) async throws -> UploadImageResponse {
        guard let jpeg = image.jpegData(compressionQuality: 0.85) else {
            throw NSError(domain: "api", code: -1, userInfo: [NSLocalizedDescriptionKey: "No se pudo convertir la imagen a JPEG"])
        }
        var req = URLRequest(url: baseURL.appending(path: "/upload_image"))
        req.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func field(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        field("user_id", userId)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(jpeg)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        req.httpBody = body
        let (data, resp) = try await session.data(for: req)
        try APIClient.throwIfBad(resp: resp, data: data)
        return try JSONDecoder().decode(UploadImageResponse.self, from: data)
    }

    // 2) POST /diagnostic (JSON con claves en español)
    func createDiagnostic(idUsuario: String, diagnostico: String, imagenURL: String) async throws -> CreateDiagnosticResponse {
        var req = URLRequest(url: baseURL.appending(path: "/diagnostic"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["idUsuario": idUsuario, "diagnostico": diagnostico, "imagen_url": imagenURL]
        req.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (data, resp) = try await session.data(for: req)
        try APIClient.throwIfBad(resp: resp, data: data)
        return try JSONDecoder().decode(CreateDiagnosticResponse.self, from: data)
    }

    // (Opcional) 3) GET /diagnoses si luego montas galería
    func listDiagnoses(idUsuario: String, limit: Int = 50, offset: Int = 0) async throws -> Data {
        var comps = URLComponents(url: baseURL.appending(path: "/diagnoses"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [
            URLQueryItem(name: "idusuario", value: idUsuario),
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        let (data, resp) = try await session.data(from: comps.url!)
        try APIClient.throwIfBad(resp: resp, data: data)
        return data
    }

    // helper
    static func throwIfBad(resp: URLResponse, data: Data) throws {
        guard let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) else { return }
        throw NSError(domain: "api", code: http.statusCode,
                      userInfo: [NSLocalizedDescriptionKey: (String(data: data, encoding: .utf8) ?? "HTTP \(http.statusCode)")])
    }
}
