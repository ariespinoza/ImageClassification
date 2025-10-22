import Foundation
import Combine

final class AdviceManager: ObservableObject {
    @Published var adviceList: [DiseaseAdvice] = []

    func loadAdvice() {
        guard let url = Bundle.main.url(forResource: "disease_advice 2", withExtension: "json") else {
            print("disease_advice.json no encontrado en el bundle")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            adviceList = try decoder.decode([DiseaseAdvice].self, from: data)
        } catch {
            print("Error cargando disease_advice 2.json:", error)
        }
    }

    func getAdvice(for label: String) -> DiseaseAdvice? {
        adviceList.first { $0.label.lowercased() == label.lowercased() }
    }
}
