import Foundation
import SwiftUI
import UIKit
import Combine

// MARK: - GLOBAL LETS
let sessionTypeForID: [SessionTypes: Sessions.Type] = [
    .multiphase: MultiphaseSession.self,
    .compsim: CompSimSession.self
]

let sessionDescriptions: [SessionTypes: String] = [
    .multiphase: "A multiphase session gives you the ability to breakdown your solves into sections, such as memo/exec stages in blindfolded solving or stages in 3x3 solves.\n\nTap anywhere on the timer during a solve to record a phase lap. You can access your breakdown statistics in each time card and view overall statistics in the Stats view.",
    .playground: "A playground session allows you to quickly change the scramble type within a session without having to specify a scramble type for the whole session.",
    .compsim: "A comp sim (Competition Simulation) session mimics a competition scenario better by recording a non-rolling session. Your solves will be split up into averages of 5 that can be accessed in your times and statistics view.\n\nStart by choosing a target to reach."
]

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
    
    static var windowSize: CGSize? {
        UIApplication.shared.connectedScenes.compactMap({ scene -> UIWindow? in
                            (scene as? UIWindowScene)?.keyWindow
        }).first?.frame.size
    }
    
    static var deviceOrientation: UIDeviceOrientation {
        UIDevice.current.orientation
    }
    
    static var useExtendedView: Bool {
        self.deviceIsPad && (self.deviceOrientation == .landscapeLeft || self.deviceOrientation == .landscapeRight)
    }
}

/// device restriction function
/// testing, includes simulator
//let smallDeviceNames: [String] = ["x86_64", "iPhoneSE"]

func getModelName() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    return machineMirror.children.reduce("") { identifier, element in
        guard let value = element.value as? Int8, value != 0 else {
            return identifier
        }
        return identifier + String(UnicodeScalar(UInt8(value)))
    }
}

// screen sizes
extension UIScreen {
   static let screenWidth = UIScreen.main.bounds.size.width
   static let screenHeight = UIScreen.main.bounds.size.height
   static let screenSize = UIScreen.main.bounds.size
}

// solve related extensions
extension CompSimSolveGroup: RawGraphData {
    var graphData: Double? {
        get {
            return self.avg?.average
        }
    }
    
    var avg: CalculatedAverage? {
        return StopWatchManager.calculateAverage(self.solves!.array as! [Solves], "Comp Sim Group", true)
    }
}

extension Solves: Comparable, RawGraphData {
    var timeIncPen: Double {
        get {
            return self.time + (self.penalty == PenTypes.plustwo.rawValue ? 2 : 0)
        }
    }
    
    var graphData: Double? {
        get {
            return timeIncPen
        }
    }
    
    public static func < (lhs: Solves, rhs: Solves) -> Bool {
        return lhs.timeIncPen < rhs.timeIncPen
    }

