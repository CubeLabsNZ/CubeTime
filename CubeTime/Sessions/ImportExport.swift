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

struct ExportFlow: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    @State private var selectedSessions = Set<Session>()
    
    var sessions: FetchedResults<Session>
    
    var body: some View {
        VStack {
            List(sessions, id: \.id, selection: $selectedSessions) { session in
                Text(session.name ?? "UNKNOWN NAME")
            }
            .navigationTitle("Export Sessions")
            
            NavigationLink(destination: ExportSelectExportType()) {
                CTButton(type: selectedSessions.count == 0 ? .disabled : .halfcoloured(nil), size: .large, onTapRun: { }) {
                    HStack {
                        Text("Continue")
                        
                        Image(systemName: "arrow.forward")
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing)
        }
        .environment(\.editMode, .constant(EditMode.active))
        .safeAreaInset(safeArea: .tabBar)
    }
}

struct ExportSelectExportType: View {
    var body: some View {
        Text("Select")
    }
}
