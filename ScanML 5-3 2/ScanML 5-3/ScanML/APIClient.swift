//
//  APIClient.swift
//  ScanML
//
//  Created by Alumno on 25/10/25.
//

import Foundation
import UIKit

struct UploadImageResponse: Codable { let image_url: String; let path: String }
struct DiagnosisInsertRow: Codable { let iddiagnostico: String?; let imagen_url: String; let diagnostico: String; let idusuario: String? }
struct CreateDiagnosticResponse: Codable { let message: String; let diagnosis_details: DiagnosisInsertRow?; let alerts_generated: Int? }

struct APIClient {
    let baseURL = URL(string: "https://pearcoflaskapi.onrender.com")!
    let session: URLSession = .shared

    func uploadImage(_ image: UIImage, userId: String) async throws -> UploadImageResponse {
        guard let jpeg = image.jpegData(compressionQuality: 0.85) else {
            throw NSError(domain: "api", code: -1, userInfo: [NSLocalizedDescriptionKey: "JPEG inválido"])
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
        try Self.throwIfBad(resp: resp, data: data)
        return try JSONDecoder().decode(UploadImageResponse.self, from: data)
    }

    func createDiagnostic(idUsuario: String, diagnostico: String, imagenURL: String) async throws -> CreateDiagnosticResponse {
        var req = URLRequest(url: baseURL.appending(path: "/diagnostic"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = ["idUsuario": idUsuario, "diagnostico": diagnostico, "imagen_url": imagenURL]
        req.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (data, resp) = try await session.data(for: req)
        try Self.throwIfBad(resp: resp, data: data)
        return try JSONDecoder().decode(CreateDiagnosticResponse.self, from: data)
    }

    static func throwIfBad(resp: URLResponse, data: Data) throws {
        guard let http = resp as? HTTPURLResponse, !(200..<300).contains(http.statusCode) else { return }
        let body = String(data: data, encoding: .utf8) ?? ""
        throw NSError(domain: "api", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"])
    }
}