    // I don't know if i need both but better safe than sorry
    public static func > (lhs: Solves, rhs: Solves) -> Bool {
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

extension RandomAccessCollection where Element : Solves {
    func insertionIndexDate(solve value: Solves) -> Index {
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

// view scaled font 
@available(iOS 15, *)
extension View {
    func scaledCustomFont(name: String, size: CGFloat, sf: Bool, weight: Font.Weight?) -> some View {
        return self.modifier(ScaledCustomFont(name: name, size: size, sf: sf, weight: weight))
    }
}

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
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// gradient view extension
extension View {
    public func gradientForeground(gradientSelected: Int) -> some View {
        self.overlay(getGradient(gradientArray: CustomGradientColours.gradientColours, gradientSelected: gradientSelected))
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
    func body(content: Content) -> some View {
        content
            .scaledToFill()
            .minimumScaleFactor(0.5)
            .lineLimit(1)
    }
}

struct AnimatingFontSize: AnimatableModifier {
    var fontSize: CGFloat

    var animatableData: CGFloat {
        get { fontSize }
        set { fontSize = newValue }
    }

    func body(content: Self.Content) -> some View {
        content
            .font(.system(size: self.fontSize, weight: .bold, design: .monospaced))
    }
}

@available(iOS 15, *)
struct ScaledCustomFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    
    var name: String
    var size: CGFloat
    var sf: Bool
    var weight: Font.Weight?
    
    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        if sf {
            return content.font(.system(size: scaledSize, weight: weight ?? .regular, design: .default))
        } else {
            return content.font(.custom(name, size: scaledSize))
        }
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
enum PenTypes: Int16 {
    case none
    case plustwo
    case dnf
}

enum SessionTypes: Int16 {
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
        let mins: Int = Int((secs / 60).rounded(.down))
        let secs = secs.truncatingRemainder(dividingBy: 60)
        
        return String(format: "%d:%0\(dp + 3).\(dp)f", mins, secs)
    }
}

func formatSolveTime(secs: Double, penType: PenTypes? = PenTypes.none) -> String {
    if penType == PenTypes.dnf {
        return "DNF"
    }
    
    let dp = UserDefaults.standard.integer(forKey: gsKeys.displayDP.rawValue)
    let secsfmt = penType == .plustwo ? ".\(dp)f+" : ".\(dp)f"
    
    if secs < 60 {
        return String(format: "%\(secsfmt)", secs); #warning("TODO: set DP")
    } else {
        let mins: Int = Int((secs / 60).rounded(.down))
        let secs = secs.truncatingRemainder(dividingBy: 60)
        
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
    
    guard let solves = compsimsolvegroup.solves!.array as? [Solves] else {return nil}
    
    if solves.count < 5 {
        return nil
    }
    
    let sorted = solves.sorted(by: StopWatchManager.sortWithDNFsLast)
    let trimmedSolves: [Solves] = sorted.prefix(trim) + sorted.suffix(trim)
    
    return CalculatedAverage(
        name: "Comp Sim",
        average: sorted.dropFirst(trim).dropLast(trim)
                .reduce(0, {$0 + timeWithPlusTwoForSolve($1)}) / Double(3),
        accountedSolves: sorted,
        totalPen: sorted.filter {$0.penalty == PenTypes.dnf.rawValue}.count >= trim * 2 ? .dnf : .none,
        trimmedSolves: trimmedSolves
    )
}



// MARK: COPY FUNCTIONS
func copySolve(solve: Solves) -> Void {
    let scramble = solve.scramble ?? "Retrieving scramble failed."
    let time = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
    
    let str = "Generated by CubeTime.\n\(time):\t\(scramble)"
    
    UIPasteboard.general.string = str
}

func copySolve(solves: [Solves]) -> Void {
    var str = "Generated by CubeTime."
    for solve in solves {
        let scramble = solve.scramble ?? "Retrieving scramble failed."
        let time = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
        
        str += "\n\(time):\t\(scramble)"
    }
    
    UIPasteboard.general.string = str
}

func copySolve(solve: Solves, phases: Array<Double>?) -> Void {
    let scramble = solve.scramble ?? "Retrieving scramble failed."
    let time = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
    
    var str = "Generated by CubeTime.\n\(time):\t\(scramble)"
    
    
    if let phases = phases {
        str += "\n\nMultiphase Breakdown:"
        
        
        var prevphasetime = 0.0
        for (index, phase) in phases.enumerated() {
            str += "\n\(index + 1): +\(formatSolveTime(secs: phase - prevphasetime)) (\(formatSolveTime(secs: phase)))"
            prevphasetime = phase
        }
    }
    
    UIPasteboard.general.string = str
}


func copySolve(solves: CalculatedAverage) -> Void {
    UIPasteboard.general.string = {
        var str = "Generated by CubeTime.\n"
        str += "\(solves.name)"
        if let avg = solves.average {
            str+=": \(formatSolveTime(secs: avg, penType: solves.totalPen))"
        }
        str += "\n\n"
        str += "Time List:"
        
        for pair in zip(solves.accountedSolves!.indices, solves.accountedSolves!) {
            str += "\n\(pair.0 + 1). "
            let formattedTime = formatSolveTime(secs: pair.1.time, penType: PenTypes(rawValue: pair.1.penalty))
            if solves.trimmedSolves!.contains(pair.1) {
                str += "(" + formattedTime + ")"
            } else {
                str += formattedTime
            }
            
            str += ":\t"+pair.1.scramble!
        }
        
        return str
    }()
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
            .onReceive(Just(text)) { newValue in
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



// MARK: - MAIN TIMER STATIC VALUES
#warning("TODO: merge this with tabrouter")
class SetValues {
    static let hasBottomBar = ((UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.safeAreaInsets.bottom)! > 0
}

class TimerTextColours {
    static let timerDefaultColour: Color = Color.primary
    static let timerDefaultColourDarkMode: Color = Color.primary
    static let timerHeldDownColour: Color = Color.red
    static let timerCanStartColour: Color = Color.green
    static let timerLoadingColor: Color = Color(uiColor: .systemGray)
}

class InspectionColours {
    static let eightColour: Color = Color(red: 234/255, green: 224/255, blue: 182/255)
    static let twelveColour: Color = Color(red: 234/255, green: 212/255, blue: 182/255)
    static let penaltyColour: Color = Color(red: 234/255, green: 194/255, blue: 192/255)
}



// MARK: - COLOURS AND GRADIENTS
// colour extensions
extension UIColor {
    func colorsEqual (_ rhs: UIColor) -> Bool {
        var sred: CGFloat = 0
        var sgreen: CGFloat = 0
        var sblue: CGFloat = 0
        
        var rred: CGFloat = 0
        var rgreen: CGFloat = 0
        var rblue: CGFloat = 0
        

        self.getRed(&sred, green: &sgreen, blue: &sblue, alpha: nil)
        rhs.getRed(&rred, green: &rgreen, blue: &rblue, alpha: nil)

        return (Int(sred*255), Int(sgreen*255), Int(sblue*255)) == (Int(rred*255), Int(rgreen*255), Int(rblue*255))
    }
}

extension Color: RawRepresentable {
    public typealias RawValue = String
    init(_ hex: UInt) {
        self.init(
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255
        )
    }
    
    public init(rawValue: RawValue) {
        try! self.init(uiColor: NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: Data(base64Encoded: rawValue)!)!)
    }

    public var rawValue: RawValue {
        return try! NSKeyedArchiver.archivedData(withRootObject: UIColor(self), requiringSecureCoding: false).base64EncodedString()
    }
}

func getGradient(gradientArray: [[Color]], gradientSelected: Int?) -> LinearGradient {
    if let gradientSelected = gradientSelected {
        return LinearGradient(gradient: Gradient(colors: gradientArray[gradientSelected]), startPoint: .bottomTrailing, endPoint: .topLeading)
    } else {
        return LinearGradient(gradient: Gradient(colors: gradientArray[6]), startPoint: .bottomTrailing, endPoint: .topLeading)
    }
}

func getGradientColours(gradientArray: [[Color]], gradientSelected: Int?) -> [Color] {
    if let gradientSelected = gradientSelected {
        return gradientArray[gradientSelected]
    } else {
        return gradientArray[6]
    }
}

class CustomGradientColours {
    static let gradientColours: [[Color]] = [
        [Color(0x0093c1), Color(0x05537a)], // light blue - dark blue
        [Color(0x52c8cd), Color(0x007caa)], // aqua - light blue
        [Color(0xe6e29a), Color(0x3ec4d0)], // pale yellow/white ish - aqua
        [Color(0xffd325), Color(0x94d7be)], // yellow - green
        [Color(0xff9e45), Color(0xffd63c)], // pale orange-yellow
        
        [Color(0xfc7018), Color(0xffc337)], // darker orange - yellow
        [Color(0xfb5b5c), Color(0xff9528)], // pink-orange
        [Color(0xd35082), Color(0xf77d4f)], // magenta-orange
        [Color(0x8548ba), Color(0xd95378)], // purple-pink
        [Color(0x3f248f), Color(0x702f86)], // dark blue-purple
    ]
}



// MARK: - SESSION HELPERS, VIEWMODIFIERS AND STRUCTS
// session type icon
struct SessionTypeIconProps {
    var size: CGFloat = 26
    var leaPadding: CGFloat = 8
    var traPadding: CGFloat = 4
    var weight: Font.Weight = .regular
}

// rounded viewblock modifier
struct NewStandardSessionViewBlocks: ViewModifier {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    func body(content: Content) -> some View {
        content
            .background(colorScheme == .light ? Color.white : Color(uiColor: .systemGray6))
            .cornerRadius(10)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + (delay ? 0.9 : 0)) {
            self.action()
        }
    }
}



// MARK: - OTHER GLOBAL VIEWS
// global close button view
struct CloseButton: View {
    @Environment(\.colorScheme) var colourScheme
    
    var body: some View {
        Image(systemName: "xmark.circle.fill")
            .font(.system(size: 24, weight: .medium))
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(.secondary)
            .foregroundStyle(colourScheme == .light ? .black : .white)
    }
}
