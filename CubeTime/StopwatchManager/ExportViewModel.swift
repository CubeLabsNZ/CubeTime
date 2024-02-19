//
//  ExportViewModel.swift
//  CubeTime
//
//  Created by rgn on 2/19/24.
//

import Foundation

enum ExportFlowState {
    case pickingSessions
    case pickingFormats
}

class ExportFormat {
    let name: String
    let supportsMultiSession: Bool
    
    init(name: String, supportsMultiSession: Bool) {
        self.name = name
        self.supportsMultiSession = supportsMultiSession
    }
}

let csvExportFormat = ExportFormat(name: "CSV (generic)", supportsMultiSession: false)
let twistyTimerExportFormat = ExportFormat(name: "Twisty Timer (CSV)", supportsMultiSession: true)
let csTimerJSONExportFormat = ExportFormat(name: "csTimer (JSON)", supportsMultiSession: true)

class ExportViewModel: ObservableObject {
    static let allFormats: [ExportFormat] = [csvExportFormat, twistyTimerExportFormat, csTimerJSONExportFormat]

    @Published var exportFlowState: ExportFlowState = .pickingSessions
    
    @Published var selectedSessions = Set<Session>()
    @Published var selectedFormats: [ExportFormat] = []
    
    init() {
        
    }
}
