import Foundation
import SwiftUI
import UIKit
import Combine
import CoreData
import AVFoundation
import ZIPFoundation

// MARK: - GLOBAL LETS
let sessionTypeForID: [SessionType: Session.Type] = [
    .multiphase: MultiphaseSession.self,
    .compsim: CompSimSession.self
]

let sessionDescriptions: [SessionType: String] = [
    .multiphase: "A multiphase session gives you the ability to breakdown your solves into sections, such as memo/exec stages in blindfolded solving or stages in 3x3 solves.\n\nTap anywhere on the timer during a solve to record a phase lap. You can access your breakdown statistics in each time card and view overall statistics in the Stats view.",
    .playground: "A playground session allows you to quickly change the scramble type within a session without having to specify a scramble type for the whole session.",
    .compsim: "A comp sim (Competition Simulation) session mimics a competition scenario better by recording a non-rolling session. Your solves will be split up into averages of 5 that can be accessed in your times and statistics view.\n\nStart by choosing a target to reach."
]


let iconNamesForType: [SessionType: String] = [
    .standard: "timer.square",
    .algtrainer: "command.square",
    .multiphase: "square.stack",
    .playground: "square.on.square",
    .compsim: "globe.asia.australia"
]


let puzzleTypes: [PuzzleType] = [
    PuzzleType(name: "2x2", cstimerName: "222so"),
    PuzzleType(name: "3x3", cstimerName: "333"),
    PuzzleType(name: "4x4", cstimerName: "444wca"),
    PuzzleType(name: "5x5", cstimerName: "555wca"),
    PuzzleType(name: "6x6", cstimerName: "666wca"),
    PuzzleType(name: "7x7", cstimerName: "777wca"),
    PuzzleType(name: "Square-1", cstimerName: "sqrs"),
    PuzzleType(name: "Megaminx", cstimerName: "mgmp"),
    PuzzleType(name: "Pyraminx", cstimerName: "pyrso"),
    PuzzleType(name: "Clock", cstimerName: "clkwca"),
    PuzzleType(name: "Skewb", cstimerName: "skbso"),
    PuzzleType(name: "3x3 OH", cstimerName: "333oh"),
    PuzzleType(name: "3x3 BLD", cstimerName: "333bld"),
    PuzzleType(name: "4x4 BLD", cstimerName: "444bld"),
    PuzzleType(name: "5x5 BLD", cstimerName: "555bld"),
]



// MARK: - EXTENSIONS
extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else { return }
        remove(at: index)
    }
    
    
    func chunked() -> [[Element]] {
        return stride(from: 0, to: count-1, by: 1).map {
            Array(self[$0 ..< Swift.min($0 + 2, count)])
        }
    }
}

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

extension RandomAccessCollection where Element: Comparable {
    func insertionIndex(of value: Element) -> Index {
        var slice : SubSequence = self[...]

        while !slice.isEmpty {
            let middle = slice.index(slice.startIndex, offsetBy: slice.count / 2)
            if value < slice[middle] {
                slice = slice[..<middle]
            } else {
                slice = slice[index(after: middle)...]
            }
        }
        return slice.startIndex
    }
}

extension RandomAccessCollection where Element: Solve {
    func insertionIndexDate(solve value: Solve) -> Index {
        var slice : SubSequence = self[...]

        while !slice.isEmpty {
            let middle = slice.index(slice.startIndex, offsetBy: slice.count / 2)
            if value.date! < slice[middle].date! {
                slice = slice[..<middle]
            } else {
                slice = slice[index(after: middle)...]
            }
        }
        return slice.startIndex
    }
}

extension Archive {
    func addEntry(with: String, data: Data) throws {
        try addEntry(with: with, type: .file, uncompressedSize: Int64(data.count), provider: { (position: Int64, size) -> Data in
            return data.subdata(in: Int(position)..<Int(position)+size)
        })
    }
}

// MARK: - UIDEVICE EXTENSIONS
extension UIDevice {
    static var deviceIsPad: Bool {
        UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
    
    static let hasBottomBar: Bool = {
        return ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom)! > 0
    }()
    
    static let deviceModelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafePointer(to: systemInfo.machine) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
                return String(cString: $0)
            }
        }
    }()
}



// view extensions
extension UIScreen {
    @available(*, deprecated, message: "use parent geo as this is not correct for pad windows")
    static let screenHeight = UIScreen.main.bounds.size.height
}


