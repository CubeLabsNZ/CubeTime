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
import ZIPFoundation
import libxml2

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

#warning("TODO: somehow minifiy without killing readability")

let metaInf = ##"""
<?xml version="1.0" encoding="UTF-8"?>
<manifest:manifest xmlns:manifest="urn:oasis:names:tc:opendocument:xmlns:manifest:1.0" manifest:version="1.2">
 <manifest:file-entry manifest:full-path="/" manifest:version="1.2" manifest:media-type="application/vnd.oasis.opendocument.spreadsheet"/>
 <manifest:file-entry manifest:full-path="content.xml" manifest:media-type="text/xml"/>
 <manifest:file-entry manifest:full-path="styles.xml" manifest:media-type="text/xml"/>
</manifest:manifest>
"""##.data(using: .utf8)!

let styles = ##"""
<?xml version="1.0" encoding="UTF-8"?>
<office:document-styles xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0">'
  <office:styles>
    <number:date-style style:name="NUMFMT_DATE">
      <number:month/>
      <number:text>/</number:text>
      <number:day/>
      <number:text>/</number:text>
      <number:year number:style="long"/>
      <number:text> </number:text>
      <number:hours/>
      <number:text>:</number:text>
      <number:minutes number:style="long"/>
      <number:text> </number:text>
      <number:am-pm/>
    </number:date-style>
  </office:styles>
