import Foundation
import SwiftUI
import UIKit
import Combine
import CoreData

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


struct SessionPickerMenu<Content: View>: View {
    let content: Content
    let sessions: [Session]?
    let clickSession: (Session) -> ()
    
    @inlinable init(sessions: [Session]?, clickSession: @escaping (Session) -> (), @ViewBuilder label: () -> Content = {Label("Move To", systemImage: "arrow.up.right")}) {
        self.sessions = sessions
        self.clickSession = clickSession
        self.content = label()
    }

    var body: some View {
        Menu {
            Text("Only compatible sessions are shown")
            if let sessions = sessions {
                let unpinnedidx = sessions.firstIndex(where: {!$0.pinned}) ?? sessions.count
                let pinned = sessions[0..<unpinnedidx]
                let unpinned = sessions[unpinnedidx..<sessions.count]
                Divider()
                Section("Pinned Sessions") {
                    ForEach(pinned) { session in
                        Button {
                            clickSession(session)
                        } label: {
                            Label(session.name!, systemImage: iconNamesForType[SessionType(rawValue:session.sessionType)!]!)
                        }
                    }
                }
                Section("Other Sessions") {
                    ForEach(unpinned) { session in
                        Button {
                            clickSession(session)
                        } label: {
                            Label(session.name!, systemImage: iconNamesForType[SessionType(rawValue:session.sessionType)!]!)
                        }
                    }
                }
            } else {
                Text("Loading...")
            }
        } label: {
            content
        }
    }
}


extension Session {
    var typeName: String {
        get {
            switch (SessionType(rawValue: sessionType)!) {
            case .standard:
                return "Standard Session"
            case .algtrainer:
                return "Alg trainer"
            case .multiphase:
                return "Multiphase"
            case .playground:
                return "Playground"
            case .compsim:
                return "Comp Sim"
            }
        }
    }
    
    var shortcutName: String {
        get {
            let scrname = puzzle_types[Int(scrambleType)].name
            switch (SessionType(rawValue: sessionType)!) {
            case .standard:
                return scrname
            case .algtrainer:
                return self.typeName + " - " + scrname
            case .multiphase:
                return self.typeName + " - " + scrname
            case .playground:
                return self.typeName
            case .compsim:
                return self.typeName + " - " + scrname
            }
        }
    }
}

