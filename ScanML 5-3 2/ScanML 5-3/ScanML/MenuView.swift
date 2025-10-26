//
//  menuView.swift
//  prueba
//
//  Created by Alumno on 11/01/24.
//

 //Version 2 reto
import SwiftUI

struct MenuView: View {
    
    @State private var isPhotoTaken = false
    @State private var goToScan = false
    
    
    var body: some View {
        
        
        NavigationStack {
            ZStack {
                HStack(spacing: 0) {
                    ZStack {
                        
                        Color(UIColor.systemBackground)
                            .edgesIgnoringSafeArea(.all)
                        
                        HStack(spacing: 0) {
                            
                            
                            // Contenido principal
                            ScrollView {
                                VStack(spacing: 30) {
                                    
                                    // Título
                                    Text("Diagnóstico por Foto")
                                        .font(.system(size: 50, weight: .bold))
                                        .foregroundColor(Color.verdeTitulos)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Text("Centre la planta en la cámara para continuar")
                                        .font(.title2)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    // Imagen y botón de cámara
                                    ZStack {
                                        Image("CoffeePlant")
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 650, height: 700)
                                            .clipped()
                                            .cornerRadius(45)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 45)
                                                    .stroke(.black, lineWidth: 4)
                                            )
                                            .shadow(color: .black.opacity(0.4), radius: 50, x: 5, y: 5)
                                            .overlay(Color.white.opacity(isPhotoTaken ? 0.7 : 0)
                                                .cornerRadius(45)
                                            )
                                            .animation(.easeInOut(duration: 0.3), value: isPhotoTaken)
                                        
                                        Button {
                                            withAnimation { isPhotoTaken = true }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                withAnimation { isPhotoTaken = false }
                                                // Unificar: este mismo botón navega al escaneo
                                                goToScan = true
                                            }
                                        } label: {
                                            Image(systemName: "camera")
                                                .font(.system(size: 40))
                                                .foregroundColor(.white)
                                                .padding(30)
                                                .background(Color.black.opacity(0.3))
                                                .clipShape(Circle())
                                        }
                                    }
                                    
                                    let currentUserId = "18d7bd5e-d046-4e4f-9ef3-fe4c8a7877c7" // UUID de prueba

                                    // Botón “Escanear” (también navega)
                                    NavigationLink(destination: CameraScanView(userId: currentUserId), isActive: $goToScan) {
                                        Text("Escanear")
                                            .font(.title)
                                            .foregroundColor(.white)
                                            .font(Font.varButtonLabel)
                                            .padding()
                                            .frame(width: 300.0, height: 50.0)
                                            .background(Color.verdeBoton)
                                            .cornerRadius(20)
                                    }

                                    



                                    Spacer().frame(height: 150)
                                }
                                .padding(50)
                            }
                        }
                        MicrophoneButton(color: Color.verdeOscuro)
                    }
                }
                .greenSidebar()
            }
            .navigationTitle("Diagnóstico")
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


/*
import Foundation
import Testing
import UIKit
@testable import ImageClassification

// MARK: - Helpers (lógica pura)
fileprivate func normalize(_ s: String) -> String {
    s.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
}

/// Debe coincidir EXACTO con diagnostico.enfermedad en la BD
fileprivate func mapToDBLabel(_ raw: String) -> String {
    switch normalize(raw) {
    case "broca": return "Broca del café"
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
        #expect(mapToDBLabel("broca") == "Broca del café")
        #expect(mapToDBLabel("Ojo de gallo") == "Ojo de gallo")
        #expect(mapToDBLabel("Antracnosis") == "Antracnosis")
        #expect(mapToDBLabel("Sano") == "Sano")
        #expect(mapToDBLabel("Desconocido") == "Desconocido")
    }

    // ---------- LIVE: POST /upload_image ----------
    @Test("LIVE /upload_image — retorna image_url y path")
    func testLiveUploadImage() async throws {
        let img = tinyTestImage()
        // Para no depender de FK, usamos un “user_id” libre (solo organiza carpeta de Storage)
        let userId = "integration-tests-\(UUID().uuidString.prefix(8))"

        let res = try await api.uploadImage(img, userId: String(userId))
        #expect(res.image_url.contains("/CoffeeDiagnosisPhotos/"))
        #expect(res.path.hasPrefix(String(userId) + "/"))
    }

    // ---------- LIVE: POST /diagnostic (requiere usuario válido) ----------
    @Test("LIVE /diagnostic — crea diagnóstico con usuario válido")
    func testLiveCreateDiagnostic() async throws {
        // Lee el UUID real del usuario de la variable de entorno
        guard let testUserId = ProcessInfo.processInfo.environment["PEARCO_TEST_USER_ID"],
              !testUserId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            Issue.record("PEARCO_TEST_USER_ID no está definido — se omite este test LIVE.")
            return
        }

        // 1) Subimos imagen para obtener URL pública
        let img = tinyTestImage()
        let up = try await api.uploadImage(img, userId: testUserId)

        // 2) Creamos el diagnóstico (usa un valor que exista en diagnostico.enfermedad)
        let created = try await api.createDiagnostic(
            idUsuario: testUserId,
            diagnostico: "Roya",
            imagenURL: up.image_url
        )

        #expect(created.message.localizedCaseInsensitiveContains("diagnóstico creado"))
        // Comprobación mínima del payload
        #expect(created.diagnosis_details?.diagnostico == "Roya")
        #expect(created.diagnosis_details?.imagen_url == up.image_url)
    }

    // ---------- LIVE: POST /diagnostic (error 400 por imagen_url faltante) ----------
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
*/