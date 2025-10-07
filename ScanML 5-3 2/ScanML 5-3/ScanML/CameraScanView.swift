//
//  CameraScanView.swift
//  prueba
//
//  Created by Alumno on 11/01/24.
//
import SwiftUI

struct CameraScanView: View {
    @EnvironmentObject var predictionStatus: PredictionStatus
    @StateObject var classifierViewModel = ClassifierViewModel()
    private(set) var labelData: Classification
    
    @State private var scan = "Safe&Unkown"
    @State private var capturedImage: UIImage?
    
    var body: some View {
        let predictionLabel = predictionStatus.topLabel
        
        HStack(spacing: 0) {
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
        }
        .greenSidebar()
    }
}

struct CameraScanViewPreviews: PreviewProvider {
    static var previews: some View {
        CameraScanView(labelData: Classification())
    }
}


 

