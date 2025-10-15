//
//  CameraScanView.swift
//  prueba
//
//  Created by Alumno on 11/01/24.
//

/*
import SwiftUI

struct CameraScanView: View {
    @EnvironmentObject var predictionStatus: PredictionStatus
    @StateObject var classifierViewModel = ClassifierViewModel()
    private(set) var labelData: Classification
    
    @State private var scan = "Safe&Unkown"
    @State private var capturedImage: UIImage?
    @State private var scanResult: String?
    //@State private var advice: String?
    
    @State private var isPhotoTaken = false
    
    var body: some View {
        let predictionLabel = predictionStatus.topLabel
        
        VStack {
            GeometryReader { geo in
                
                ZStack(alignment: .center){
                    Color(.white).ignoresSafeArea()
                    
                    VStack(alignment: .center){
                        
                        VStack() {
                            ShowSignView(labelData: classifierViewModel.getPredictionData(label: predictionLabel))
                        }
                        
                        VStack() {
                            LiveCameraRepresentable() {
                                predictionStatus.setLivePrediction(with: $0, label: $1, confidence: $2)
                            }
                            .frame(width: geo.size.width * 0.5)
                            
                            
                            
                        }// VStack
                        .onAppear(perform: classifierViewModel.loadJSON)
                        
                        
                    }//VStack
                    
                }//ZStack
            } //Geo
            .greenSidebar()
        }
    }
}

struct CameraScanViewPreviews: PreviewProvider {
    static var previews: some View {
        CameraScanView(labelData: Classification())
    }
}


 */


/*
import SwiftUI

struct CameraScanView: View {
    @State private var capturedImage: UIImage?
    @State private var isImagePickerPresented = false

    // Estado para diagnóstico (conéctalo a tu modelo real)
    @State private var diagnosisText: String = "Esperando diagnóstico…"

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    // Zona de preview
                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 600)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                    } else {
                        // Tip: mientras no haya foto, mostramos un placeholder simple
                        Text("Apunta a la hoja y toma una foto")
                            .font(.headline)
                            .padding(.top, 24)
                    }

                    // Sección de diagnóstico
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Diagnóstico")
                            .font(.title2).bold()
                        Text(diagnosisText)
                            .font(.body)
                            .padding(.vertical, 4)
                    }
                    .padding()
                    .frame(maxWidth: 600)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    .id("diagnosis-section")

                    // Opcional: botón para repetir captura
                    if capturedImage != nil {
                        Button {
                            isImagePickerPresented = true
                        } label: {
                            Text("Volver a tomar")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: 300)
                                .background(Color.verdeBoton)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.bottom, 32)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            // Abrir cámara inmediatamente al entrar
            .onAppear {
                // Abre solo si aún no hay imagen
                if capturedImage == nil {
                    isImagePickerPresented = true
                }
            }
            // Presentación de la cámara
            .sheet(isPresented: $isImagePickerPresented) {
                CameraPicker(capturedImage: $capturedImage,
                             isPresented: $isImagePickerPresented,
                             onCaptured: { image in
                    // 1) Aquí puedes llamar a tu modelo de ML para clasificar.
                    //    Reemplaza este mock por tu pipeline real:
                    self.diagnosisText = analizar(image: image)

                    // 2) Hacemos scroll hacia la sección de diagnóstico
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation {
                            proxy.scrollTo("diagnosis-section", anchor: .top)
                        }
                    }
                })
            }
            .navigationTitle("Escaneo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Mock de análisis: conecta tu modelo y devuelve "broca", "ojo de gallo", "antracnosis" o "roya"
    private func analizar(image: UIImage) -> String {
        // TODO: reemplazar por tu clasificador actual
        // Por ahora devolvemos un placeholder:
        return "Resultado: Roya (confianza 0.92)."
    }
}

 */



import SwiftUI
import Vision
import CoreImage

struct CameraScanView: View {
    @EnvironmentObject var predictionStatus: PredictionStatus
    @StateObject private var classifierViewModel = ClassifierViewModel()

    @State private var capturedImage: UIImage?
    @State private var isImagePickerPresented = false

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    // Preview de la foto
                    if let image = capturedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: 600)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .padding(.horizontal)
                    } else {
                        Text("Apunta a la hoja y toma una foto")
                            .font(.headline)
                            .padding(.top, 24)
                    }

                    // Sección de diagnóstico con ShowSignView (usa tu pipeline existente)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Diagnóstico")
                            .font(.title2).bold().multilineTextAlignment(.center)

                        // Reutilizamos exactamente tu UI de resultado
                        ShowSignView(labelData: classifierViewModel.getPredictionData(label: predictionStatus.topLabel))
                            .onAppear {
                                // Asegurar que los datos de mydata.geojson estén cargados
                                if classifierViewModel.classifierData.isEmpty {
                                    classifierViewModel.loadJSON()
                                }
                            }
                    }
                    .padding(.horizontal, 70)
                    .frame(maxWidth: 600)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    .id("diagnosis-section")

                    if capturedImage != nil {
                        Button {
                            isImagePickerPresented = true
                        } label: {
                            Text("Volver a tomar")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: 300)
                                .background(Color.verdeBoton)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.bottom, 32)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .onAppear {
                // Abrir cámara automáticamente al entrar si no hay imagen
                if capturedImage == nil {
                    // Asegurar datos
                    if classifierViewModel.classifierData.isEmpty {
                        classifierViewModel.loadJSON()
                    }
                    isImagePickerPresented = true
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                CameraPicker(capturedImage: $capturedImage,
                             isPresented: $isImagePickerPresented,
                             onCaptured: { image in
                    // Clasificamos con el mismo modelo que usabas en vivo
                    classify(image: image)

                    // Scroll a la sección de diagnóstico
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation {
                            proxy.scrollTo("diagnosis-section", anchor: .top)
                        }
                    }
                })
            }
            .navigationTitle("Escaneo")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func classify(image: UIImage) {
        guard let ciImage = CIImage(image: image) else { return }

        // Usa el mismo modelo que PredictionStatus (CoffeePlantClassifier_)
        guard let vnModel = try? VNCoreMLModel(for: predictionStatus.modelObject.model) else { return }

        let request = VNCoreMLRequest(model: vnModel) { req, _ in
            let observations = (req.results as? [VNClassificationObservation]) ?? []

            // Mapa de resultados como en LiveCamera
            let compiled: LivePredictionResults = Dictionary(uniqueKeysWithValues:
                observations.map { obs in
                    (obs.identifier, (basicValue: Double(obs.confidence),
                                      displayValue: String(format: "%.0f%%", obs.confidence * 100)))
                }
            )

            let top = observations.first
            let topLabel = top?.identifier ?? ""
            let topConf = String(format: "%.0f%%", (top?.confidence ?? 0) * 100)

            // Actualiza PredictionStatus igual que LiveCameraRepresentable
            DispatchQueue.main.async {
                predictionStatus.setLivePrediction(with: compiled, label: topLabel, confidence: topConf)
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([request])
    }
}