extension View {
    @inlinable @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    
    @inlinable @ViewBuilder func `ifelse`<Content: View, ContentElse: View>(_ condition: Bool, transform: (Self) -> Content, elseDo: (Self) -> ContentElse) -> some View {
        if condition {
            transform(self)
        } else {
            elseDo(self)
        }
    }
}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}


struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}


// source https://stackoverflow.com/a/62687023/17569741
extension UIFont {
    static func preferredFont(for style: TextStyle, weight: Weight, italic: Bool = false) -> UIFont {

        // Get the style's default pointSize
        let traits = UITraitCollection(preferredContentSizeCategory: .large)
        let desc = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style, compatibleWith: traits)

        // Get the font at the default size and preferred weight
        var font = UIFont.systemFont(ofSize: desc.pointSize, weight: weight)
        if italic == true {
            font = font.with([.traitItalic])
        }

        // Setup the font to be auto-scalable
        let metrics = UIFontMetrics(forTextStyle: style)
        return metrics.scaledFont(for: font)
    }
    
    private func with(_ traits: UIFontDescriptor.SymbolicTraits...) -> UIFont {
        guard let descriptor = fontDescriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits(traits).union(fontDescriptor.symbolicTraits)) else {
            return self
        }
        return UIFont(descriptor: descriptor, size: 0)
    }
}


// MARK: - FUNCS
// all formatting funcs
func formatSolveTime(secs: Double, dp: Int = SettingsManager.standard.displayDP, penalty: Penalty? = Penalty.none) -> String {
    if penalty == .dnf {
        return "DNF"
    }
    
    let ratio = pow(10.0, Double(dp))
    let formatString = penalty == .plustwo ? ".\(dp)f+" : ".\(dp)f"
    
    if secs < 60 {
        return String(format: "%\(formatString)", floor(secs * ratio) / ratio)
    } else {
        let mins = Int(secs / 60)
        let secs = (floor(secs * ratio) / ratio) - Double(mins * 60)
        
        let offset = dp == 0 ? 2 : 3
        return String(format: "%d:%0\(dp + offset)\(formatString)", mins, secs)
    }
}

func formatLegendTime(secs: Double, dp: Int) -> String {
    if secs < 10 {
        return String(format: "%.\(dp)f", secs) // dp = 1
    } else if secs < 60 {
        return String(format: "%.\(dp-1)f", secs); #warning("TODO: set DP")
    } else if secs < 600 {
        let mins: Int = Int((secs / 60).rounded(.down))
        let secs = Int(secs.truncatingRemainder(dividingBy: 60))
        return String(format: "%d:%02d", mins, secs)
    } else {
        let mins: Int = Int((secs / 60).rounded(.down))
        return String(format: "%dm", mins)
    }
}

func jsonSerialize(obj: Any) throws -> Data {
    var error: NSError?
    let exportStream = OutputStream(toMemory: ())
    exportStream.open()
    JSONSerialization.writeJSONObject(obj, to: exportStream, error: &error)
    exportStream.close()
    if let error {
        throw error
    }
    return (exportStream.property(forKey: .dataWrittenToMemoryStreamKey) as! NSData) as Data

}

// MARK: - MANUAL ENTRY FUNCS + VIEW MODIFIERS
// formatting funcs
@inline(__always) func filteredStrFromTime(_ time: Double?) -> String {
    return time == nil ? "" : formatSolveTime(secs: time!)
}

func timeFromStr(_ formattedTime: String) -> Double? {
    if formattedTime.isEmpty {
        return nil
    }
    let separated = formattedTime.components(separatedBy: ":")
    let mins: UInt = separated.count > 1 ? UInt(separated[0])! : 0
    let secs: Double = Double(separated.last!) ?? 0
    
    return Double(mins) * 60 + secs
}



func getSessionsCanMoveTo(managedObjectContext: NSManagedObjectContext, scrambleType: Int32, currentSession: Session) -> [Session] {
    var phaseCount: Int16 = -1
    if let multiphaseSession = currentSession as? MultiphaseSession {
        phaseCount = multiphaseSession.phaseCount
    }
    
    let req = NSFetchRequest<Session>(entityName: "Session")
    req.sortDescriptors = [
        NSSortDescriptor(keyPath: \Session.pinned, ascending: false),
        NSSortDescriptor(keyPath: \Session.name, ascending: true)
    ]
    req.predicate = NSPredicate(format: """
        sessionType != \(SessionType.compsim.rawValue)
        AND
        (
            sessionType == \(SessionType.playground.rawValue) OR
            scrambleType == %i
        )
        AND
        (
            sessionType != \(SessionType.multiphase.rawValue) OR
            phaseCount == %i
        )
        AND
        self != %@
    """, scrambleType, phaseCount, currentSession)
    
    return try! managedObjectContext.fetch(req)
}


