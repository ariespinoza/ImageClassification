//
//  ImageClassificationTests.swift
//  ImageClassificationTests
//
//  Created by Alumno on 24/10/25.
//

/*
import Foundation
import Testing
@testable import ScanML

final class MockURLProtocol: URLProtocol {
    static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.handler else {
            client?.urlProtocol(self, didFailWithError: NSError(domain: "no-handler", code: -1))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

extension URLSession {
    static func mocked() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }
}

// MARK: - Modelos mínimos para decodificar

struct UploadImageResponse: Codable, Equatable {
    let image_url: String
    let path: String
}

struct DiagnosisCreateResponse: Codable {
    let message: String
    let diagnosis_details: DiagnosisRow?
    let alerts_generated: Int?
}

struct DiagnosisRow: Codable, Equatable {
    let iddiagnostico: String?
    let imagen_url: String
    let diagnostico: String
    let idusuario: String?
}

struct DiagnosisListItem: Codable, Equatable {
    let iddiagnostico: String
    let imagen_url: String
    let fecha: String
    let idusuario: String
    let diagnostico: String
    let diagnostico_details: DiagnosticoDetails?

    enum CodingKeys: String, CodingKey {
        case iddiagnostico, imagen_url, fecha, idusuario, diagnostico
        case diagnostico_details = "diagnostico" // campo anidado del JOIN
    }
}

struct DiagnosticoDetails: Codable, Equatable {
    let descripcion: String?
    let causas: String?
    let prevencion: String?
    let tratamiento: String?
}

// MARK: - Cliente ligero para tests

struct PearAPI {
    let baseURL: URL
    let session: URLSession

    // POST /upload_image (multipart)
    func uploadImage(jpegData: Data, userId: String) async throws -> UploadImageResponse {
        var req = URLRequest(url: baseURL.appending(path: "/upload_image"))
        req.httpMethod = "POST"

        let boundary = "Boundary-\(UUID().uuidString)"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        func addField(name: String, value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        addField(name: "user_id", value: userId)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(jpegData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        req.httpBody = body

        let (data, _) = try await session.data(for: req)
        return try JSONDecoder().decode(UploadImageResponse.self, from: data)
    }

    // POST /diagnostic (JSON simple para test)
    func createDiagnosticJSON(idUsuario: String, diagnostico: String, imageURL: String) async throws -> DiagnosisCreateResponse {
        var req = URLRequest(url: baseURL.appending(path: "/diagnostic"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload: [String: Any] = [
            "idUsuario": idUsuario,
            "diagnostico": diagnostico,
            "imagen_url": imageURL
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: payload)
        let (data, _) = try await session.data(for: req)
        return try JSONDecoder().decode(DiagnosisCreateResponse.self, from: data)
    }

    // GET /diagnoses?idUsuario=...
    func listDiagnoses(idUsuario: String) async throws -> [DiagnosisListItem] {
        var comps = URLComponents(url: baseURL.appending(path: "/diagnoses"), resolvingAgainstBaseURL: false)!
        comps.queryItems = [URLQueryItem(name: "idUsuario", value: idUsuario)]
        let req = URLRequest(url: comps.url!)
        let (data, _) = try await session.data(for: req)
        return try JSONDecoder().decode([DiagnosisListItem].self, from: data)
    }
}

// MARK: - TESTS

struct ImageClassificationTests {

    // ---------- /upload_image ----------
    @Test("POST /upload_image — retorna image_url y path")
    func testUploadImageReturnsURLAndPath() async throws {
        let session = URLSession.mocked()
        let api = PearAPI(baseURL: URL(string: "https://pearcoflaskapi.onrender.com")!, session: session)

        // Stub response
        MockURLProtocol.handler = { request in
            #expect(request.url?.path == "/upload_image")
            #expect(request.httpMethod == "POST")
            // Comprobar cabecera multipart
            #expect(request.value(forHTTPHeaderField: "Content-Type")?.contains("multipart/form-data") == true)

            let body = """
            {"image_url":"https://supabase.../CoffeeDiagnosisPhotos/u1/img1.jpg","path":"u1/abc.jpg"}
            """.data(using: .utf8)!
            let resp = HTTPURLResponse(url: request.url!, statusCode: 201, httpVersion: nil, headerFields: ["Content-Type":"application/json"])!
            return (resp, body)
        }

        let result = try await api.uploadImage(jpegData: Data(repeating: 1, count: 10), userId: "u1")
        #expect(result.image_url.hasPrefix("https://supabase"))
        #expect(result.path.hasPrefix("u1/"))
    }

    // ---------- /diagnostic (JSON) ----------
    @Test("POST /diagnostic — inserta registro y genera alertas (JSON)")
    func testCreateDiagnosticJSON() async throws {
        let session = URLSession.mocked()
        let api = PearAPI(baseURL: URL(string: "https://pearcoflaskapi.onrender.com")!, session: session)

        MockURLProtocol.handler = { request in
            #expect(request.url?.path == "/diagnostic")
            #expect(request.httpMethod == "POST")
            #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")

            // Validar payload mínimo
            let json = try JSONSerialization.jsonObject(with: request.httpBody ?? Data()) as? [String: Any]
            #expect(json?["idUsuario"] as? String == "u1")
            #expect(json?["diagnostico"] as? String == "Roya")
            #expect((json?["imagen_url"] as? String)?.contains("/CoffeeDiagnosisPhotos/") == true)

            let body = """
            {
              "message": "Diagnóstico creado y alertas generadas exitosamente.",
              "diagnosis_details": {
                "iddiagnostico": "d-123",
                "imagen_url": "https://supabase.../CoffeeDiagnosisPhotos/u1/img1.jpg",
                "diagnostico": "Roya",
                "idusuario": "u1"
              },
              "alerts_generated": 2
            }
            """.data(using: .utf8)!
            let resp = HTTPURLResponse(url: request.url!, statusCode: 201, httpVersion: nil, headerFields: ["Content-Type":"application/json"])!
            return (resp, body)
        }

        let created = try await api.createDiagnosticJSON(idUsuario: "u1", diagnostico: "Roya", imageURL: "https://supabase.../CoffeeDiagnosisPhotos/u1/img1.jpg")
        #expect(created.message.contains("éxitosamente") || created.message.contains("exitosamente"))
        #expect(created.diagnosis_details?.diagnostico == "Roya")
        #expect(created.alerts_generated == 2)
    }

    // ---------- /diagnoses (GET) ----------
    @Test("GET /diagnoses — devuelve lista con detalles del diagnóstico")
    func testListDiagnoses() async throws {
        let session = URLSession.mocked()
        let api = PearAPI(baseURL: URL(string: "https://pearcoflaskapi.onrender.com")!, session: session)

        MockURLProtocol.handler = { request in
            #expect(request.url?.path == "/diagnoses")
            #expect(request.httpMethod == "GET")
            #expect(request.url?.query?.contains("idUsuario=u1") == true)

            let body = """
            [
              {
                "iddiagnostico":"d-1",
                "imagen_url":"https://supabase.../CoffeeDiagnosisPhotos/u1/a.jpg",
                "fecha":"2025-10-24T18:30:00Z",
                "idusuario":"u1",
                "diagnostico":"Roya",
                "diagnostico": { "descripcion":"...", "causas":"...", "prevencion":"...", "tratamiento":"..." }
              },
              {
                "iddiagnostico":"d-2",
                "imagen_url":"https://supabase.../CoffeeDiagnosisPhotos/u1/b.jpg",
                "fecha":"2025-10-24T18:40:00Z",
                "idusuario":"u1",
                "diagnostico":"Sano",
                "diagnostico": { "descripcion":"No hay enfermedad", "causas":null, "prevencion":null, "tratamiento":null }
              }
            ]
            """.data(using: .utf8)!
            let resp = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: ["Content-Type":"application/json"])!
            return (resp, body)
        }

        let list = try await api.listDiagnoses(idUsuario: "u1")
        #expect(list.count == 2)
        #expect(list.first?.diagnostico == "Roya")
        #expect(list.first?.diagnostico_details?.prevencion != nil)
        #expect(list.last?.diagnostico == "Sano")
    }

    // ---------- Errores útiles ----------
    @Test("POST /upload_image — maneja 403 RLS con mensaje claro")
    func testUploadImageHandlesRLS403() async throws {
        let session = URLSession.mocked()
        let api = PearAPI(baseURL: URL(string: "https://pearcoflaskapi.onrender.com")!, session: session)

        MockURLProtocol.handler = { request in
            let errorJSON = #"{"statusCode":403,"error":"Unauthorized","message":"new row violates row-level security policy"}"#
            let resp = HTTPURLResponse(url: request.url!, statusCode: 403, httpVersion: nil, headerFields: ["Content-Type":"application/json"])!
            return (resp, Data(errorJSON.utf8))
        }

        do {
            _ = try await api.uploadImage(jpegData: Data(repeating: 1, count: 10), userId: "u1")
            Issue.record("Se esperaba error 403 pero la llamada no falló")
        } catch {
            // Esperamos que tu capa de red lo propague; aquí basta con que lance.
            #expect(true) // llegó al catch
        }
    }
}


*/