</office:document-styles>
"""##.data(using: .utf8)!

/*
 <manifest:file-entry manifest:full-path="Thumbnails/thumbnail.png" manifest:media-type="image/png"/>
 <manifest:file-entry manifest:full-path="meta.xml" manifest:media-type="text/xml"/>
 <manifest:file-entry manifest:full-path="manifest.rdf" manifest:media-type="application/rdf+xml"/>
*/

/*
 */
 

class ODSExportFormat: ExportFormat {
    override func getName() -> String {
        return "ODF (MS Excel/Google Sheets)"
    }
    
    static var _readableContentTypes: [UTType] = [.zip]
    
    override func fileWrapper(snapshot: Set<Session>, configuration: WriteConfiguration) throws -> FileWrapper {
        // TODO: thumbnail
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        // Keep in sync with style above!
        let dateFormatterPretty = DateFormatter()
        dateFormatterPretty.locale = Locale(identifier: "en_US_POSIX")
        dateFormatterPretty.dateFormat = "M/d/yyyy h:mm a"

        
        let archive = try Archive(accessMode: .create)
        let mimetype = "application/vnd.oasis.opendocument.spreadsheet"
        try archive.addEntry(with: "mimetype", data: mimetype.data(using: .utf8)!)
        let buf = libxml2.xmlBufferCreate()!
        
        func writeCell(writer: xmlTextWriterPtr, content: String?, type: String = "string") {
            libxml2.xmlTextWriterStartElement(writer, "table:table-cell")
            libxml2.xmlTextWriterWriteAttribute(writer, "office:value-type", type)
            if let content, type == "float" {
                libxml2.xmlTextWriterWriteAttribute(writer, "office:value", content)
            }
            libxml2.xmlTextWriterWriteAttribute(writer, "calcext:value-type", type)
            if let content {
                libxml2.xmlTextWriterWriteElement(writer, "text:p", content)
            }
            libxml2.xmlTextWriterEndElement(writer)
        }
        
        func writeCell(writer: xmlTextWriterPtr, date: Date) {
            libxml2.xmlTextWriterStartElement(writer, "table:table-cell")
            libxml2.xmlTextWriterWriteAttribute(writer, "table:style-name", "CELL_DATE")
            libxml2.xmlTextWriterWriteAttribute(writer, "office:value-type", "date")
            libxml2.xmlTextWriterWriteAttribute(writer, "office:date-value", dateFormatter.string(from: date))
            libxml2.xmlTextWriterWriteAttribute(writer, "calcext:value-type", "date")
            libxml2.xmlTextWriterWriteElement(writer, "text:p", dateFormatterPretty.string(from: date))
            libxml2.xmlTextWriterEndElement(writer)
        }

        
        
        let writer = libxml2.xmlNewTextWriterMemory(buf, 0)!
        libxml2.xmlTextWriterStartDocument(writer, "1.0", "UTF-8", nil)
        libxml2.xmlTextWriterStartElement(writer, "office:document-content")
        libxml2.xmlTextWriterWriteAttribute(writer, "xmlns:office", "urn:oasis:names:tc:opendocument:xmlns:office:1.0")
        libxml2.xmlTextWriterWriteAttribute(writer, "xmlns:text", "urn:oasis:names:tc:opendocument:xmlns:text:1.0")
        libxml2.xmlTextWriterWriteAttribute(writer, "xmlns:table", "urn:oasis:names:tc:opendocument:xmlns:table:1.0")
        libxml2.xmlTextWriterWriteAttribute(writer, "xmlns:calcext", "urn:org:documentfoundation:names:experimental:calc:xmlns:calcext:1.0")
        libxml2.xmlTextWriterWriteAttribute(writer, "xmlns:style", "urn:oasis:names:tc:opendocument:xmlns:style:1.0")
        libxml2.xmlTextWriterWriteAttribute(writer, "office:version", "1.2")
        
        
        libxml2.xmlTextWriterStartElement(writer, "office:automatic-styles")
        
        libxml2.xmlTextWriterStartElement(writer, "style:style")
        libxml2.xmlTextWriterWriteAttribute(writer, "style:name", "COL_DATE")
        libxml2.xmlTextWriterWriteAttribute(writer, "style:family", "table-column")
        libxml2.xmlTextWriterStartElement(writer, "style:table-column-properties")
        libxml2.xmlTextWriterWriteAttribute(writer, "style:column-width", "100.00pt")
        libxml2.xmlTextWriterEndElement(writer)
        libxml2.xmlTextWriterEndElement(writer)
        
        libxml2.xmlTextWriterStartElement(writer, "style:style")
        libxml2.xmlTextWriterWriteAttribute(writer, "style:name", "COL_SCR")
        libxml2.xmlTextWriterWriteAttribute(writer, "style:family", "table-column")
        libxml2.xmlTextWriterStartElement(writer, "style:table-column-properties")
        libxml2.xmlTextWriterWriteAttribute(writer, "style:column-width", "200.00pt")
        libxml2.xmlTextWriterEndElement(writer)
        libxml2.xmlTextWriterEndElement(writer)
        
        libxml2.xmlTextWriterStartElement(writer, "style:style")
        libxml2.xmlTextWriterWriteAttribute(writer, "style:name", "CELL_DATE")
        libxml2.xmlTextWriterWriteAttribute(writer, "style:family", "table-cell")
        libxml2.xmlTextWriterWriteAttribute(writer, "style:data-style-name", "NUMFMT_DATE")
        libxml2.xmlTextWriterEndElement(writer)

        
        libxml2.xmlTextWriterEndElement(writer)
        
        
        libxml2.xmlTextWriterStartElement(writer, "office:body")
        libxml2.xmlTextWriterStartElement(writer, "office:spreadsheet")
        
        // Shut up MS Excel warning
        libxml2.xmlTextWriterStartElement(writer, "table:calculation-settings")
        libxml2.xmlTextWriterWriteAttribute(writer, "table:use-regular-expressions", "false")
        libxml2.xmlTextWriterEndElement(writer)
        
        for session in self.selectedSessions {
            libxml2.xmlTextWriterStartElement(writer, "table:table")
            libxml2.xmlTextWriterWriteAttribute(writer, "table:name", "\(session.name!)")
            
            libxml2.xmlTextWriterStartElement(writer, "table:table-column")
            libxml2.xmlTextWriterWriteAttribute(writer, "table:number-columns-repeated", "3")
            libxml2.xmlTextWriterEndElement(writer)
            
            libxml2.xmlTextWriterStartElement(writer, "table:table-column")
            libxml2.xmlTextWriterWriteAttribute(writer, "table:style-name", "COL_SCR")
            libxml2.xmlTextWriterEndElement(writer)
            
            libxml2.xmlTextWriterStartElement(writer, "table:table-column")
            libxml2.xmlTextWriterWriteAttribute(writer, "table:style-name", "COL_DATE")
            libxml2.xmlTextWriterEndElement(writer)

            
            for solve in session.solves?.allObjects as! [Solve] {
                libxml2.xmlTextWriterStartElement(writer, "table:table-row")
                
                let t = numberFormatter.string(from: NSNumber(value: solve.time))!
                
                writeCell(writer: writer, content: t, type: "float")
                #warning("TODO: maybe make the penalty cell a dropdown?")
                writeCell(writer: writer, content: Penalty(rawValue: solve.penalty)!.exportName())
                writeCell(writer: writer, content: solve.comment)
                writeCell(writer: writer, content: solve.scramble!)
                writeCell(writer: writer, date: solve.date!)
                
                libxml2.xmlTextWriterEndElement(writer)
            }
            
            
            libxml2.xmlTextWriterEndElement(writer)
            
        }
        libxml2.xmlTextWriterEndElement(writer)
        libxml2.xmlTextWriterEndElement(writer)
        libxml2.xmlTextWriterEndElement(writer)
        libxml2.xmlTextWriterEndDocument(writer)
        
        let content = Data(bytes: buf.pointee.content, count: Int(buf.pointee.use))
        libxml2.xmlFreeTextWriter(writer)
        
        
        libxml2.xmlBufferFree(buf)
        try archive.addEntry(with: "content.xml", data: content)
        // Yes, MS Excel really needs this, even though it's empty.
        try archive.addEntry(with: "styles.xml", data: styles)
        try archive.addEntry(with: "META-INF/manifest.xml", data: metaInf)
        
        let wrapper = FileWrapper(regularFileWithContents: archive.data!)
        wrapper.preferredFilename = "CubeTime Export.ods"
        return wrapper
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
    let allFormats: [ExportFormat] = [CSVExportFormat(), ODSExportFormat(), CSTimerExportFormat()]

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
