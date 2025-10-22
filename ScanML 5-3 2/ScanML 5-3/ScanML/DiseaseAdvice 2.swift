import Foundation

struct DiseaseAdvice: Codable {
    let label: String
    let precauciones: [String]?
    let recomendaciones: [String]?
}