//
//  ImportExport.swift
//  CubeTime
//
//  Created by Tim Xie on 18/02/24.
//

import SwiftUI

struct ImportFlow: View {
    var body: some View {
        Text("IMPORT")
    }
}

struct ExportFlowPickSessions: View {
    @EnvironmentObject var exportViewModel: ExportViewModel
    
    
    let sessions: FetchedResults<Session>
    
    
    var body: some View {
        ForEach(sessions) { session in
            let selected = exportViewModel.selectedSessions.contains(session)
            HStack {
                Text(session.name ?? "UNKNOWN NAME")
                Spacer()
                Image(systemName: selected ? "checkmark.circle.fill" : "checkmark.circle")
            }
            .onTapGesture {
                if selected {
                    exportViewModel.selectedSessions.remove(session)
                } else {
                    exportViewModel.selectedSessions.insert(session)
                }
            }
        }
        .navigationTitle("Export Sessions")
        
        CTButton(type: exportViewModel.selectedSessions.count == 0 ? .disabled : .halfcoloured(nil), size: .large, onTapRun: { exportViewModel.exportFlowState = .pickingFormats }) {
            HStack {
                Text("Continue")
                
                Image(systemName: "arrow.forward")
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing)

    }
}

struct ExportFlowPickFormats: View {
    @EnvironmentObject var exportViewModel: ExportViewModel
    @State var showFilePathSave = false
    
    var body: some View {
        let zippedArray = Array(zip(exportViewModel.allFormats.indices, exportViewModel.allFormats))
        ForEach(zippedArray, id: \.0) { (_, format) in
//            let selected = exportViewModel.selectedFormats.contains(format)
            let indexInSelected = exportViewModel.selectedFormats.firstIndex(where: {$0 === format})
            HStack {
                Text(format.getName())
                Spacer()
                Image(systemName: indexInSelected != nil ? "checkmark.circle.fill" : "checkmark.circle")
            }
            .onTapGesture {
                if let indexInSelected {
                    exportViewModel.selectedFormats.remove(at: indexInSelected)
                } else {
                    exportViewModel.selectedFormats.append(format)
                }
            }
        }
        .navigationTitle("Export Sessions")
        
        CTButton(type: exportViewModel.selectedSessions.count == 0 ? .disabled : .halfcoloured(nil), size: .large, onTapRun: { showFilePathSave = true }) {
            HStack {
                Text("Confirm Export")
                
                Image(systemName: "arrow.forward")
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing)
        .fileExporter(isPresented: $showFilePathSave, documents: exportViewModel.selectedFormats, contentType: .data ,onCompletion: { result in
            exportViewModel.finishExport(result: result)
        })
    }
}


struct ExportFlowFinished: View {
    @EnvironmentObject var exportViewModel: ExportViewModel
    
    var result: Result<[URL], Error>
    
    var body: some View {
        switch result {
        case .success:
            Text("Export Success!")
        case .failure(let failure):
            Text("Export failed: \(failure.localizedDescription)")
        }
    }
}


struct ExportFlow: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @StateObject var exportViewModel: ExportViewModel = ExportViewModel()
    
    let sessions: FetchedResults<Session>
    
    var body: some View {
        VStack {
            switch exportViewModel.exportFlowState {
            case .pickingSessions:
                ExportFlowPickSessions(sessions: sessions)
            case .pickingFormats:
                ExportFlowPickFormats()
            case .finished(let result):
                ExportFlowFinished(result: result)
            }
        }
        .safeAreaInset(safeArea: .tabBar)
        .environmentObject(exportViewModel)
    }
}