let iconNamesForType: [SessionType: String] = [
    .standard: "timer.square",
    .algtrainer: "command.square",
    .multiphase: "square.stack",
    .playground: "square.on.square",
    .compsim: "globe.asia.australia"
]

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
        session_type != \(SessionType.compsim.rawValue)
        AND
        (
            session_type == \(SessionType.playground.rawValue) OR
            scramble_type == %i
        )
        AND
        (
            session_type != \(SessionType.multiphase.rawValue) OR
            phase_count == %i
        )
        AND
        self != %@
    """, scrambleType, phaseCount, currentSession)
    
    return try! managedObjectContext.fetch(req)
}

// set small device names
let smallDeviceNames: [String] = ["iPhoneSE"]

// legacy scramble support :sob:

//let chtscramblesthatdontworkwithtnoodle: [OrgWorldcubeassociationTnoodleScramblesPuzzleRegistry] = [.SIX, .SEVEN, .SKEWB]
                    
// all puzzle type identifier names
#warning("TODO: fix snake case")
let puzzle_types: [PuzzleType] = [
    PuzzleType(name: "2x2"),
    PuzzleType(name: "3x3"),
    PuzzleType(name: "4x4"),
    PuzzleType(name: "5x5"),
    PuzzleType(name: "6x6"),
    PuzzleType(name: "7x7"),
    PuzzleType(name: "Square-1"),
    PuzzleType(name: "Megaminx"),
    PuzzleType(name: "Pyraminx"),
    PuzzleType(name: "Clock"),
    PuzzleType(name: "Skewb"),
    
    // One hand
    PuzzleType(name: "3x3 OH"),
    
    // Blind
    PuzzleType(name: "3x3 BLD"),
    PuzzleType(name: "4x4 BLD"),
    PuzzleType(name: "5x5 BLD"),
]



// MARK: - PROTOCOLS
protocol RawGraphData {
    var graphData: Double? { get }
}



// MARK: - EXTENSIONS
// xor shortcut
extension Bool {
    static func ^ (l: Bool, r: Bool) -> Bool {
        return l != r
    }
}


extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        guard let index = firstIndex(of: object) else {return}
        remove(at: index)
    }
    
    
    func chunked() -> [[Element]] {
        return stride(from: 0, to: count-1, by: 1).map {
            Array(self[$0 ..< Swift.min($0 + 2, count)])
        }
    }
}


#warning("TODO: fix these, combine")
// get device type extension
public extension UIDevice {
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return identifier
    }()
    
    
    static var deviceIsPad: Bool {
        UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad
    }
    
    static func deviceIsLandscape(_ geo: CGSize) -> Bool {
        return geo.width > geo.height
    }
    
    static let hasBottomBar: Bool = {
        return ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom)! > 0
    }()
}

/// device restriction function
/// testing, includes simulator
//let smallDeviceNames: [String] = ["x86_64", "iPhoneSE"]

func getModelName() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    return withUnsafePointer(to: systemInfo.machine) {
        $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout.size(ofValue: $0)) {
            return String(cString: $0)
        }
    }
}

// screen sizes
extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
}

// solve related extensions
extension CompSimSolveGroup: RawGraphData {
    var graphData: Double? {
        get {
            return self.avg?.average
        }
    }
    
    var avg: CalculatedAverage? {
        return StopwatchManager.getCalculatedAverage(forSolves: self.solves!.array as! [Solve], name: "Comp Sim Group", isCompsim: true)
    }
}

extension Solve: Comparable, RawGraphData {
    var timeIncPen: Double {
        get {
            return self.time + (self.penalty == Penalty.plustwo.rawValue ? 2 : 0)
        }
    }
    
    var timeIncPenDNFMax: Double {
        get {
            return (self.penalty == Penalty.dnf.rawValue
                    ? Double.infinity
                    : (self.time + (self.penalty == Penalty.plustwo.rawValue ? 2 : 0)))
        }
    }
    
    var graphData: Double? {
        get {
            return timeIncPen
        }
    }
    
    public static func < (lhs: Solve, rhs: Solve) -> Bool {
        return lhs.timeIncPen < rhs.timeIncPen
    }

    // I don't know if i need both but better safe than sorry
    public static func > (lhs: Solve, rhs: Solve) -> Bool {
        return lhs.timeIncPen > rhs.timeIncPen
    }
}

// other
extension RandomAccessCollection where Element : Comparable {
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

extension RandomAccessCollection where Element : Solve {
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

// sizing + image dim
//extension CGSize {
//    public init(_ svgdimen: OrgWorldcubeassociationTnoodleSvgliteDimension) {
//        self.init(width: Int(svgdimen.getWidth()), height: Int(svgdimen.getHeight()))
//    }
//}
//
//extension OrgWorldcubeassociationTnoodleSvgliteDimension {
//    public convenience init(_ cgsize: CGSize) {
//        self.init(int: jint(cgsize.width), with: jint(cgsize.height))
//    }
//}

// view struct extensions
// source: https://www.avanderlee.com/swiftui/conditional-view-modifier/
extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
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

// gradient view extension
extension View {
    public func gradientForeground(gradientSelected: Int, isStaticGradient: Bool) -> some View {
        self.overlay(getGradient(gradientSelected: gradientSelected, isStaticGradient: isStaticGradient))
            .mask(self)
    }
}



// MARK: - STRUCTS
struct AppZoomWrapper: RawRepresentable, Identifiable {
    static let allCases = [DynamicTypeSize.xSmall,
                           DynamicTypeSize.small,
                           DynamicTypeSize.medium,
                           DynamicTypeSize.large,
                           DynamicTypeSize.xLarge,
                           DynamicTypeSize.xxLarge,
                           DynamicTypeSize.xxxLarge,
    ]
    
    static private let appZoomNames: [DynamicTypeSize: String] = [
            DynamicTypeSize.xSmall: "Extra Small",
            DynamicTypeSize.small: "Small",
            DynamicTypeSize.medium: "Medium",
            DynamicTypeSize.large: "Large (Default)",
            DynamicTypeSize.xLarge: "Extra Large",
            DynamicTypeSize.xxLarge: "Extra Extra Large",
            DynamicTypeSize.xxxLarge: "Extra Extra Extra Large",
    ]
    
    typealias RawValue = Int
    
    
    let size: DynamicTypeSize
    let name: String
    
    var rawValue: RawValue
    
    init(rawValue: RawValue) {
        // Couldn't figure out a nice way to do this with guard let
        self.rawValue = rawValue
        self.size = Self.allCases[rawValue]
        self.name = Self.appZoomNames[size]!
    }
    
    
    var id: Int {
        return rawValue
    }
}

// all main font structs
struct DynamicText: ViewModifier {
    @inlinable func body(content: Content) -> some View {
        content
            .scaledToFit()
//            .scaledToFill()   // i have no idea how swiftui works
            .minimumScaleFactor(0.5)
            .lineLimit(1)
    }
}

struct AnimatingFontSize: AnimatableModifier {
    let font: CTFontDescriptor
    var fontSize: CGFloat

    @inlinable var animatableData: CGFloat {
        get { fontSize }
        set { fontSize = newValue }
    }

    @inlinable func body(content: Self.Content) -> some View {
        content
            .font(Font(CTFontCreateWithFontDescriptor(font, fontSize, nil)))
    }
}

// global geometry reader structs
/// as the default textfield does not dynamically adjust its width according to the text
/// and instead is always set to the maximum width, this globalgeometrygetter is used
/// for the target input field on the timer view to change its width dynamically.

// source: https://stackoverflow.com/a/56729880/3902590
struct GlobalGeometryGetter: View {
    @Binding var rect: CGRect

    var body: some View {
        return GeometryReader { geometry in
            self.makeView(geometry: geometry)
        }
    }

    func makeView(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = geometry.frame(in: .global)
        }

        return Rectangle().fill(Color.clear)
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

// puzzletype wrapper
struct PuzzleType {
    let name: String
//    let puzzle: OrgWorldcubeassociationTnoodleScramblesPuzzleRegistry
}



// MARK: - ENUMS
enum Penalty: Int16, Hashable {
    case none
    case plustwo
    case dnf
}

enum SessionType: Int16 {
    case standard
    case algtrainer
    case multiphase
    case playground
    case compsim
}



// MARK: - FUNCS
// all formatting funcs
func formatSolveTime(secs: Double, dp: Int) -> String {
    if secs < 60 {
        return String(format: "%.\(dp)f", secs); #warning("TODO: set DP")
    } else {
        var secs = round(secs * 100) / 100.0
        let mins: Int = Int((secs / 60).rounded(.down))
        secs = secs.truncatingRemainder(dividingBy: 60)
        
        return String(format: "%d:%0\(dp + 3).\(dp)f", mins, secs)
    }
}

@available(*, deprecated, message: "Use solve.timeText instead.")
func formatSolveTime(secs: Double, penType: Penalty? = Penalty.none) -> String {
    if penType == Penalty.dnf {
        return "DNF"
    }
    
    let dp = SettingsManager.standard.displayDP
    let secsfmt = penType == .plustwo ? ".\(dp)f+" : ".\(dp)f"
    
    if secs < 60 {
        return String(format: "%\(secsfmt)", secs); #warning("TODO: set DP")
    } else {
        var secs = round(secs * 100) / 100.0
        let mins: Int = Int((secs / 60).rounded(.down))
        secs = secs.truncatingRemainder(dividingBy: 60)
        
        return String(format: "%d:%0\(dp + 3)\(secsfmt)", mins, secs)
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

// stats funcs
#warning("TODO: make good AND MOVE TO STOPWATCHMANAGER? or don't define here atleast")
func getAvgOfSolveGroup(_ compsimsolvegroup: CompSimSolveGroup) -> CalculatedAverage? {
    
    let trim = 1
    
    guard let solves = compsimsolvegroup.solves!.array as? [Solve] else {return nil}
    
    if solves.count < 5 {
        return nil
    }
    
    let sorted = solves.sorted(by: StopwatchManager.sortWithDNFsLast)
    let trimmedSolves: [Solve] = sorted.prefix(trim) + sorted.suffix(trim)
    
    return CalculatedAverage(
        name: "Comp Sim",
        average: sorted.dropFirst(trim).dropLast(trim)
                .reduce(0, {$0 + timeWithPlusTwoForSolve($1)}) / Double(3),
        accountedSolves: sorted,
        totalPen: sorted.filter {$0.penalty == Penalty.dnf.rawValue}.count >= trim * 2 ? .dnf : .none,
        trimmedSolves: trimmedSolves
    )
}


extension Solve {
    var timeText: String {
        get {
            return formatSolveTime(secs: self.time, penType: Penalty(rawValue: self.penalty)!)
        }
    }
}


// MARK: COPY FUNCTIONS
func copyScramble(scramble: String) -> Void {
    let str = "Generated by CubeTime.\n" + scramble
    UIPasteboard.general.string = str
}

func getShareStr(solve: Solve) -> String {
    var str = "Generated by CubeTime.\n"
    let scramble = solve.scramble ?? "Retrieving scramble failed."
    let time = solve.timeText
    
    str += "\n\(time):\t\(scramble)"

    return str
}

func getShareStr(solves: Set<Solve>) -> String {
    var str = "Generated by CubeTime."
    for solve in solves {
        let scramble = solve.scramble ?? "Retrieving scramble failed."
        let time = solve.timeText
        
        str += "\n\(time):\t\(scramble)"
    }
    
    return str
}

func getShareStr(solve: Solve, phases: Array<Double>?) -> String {
    let scramble = solve.scramble ?? "Retrieving scramble failed."
    let time = solve.timeText
    
    var str = "Generated by CubeTime.\n\(time):\t\(scramble)"
    
    
    if let phases = phases {
        str += "\n\nMultiphase Breakdown:"
        
        
        var prevphasetime = 0.0
        for (index, phase) in phases.enumerated() {
            str += "\n\(index + 1): +\(formatSolveTime(secs: phase - prevphasetime)) (\(formatSolveTime(secs: phase)))"
            prevphasetime = phase
        }
    }
    
    return str
}

func getShareStr(solves: CalculatedAverage) -> String {
    var str = "Generated by CubeTime.\n"
    str += "\(solves.name)"
    if let avg = solves.average {
        str+=": \(formatSolveTime(secs: avg, penType: solves.totalPen))"
    }
    str += "\n\n"
    str += "Time List:"
    
    for pair in zip(solves.accountedSolves!.indices, solves.accountedSolves!) {
        str += "\n\(pair.0 + 1). "
        let formattedTime = formatSolveTime(secs: pair.1.time, penType: Penalty(rawValue: pair.1.penalty))
        if solves.trimmedSolves!.contains(pair.1) {
            str += "(" + formattedTime + ")"
        } else {
            str += formattedTime
        }
        
        str += ":\t"+pair.1.scramble!
    }
    
    return str
}


func copySolve(solve: Solve) -> Void {
    UIPasteboard.general.string = getShareStr(solve: solve)
}

func copySolve(solves: Set<Solve>) -> Void {
    UIPasteboard.general.string = getShareStr(solves: solves)
}

func copySolve(solve: Solve, phases: Array<Double>?) -> Void {
    UIPasteboard.general.string = getShareStr(solve: solve, phases: phases)
}

func copySolve(solves: CalculatedAverage) -> Void {
    UIPasteboard.general.string = getShareStr(solves: solves)
}




// MARK: - MANUAL ENTRY FUNCS + VIEW MODIFIERS
// formatting funcs
@inline(__always) func filteredStrFromTime(_ time: Double?) -> String {
    return time == nil ? "" : formatSolveTime(secs: time!, dp: 2)
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

// manual entry mask
#warning("TODO: convert to TextFieldStyle")
struct TimeMaskTextField: ViewModifier {
    @Binding var text: String
    @State var userDotted = false
    
    var onReceiveAlso: ((String) -> Void)?
    func body(content: Content) -> some View {
        content
            .keyboardType(text.count > 2 ? .numberPad : .decimalPad)
            .onChange(of: text) { newValue in
                NSLog("ONRECEIVE, text: \(text)")
                refilter()
                
                onReceiveAlso?(text)
            }
    }
    
    func refilter() {
        var filtered: String!
        
        let dotCount = text.filter({ $0 == "."}).count
        
        // Let the user dot if the text is more than 1, less than six (0.xx.) and there are 2 dots where the last was just entered
        if text == "." || ( text.count > 1 && text.count < 6 && text.last! == "." && dotCount < 3 ) {
            userDotted = true
        } else if dotCount == 0 {
            userDotted = false
        }
        
        
        if userDotted {
            var removedfirstdot = !(dotCount == 2)
            
            filtered = String(
                text
                    .filter {
                        // Remove only first of 2 dots
                        if removedfirstdot {
                            return $0.isNumber || $0 == "."
                        } else {
                            if $0 == "." {
                                removedfirstdot = true
                                return false
                            } else {
                                return $0.isNumber
                            }
                        }
                    }
                    .replacingOccurrences(of: "^0+", with: "", options: .regularExpression) // Remove leading 0s
            )
            let dotindex = filtered.firstIndex(of: ".")!
            
            let from = filtered.index(dotindex, offsetBy: -2, limitedBy: filtered.startIndex) ?? filtered.startIndex
            let to = filtered.index(dotindex, offsetBy: 3, limitedBy: filtered.endIndex) ?? filtered.endIndex
            
            
            filtered = String(filtered[from..<to])
        } else {
            filtered = String(
                text.filter { $0.isNumber } // Remove a non numbers
                    .replacingOccurrences(of: "^0+", with: "", options: .regularExpression) // Remove leading 0s
                    .prefix(6)
            )
            if filtered.count > 2 {
                filtered.insert(".", at: filtered.index(filtered.endIndex, offsetBy: -2))
            } else if filtered.count > 0 {
                filtered = "0." + repeatElement("0", count: 2 - filtered.count) + filtered
            }
            if filtered.count > 5 {
                filtered.insert(":", at: filtered.index(filtered.endIndex, offsetBy: -5))
            }
        }
        
        text = filtered
    }
}




// MARK: - CUSTOM SAFE AREA INSET
enum SafeAreaDeviceType {
    case defaultView
    case padFloating
}

enum SafeAreaType {
    case tabBar
}

struct TabBarSafeAreaInset: ViewModifier {
    let avoidBottomBy: CGFloat
    
    init(avoidBottomBy: CGFloat = 0) {
        self.avoidBottomBy = avoidBottomBy
    }
    
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Rectangle()
                .fill(Color.clear)
                .frame(height: 50)
                .padding(.top, 8 + avoidBottomBy)
                .padding(.bottom, UIDevice.hasBottomBar ? 0 : nil)
            }
    }
}

struct PadFloatingSafeAreaInset: ViewModifier {
    func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Rectangle()
                .fill(Color.clear)
                .frame(height: 50)
                .padding(.vertical)
            }
    }
}

extension View {
    func safeAreaInset(safeArea: SafeAreaDeviceType, avoidBottomBy: CGFloat=0) -> some View {
        switch safeArea {
        case .defaultView:
            return AnyView(modifier(TabBarSafeAreaInset(avoidBottomBy: avoidBottomBy)))
        case .padFloating:
            return AnyView(modifier(PadFloatingSafeAreaInset()))
        }
    }
        
    func safeAreaInset(safeArea: SafeAreaType, avoidBottomBy: CGFloat=0) -> some View {
        switch safeArea {
        case .tabBar:
            return safeAreaInset(safeArea: .defaultView, avoidBottomBy: avoidBottomBy)
        }
    }
}



@available(*, deprecated, message: "Use solve.timeIncPen instead.")
func timeWithPlusTwoForSolve(_ solve: Solve) -> Double {
    return solve.time + (solve.penalty == Penalty.plustwo.rawValue ? 2 : 0)
}



// MARK: - SESSION HELPERS, VIEWMODIFIERS AND STRUCTS
// session type icon
struct SessionTypeIcon {
    var size: CGFloat = 26
    var iconName: String = ""
    var padding: (leading: CGFloat, trailing: CGFloat) = (8, 4)
    var weight: Font.Weight = .regular
}

#warning("TODO: change timedetailview and statsdetailview to also use this")
#warning("TODO: check if .style continuous makes a difference?")
// rounded viewblock modifier
struct CardBlockBackground: ViewModifier {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    func body(content: Content) -> some View {
        content
            .background(Color("overlay1"))
            .cornerRadius(8)
            .padding(.horizontal)
    }
}

// delayed context menu animation
struct ContextMenuButton: View {
    var delay: Bool
    var action: () -> Void
    var title: String
    var systemImage: String? = nil
    var disableButton: Bool? = nil
    
    init(delay: Bool, action: @escaping () -> Void, title: String, systemImage: String?, disableButton: Bool?) {
        self.delay = delay
        self.action = action
        self.title = title
        self.systemImage = systemImage
        self.disableButton = disableButton
    }
    
    var body: some View {
        Button(role: title == "Delete Session" ? .destructive : nil, action: delayedAction) {
            HStack {
                Text(title)
                if image != nil {
                    Image(uiImage: image!)
                }
            }
        }.disabled(disableButton ?? false)
    }
    
    private var image: UIImage? {
        if let systemName = systemImage {
            let config = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .body), scale: .medium)
            
            return UIImage(systemName: systemName, withConfiguration: config)
        } else {
            return nil
        }
    }
    private func delayedAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + (delay ? 0.55 : 0)) {
            self.action()
        }
    }
}

// src: https://stackoverflow.com/a/69694099/17569741
struct ShareSheetViewController: UIViewControllerRepresentable {
    @Binding var isPresenting: Bool
    var content: () -> UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if isPresenting {
            uiViewController.present(content(), animated: true, completion: nil)
        }
    }
}


func offsetImage(image: UIImage, offsetX: CGFloat=0, offsetY: CGFloat=0) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(CGSize(width: image.size.width + abs(offsetX), height: image.size.height + abs(offsetY)), false, 0)
    image.draw(in: CGRect(x: offsetX, y: offsetY, width: image.size.width, height: image.size.height))

    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage
}


func setupNavbarAppearance() -> Void {
    let navBarAppearance = UINavigationBar.appearance()
    var customBackImage = UIImage(systemName: "arrow.backward")
    customBackImage = offsetImage(image: customBackImage!, offsetX: 10, offsetY: -1.5)
    navBarAppearance.backIndicatorImage = customBackImage
    navBarAppearance.backIndicatorTransitionMaskImage = customBackImage
    navBarAppearance.tintColor = UIColor(named: "accent")
//    navBarAppearance.backgroundColor = UIColor(named: "overlay1")
    #warning("BUG: enabling this fixes background blur effect, BUT buttons on timelistview are cut off on top?")
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
