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
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @StateObject var exportViewModel: ExportViewModel = ExportViewModel()
    
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    @State private var showNext = false
    
    let sessions: FetchedResults<Session>
    
    var body: some View {
        ZStack {
            BackgroundColour()
                .ignoresSafeArea()
            
            VStack(spacing: 4) {
                Text("Select Sessions for Export")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    .padding(.top, 32)
                    .padding(.leading)
                
                VStack {
                    ScrollView {
                        ForEach(sessions) { session in
                            let selected = exportViewModel.selectedSessions.contains(session)
                            
                            SessionCardBase(item: session,
                                            pinned: false,
                                            sessionType: SessionType(rawValue: session.sessionType)!,
                                            name: session.name ?? "Unknown session name",
                                            scrambleType: Int(session.scrambleType),
                                            solveCount: 0,
                                            selected: selected,
                                            forExportUse: true)
                            .onTapGesture {
                                withAnimation(Animation.customDampedSpring) {
                                    if selected {
                                        exportViewModel.selectedSessions.remove(session)
                                    } else {
                                        exportViewModel.selectedSessions.insert(session)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationTitle("Export Sessions")
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .bottomTrailing) {
                NavigationLink(destination: ExportFlowPickFormats().environmentObject(exportViewModel), isActive: $showNext) { EmptyView() }
                
                CTButton(type: exportViewModel.selectedSessions.count == 0 ? .disabled : .coloured(nil), size: .large, onTapRun: { exportViewModel.exportFlowState = .pickingFormats
                    showNext = true
                }) {
                    HStack {
                        Text("Continue")
                        
                        Image(systemName: "arrow.forward")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                .if(!(UIDevice.deviceIsPad && hSizeClass == .regular)) { view in
                    view
                        .padding(.bottom, 58)
                        .padding(.bottom, UIDevice.hasBottomBar ? 0 : nil)
                }
                .if(UIDevice.deviceIsPad && hSizeClass == .regular) { view in
                    view
                        .padding(.bottom, 8)
                }
            }
        }
    }
}


struct ExportFlowPickFormats: View {
    @EnvironmentObject var exportViewModel: ExportViewModel
    @State var showFilePathSave = false
    
    @State private var showNext = false
    
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    
    var body: some View {
        let zippedArray = Array(zip(exportViewModel.allFormats.indices, exportViewModel.allFormats))
        
        ZStack {
            BackgroundColour()
                .ignoresSafeArea()
            
            VStack(spacing: 4) {
                Text("Select Export Types")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .bottomLeading)
                    .padding(.top, 32)
                    .padding(.leading)
                
                VStack {
                    ForEach(zippedArray, id: \.0) { (_, format) in
                        let indexInSelected = exportViewModel.selectedFormats.firstIndex(where: {$0 === format})
                        
                        HStack {
                            Text(format.getName())
                                .font(.title2.weight(.semibold))
                                .foregroundColor(Color("dark"))
                            
                            Spacer()
                            
                            if indexInSelected != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(Color("accent"), Color("overlay0"))
                                    .padding(.trailing, 8)
                            }
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(indexInSelected != nil ? Color("indent1") : Color("overlay0"))
                        )
                        .padding(.horizontal)
                        
                        .onTapGesture {
                            withAnimation(Animation.customDampedSpring) {
                                if let indexInSelected {
                                    exportViewModel.selectedFormats.remove(at: indexInSelected)
                                } else {
                                    exportViewModel.selectedFormats.append(format)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if case let ExportFlowState.finished(result) = exportViewModel.exportFlowState {
                    NavigationLink(destination: ExportFlowFinished(result: result).environmentObject(exportViewModel), isActive: Binding.constant(true)) { EmptyView() }
                }
                
                
                CTButton(type: exportViewModel.selectedFormats.count == 0 ? .disabled : .coloured(nil), size: .large, onTapRun: {
                    showFilePathSave = true
                    showNext = true
                }) {
                    HStack {
                        Text("Confirm Export")
                        
                        Image(systemName: "arrow.forward")
                    }
                }
                .padding(.horizontal)
                .if(!(UIDevice.deviceIsPad && hSizeClass == .regular)) { view in
                    view
                        .padding(.bottom, 58)
                        .padding(.bottom, UIDevice.hasBottomBar ? 0 : nil)
                }
                .if(UIDevice.deviceIsPad && hSizeClass == .regular) { view in
                    view
                        .padding(.bottom, 8)
                }
            }
        }
        .fileExporter(isPresented: $showFilePathSave, documents: exportViewModel.selectedFormats, contentType: .data ,onCompletion: { result in
            exportViewModel.finishExport(result: result)
        })
    }
}


struct ExportFlowFinished: View {
    @EnvironmentObject var exportViewModel: ExportViewModel
    
    var result: Result<[URL], Error>
    
    var body: some View {
        ZStack {
            BackgroundColour()
                .ignoresSafeArea()
            switch result {
            case .success:
                Text("Export Success!")
                
            case .failure(let failure):
                Text("Export failed: \(failure.localizedDescription)")
            }
        }
    }
}
