//
//  PredictionStatus.swift
//  Proyecto_Equipo1
//
//  Created by Alumno on 11/10/23.
//

import Foundation
import SwiftUI
import Vision

class PredictionStatus: ObservableObject {
    @Published var modelUrl = URL(fileURLWithPath: "")
    // TODO - replace with the name of your classifier
    @Published var modelObject = CoffeHealthClassifier_1()
    @Published var topLabel = ""
    @Published var topConfidence = ""
    
    // Live prediction results
    @Published var livePrediction: LivePredictionResults = [:]
    
    func setLivePrediction(with results: LivePredictionResults, label: String, confidence: String) {
        livePrediction = results
        topLabel = label
        topConfidence = confidence
    }
}