#warning("TODO: make good AND MOVE TO STOPWATCHMANAGER? or don't define here atleast")
func getAvgOfSolveGroup(_ compsimsolvegroup: CompSimSolveGroup) -> CalculatedAverage? {
    
    let trim = 1
    
    guard let solves = compsimsolvegroup.solves?.allObjects as? [Solve] else {return nil}
    
    if solves.count < 5 {
        return nil
    }
    
    let sorted = solves.sorted(by: StopwatchManager.sortWithDNFsLast)
    let trimmedSolves: [Solve] = sorted.prefix(trim) + sorted.suffix(trim)
    
    return CalculatedAverage(
        name: "Comp Sim",
        average: sorted.dropFirst(trim).dropLast(trim)
            .reduce(0, { $0 + $1.timeIncPen }) / Double(3),
        accountedSolves: sorted,
        totalPen: sorted.filter {$0.penalty == Penalty.dnf.rawValue}.count >= trim * 2 ? .dnf : .none,
        trimmedSolves: trimmedSolves
    )
}


// MARK: - Override

func offsetImage(image: UIImage, offsetX: CGFloat=0, offsetY: CGFloat=0) -> UIImage? {
    let format: UIGraphicsImageRendererFormat = UIGraphicsImageRendererFormat.default()
    format.opaque = false
    format.scale = UIScreen.main.scale
    
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: image.size.width + abs(offsetX), height: image.size.height + abs(offsetY)), format: format)
    
    let newImage = renderer.image { ctx in
        image.draw(in: CGRect(x: offsetX, y: offsetY, width: image.size.width, height: image.size.height))
    }
    

//    let newImage = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()

    return newImage
}


func setupNavbarAppearance() -> Void {
    let navBarAppearance = UINavigationBar.appearance()
    var customBackImage = UIImage(systemName: "arrow.backward")
    customBackImage = offsetImage(image: customBackImage!, offsetX: 10, offsetY: -1.5)
    navBarAppearance.backIndicatorImage = customBackImage
    navBarAppearance.backIndicatorTransitionMaskImage = customBackImage
    navBarAppearance.tintColor = UIColor(named: "accent")
    #warning("TODO FIX")
//    navBarAppearance.backgroundColor = UIColor(named: "indent")
}

func setupNavTitleAppearance() -> Void {
    let navBarAppearance = UINavigationBar.appearance()
    
    let variations = [2003265652: 650.0, 1128354636: 0.0, 1129468758: 0]
    
    let uiFontDesc = UIFontDescriptor(fontAttributes: [
        .name: "RecursiveSansLinearLightCasual-Regular",
        kCTFontVariationAttribute as UIFontDescriptor.AttributeName: variations
    ])
    
    let metrics = UIFontMetrics(forTextStyle: .largeTitle)
    let font = metrics.scaledFont(for: UIFont(descriptor: uiFontDesc, size: 34))
    
    navBarAppearance.largeTitleTextAttributes = [NSAttributedString.Key.font: font]
}

#warning("todo: fix; doesn't seem to be working ios 15?")
func setupColourScheme(_ mode: UIUserInterfaceStyle?) -> Void {
    if let mode = mode {
        keyWindow?.overrideUserInterfaceStyle = mode
    }
}

var keyWindow: UIWindow? {
    return UIApplication.shared.connectedScenes
        .filter({ $0.activationState == .foregroundActive })
        .first(where: { $0 is UIWindowScene })
        .flatMap({ $0 as? UIWindowScene })?.windows
        .first(where: \.isKeyWindow)
}


func setupAudioSession(with category: AVAudioSession.Category = .playback) {
    let audioSession = AVAudioSession.sharedInstance()
    do {
        try audioSession.setCategory(category, options: .duckOthers)
    } catch let error as NSError {
        #if DEBUG
        NSLog(error.description)
        #endif
    }
}


// ignore... doesn't work with splash screen
/*
@IBDesignable
class SplashShadowView: UIImageView {
    @IBInspectable var shadowColor: UIColor = UIColor(named: "accent3")! {
        didSet {
            self.updateView()
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.5 {
        didSet {
            self.updateView()
        }
    }
    
    @IBInspectable var shadowOffset = CGSize(width: 0, height: 0) {
        didSet {
            self.updateView()
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 12.0 {
        didSet {
            self.updateView()
        }
    }
    
    
    func updateView() {
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
    }
}
*/
