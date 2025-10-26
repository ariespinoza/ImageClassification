//
//  CameraScanView.swift
//  prueba
//
//  Created by Alumno on 11/01/24.
//


import SwiftUI
import Vision
import CoreImage

struct CameraScanView: View {
    
    let userId: String
    
    @StateObject private var vm: ScanViewModel
    @EnvironmentObject var predictionStatus: PredictionStatus
    @StateObject private var classifierViewModel = ClassifierViewModel()
    @StateObject private var adviceManager = AdviceManager()
    
    init(userId: String) {
        self.userId = userId
        _vm = StateObject(wrappedValue: ScanViewModel(userId: userId))
    }

    @State private var capturedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var diagnosisText: String = "Esperando diagnóstico…"
    @State private var showResult = false
    
    // Normaliza y define qué etiquetas son enfermedad
    private func normalize(_ s: String) -> String {
        s.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var diseaseLabels: Set<String> {
        ["roya", "broca", "ojo de gallo", "antracnosis"]
    }

     // mapeo a los nombres de la tabla de diagnosticos de la BD
    private func mapToDBLabel(_ raw: String) -> String {
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

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .center, spacing: 16) {
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

                    // Sección de diagnóstico con ShowSignView
                    VStack(alignment: .center, spacing: 8) {
                        Text("Diagnóstico")
                            .font(.title2).bold().multilineTextAlignment(.center)

                        // Utilizamos UI de resultado
                        ShowSignView(labelData: classifierViewModel.getPredictionData(label: predictionStatus.topLabel))
                            .onAppear {
                                // Asegurar que los datos de mydata.geojson estén cargados
                                if classifierViewModel.classifierData.isEmpty {
                                    classifierViewModel.loadJSON()
                                }
                            }
                    }
                    .padding(.horizontal, 90)
                    .padding(.vertical, 20)
                    .frame(maxWidth: 600)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    .id("diagnosis-section")
                    
                    
                    
                    // Bloque de recomendaciones y precauciones
                    if let advice = adviceManager.getAdvice(for: predictionStatus.topLabel), !predictionStatus.topLabel.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Fiabilidad: \(predictionStatus.topConfidence)")
                                .font(.title3).bold()
                            
                            if let prec = advice.precauciones {
                                Text("Precauciones:")
                                    .font(.headline)
                                ForEach(prec, id: \.self) { Text("• \($0)") }
                            }
                            
                            if let reco = advice.recomendaciones {
                                Text("Recomendaciones:")
                                    .font(.headline)
                                ForEach(reco, id: \.self) { Text("• \($0)") }
                            }
                            
                            let raw = predictionStatus.topLabel
                            if diseaseLabels.contains(normalize(raw)) {
                                Text("Para más información, consulta al asistente de voz Latte.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.horizontal, 70)
                        .padding(.bottom, 20)
                    }


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
            .overlay(alignment: .top) {
                if vm.isSaving {
                    ProgressView("Enviando…")
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.top, 8)
                }
            }
            .onAppear {
                
                // Asegurar datos
                if classifierViewModel.classifierData.isEmpty {
                    classifierViewModel.loadJSON()
                }
                
                adviceManager.loadAdvice()
                
                // Abrir cámara automáticamente al entrar si no hay imagen
                if capturedImage == nil {
                    isImagePickerPresented = true
                }
            }
            .sheet(isPresented: $isImagePickerPresented) {
                CameraPicker(capturedImage: $capturedImage,
                             isPresented: $isImagePickerPresented,
                             onCaptured: { image in
                    
                    classify(image: image)

                    // Scroll a la sección de diagnóstico
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation {
                            proxy.scrollTo("diagnosis-section", anchor: .top)
                        }
                    }
                })
            }
            // En cuanto cambie la etiqueta top después de clasificar enviamos al backend y a la BD
            .onChange(of: predictionStatus.topLabel) { _, newLabel in
                guard let image = capturedImage, !newLabel.isEmpty else { return }
                let labelForDB = mapToDBLabel(newLabel)
                Task {
                    await vm.uploadAndCreate(image: image, diagnostico: labelForDB)
                    showResult = true
                }
            }
            .alert("Resultado", isPresented: $showResult) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(vm.message ?? vm.error ?? "Listo")
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

            // Mapa de resultados
            let compiled: LivePredictionResults = Dictionary(uniqueKeysWithValues:
                observations.map { obs in
                    (obs.identifier, (basicValue: Double(obs.confidence),
                                      displayValue: String(format: "%.0f%%", obs.confidence * 100)))
                }
            )

            let top = observations.first
            let topLabel = top?.identifier ?? ""
            let topConf = String(format: "%.0f%%", (top?.confidence ?? 0) * 100)

            // Actualiza PredictionStatus 
            DispatchQueue.main.async {
                predictionStatus.setLivePrediction(with: compiled, label: topLabel, confidence: topConf)
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        try? handler.perform([request])
    }
}
