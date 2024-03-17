//
//  ExportViewModel.swift
//  CubeTime
//
//  Created by rgn on 2/19/24.
//

import SwiftUI
import Foundation
import UniformTypeIdentifiers
import Combine

enum ExportFlowState {
    case pickingSessions
    case pickingFormats
    case finished(Result<[URL], Error>)
}
/*
protocol ExportFormat: ReferenceFileDocument {
// protocol ExportFormat: ReferenceFileDocument where Snapshot == Set<Session> {
    
    static var name: String { get }
    static var supportsMultiSession: Bool { get }
    var selectedSessions: Set<Session> { get set }
    init()
}
 */

// Don't even talk to me right now

class ExportFormat: ReferenceFileDocument {
    func getName() -> String {
        fatalError()
    }

    // This is a problem for when I do import :(
    static var readableContentTypes: [UTType] = [.data]
    
    required init(configuration: ReadConfiguration) throws {
        fatalError()
    }
    
    init() {}
    
    func fileWrapper(snapshot: Set<Session>, configuration: WriteConfiguration) throws -> FileWrapper {
        fatalError()
    }
    
    var selectedSessions: Set<Session> = []
    
    func snapshot(contentType: UTType) throws -> Set<Session> {
        return selectedSessions
    }
    
    
}

class CSVExportFormat: ExportFormat {
    override func getName() -> String {
        return "CSV (generic)"
    }
    
    static var _readableContentTypes: [UTType] = [.commaSeparatedText]
    
    override func fileWrapper(snapshot: Set<Session>, configuration: WriteConfiguration) throws -> FileWrapper {
        func doCSV(session: Session) -> FileWrapper {
            var csv = "Time,Comment,Scramble,Date"
            for case let solve as Solve in session.solves ?? [] {
                csv += "\n\(solve.time),\"\(solve.comment?.replacingOccurrences(of: "\"", with: "\"\"") ?? "")\",\(solve.scramble ?? ""),\(solve.date?.description ?? "")"
            }
            let wrapper = FileWrapper(regularFileWithContents: csv.data(using: .utf8)!)
            wrapper.preferredFilename = "CubeTime - \(session.name!).csv"
            return wrapper
        }
        
        if self.selectedSessions.count == 1 {
            return doCSV(session: self.selectedSessions.first!)
        } else {
            var wrappers: [String: FileWrapper] = [:]
            
            func getName(name: String) -> String {
                var name = "\(name).csv"
                var counter = 0
                while wrappers[name] != nil {
                    counter += 1
                    name = "\(name) (\(counter)).csv"
                }
                return name
            }
            
            for session in selectedSessions {
                let csv = doCSV(session: session)
                wrappers["\(session.name!).csv"] = csv
            }
            let wrapper = FileWrapper(directoryWithFileWrappers: wrappers)
            wrapper.preferredFilename = "CubeTime Export (CSV)"
            return wrapper
        }
    }
}

class CSTimerExportFormat: ExportFormat {
    override func getName() -> String {
        return "csTimer (JSON)"
    }

    static var _readableContentTypes: [UTType] = [.commaSeparatedText]
    
    override func fileWrapper(snapshot: Set<Session>, configuration: WriteConfiguration) throws -> FileWrapper {
        var exportData: [String: Any] = [:]
        var properties: [String: Any] = [:]
        var sessionData: [String: [String: Any]] = [:]
        
        for (idx, session) in self.selectedSessions.enumerated() {
            let solvesCSTimer = (session.solves?.allObjects as? [Solve] ?? []).map { solve in
                let pen = switch Penalty(rawValue: solve.penalty)! {
                case .none: 0
                case .dnf: -1
                case .plustwo: 2000
                }
                let time = Int(solve.time * 1000.0)
                // Yes, the format is really like this.
                return [[pen, time], solve.scramble ?? "", solve.comment ?? "", Int(solve.date!.timeIntervalSince1970)] as [any Encodable]
            }
            
            exportData["session\(idx+1)"] = solvesCSTimer
                        
            sessionData["\(idx+1)"] = [
                "name": "CubeTime Export - \(session.name ?? "")",
                "scrType": puzzleTypes[Int(session.scrambleType)].cstimerName
            ]
        }
        
        

        let sessionDataJson = try jsonSerialize(obj: sessionData)
        
        properties["sessionData"] = String(data: sessionDataJson, encoding: .utf8)
        
        
        exportData["properties"] = properties
        
        
        let exportDataJson = try jsonSerialize(obj: exportData)
                
        let wrapper = FileWrapper(regularFileWithContents: exportDataJson)
        wrapper.preferredFilename = "CubeTime Export (csTimer).json"
        return wrapper
    }
}

class ExportViewModel: ObservableObject {
    let allFormats: [ExportFormat] = [CSVExportFormat(), CSTimerExportFormat()]

    @Published var exportFlowState: ExportFlowState = .pickingSessions
    
    @Published var selectedSessions = Set<Session>()
    @Published var selectedFormats: [ExportFormat] = []
        
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        $selectedSessions
            .sink(receiveValue: { newValue in
                for format in self.allFormats {
                    format.selectedSessions = newValue
                }
            })
            .store(in: &cancellables)
    }
    
    func finishExport(result: Result<[URL], Error>) {
        self.exportFlowState = .finished(result)
    }
}
