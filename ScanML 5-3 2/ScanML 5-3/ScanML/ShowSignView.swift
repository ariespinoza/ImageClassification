//
//  ShowSignView.swift
//  Proyecto_Equipo1
//
//  Created by Alumno on 15/10/23.
//

import SwiftUI

struct ShowSignView: View {
    private(set) var labelData: Classification
    
    var body: some View {
        VStack(alignment: .center){
            
            Text(labelData.label.capitalized)
                .multilineTextAlignment(.center)
                .font(Font
                    .custom("Chapeau-Medium", size: 20))
                .foregroundColor(Color.verdeOscuro)
            
                
        }
        .padding(.horizontal, 20)
    }
       
}

struct ShowSignView_Previews: PreviewProvider {
    static var previews: some View {
        ShowSignView(labelData: Classification())
    }
}
