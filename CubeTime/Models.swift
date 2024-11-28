import Foundation
import SwiftUI

struct CalculatedAverage: Identifiable, Comparable {
    let id = UUID()
    var name: String

    //    let discardedIndexes: [Int]
    let average: Double?
    let accountedSolves: [Solve]?
    let totalPen: Penalty
    let trimmedSolves: [Solve]?
    
    static func < (lhs: CalculatedAverage, rhs: CalculatedAverage) -> Bool {
        #warning("TODO:  merge with that one sort function")
        if lhs.totalPen == .dnf && rhs.totalPen != .dnf {
            return true
        } else if lhs.totalPen != .dnf && rhs.totalPen == .dnf {
            return false
        } else {
            if let lhsa = lhs.average {
                if let rhsa = rhs.average {
//                    return timeWithPlusTwo(lhsa, pen: lhs.totalPen) < timeWithPlusTwo(rhsa, pen: rhs.totalPen)
                    return lhsa < rhsa
                } else {
                    return true
                }
            } else {
                return false
            }
        }
    }
}

struct Average: Identifiable, Comparable {
    let id = UUID()
    
    let average: Double
    let penalty: Penalty
    
    static func < (lhs: Average, rhs: Average) -> Bool {
        if (lhs.penalty == .dnf) { return false }
        if (rhs.penalty == .dnf) { return true }
        
        return lhs.average < rhs.average
    }
}


extension Solve {
    var timeText: String {
        get {
            return formatSolveTime(secs: self.time, penalty: Penalty(rawValue: self.penalty)!)
        }
    }
}


extension Session {
    var typeName: String {
        get {
            if SessionType(rawValue: sessionType) == .standard {
                return PUZZLE_TYPES[Int(scrambleType)].name
            } else {
                return SessionType(rawValue: sessionType)!.name()
            }
        }
    }
    
    @ViewBuilder func icon(size: CGFloat = 24) -> some View {
        if SessionType(rawValue: sessionType)! == .standard {
            Image(PUZZLE_TYPES[Int(scrambleType)].imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
        } else {
            SessionType(rawValue: sessionType)!.icon(size: size)
        }
    }
    
    var shortcutName: String {
        get {
            let scrambleName = PUZZLE_TYPES[Int(scrambleType)].name
            switch (SessionType(rawValue: sessionType)!) {
            case .standard:
                return scrambleName
            case .multiphase, .algtrainer, .compsim:
                return self.typeName + "[\(scrambleName)]"
            case .playground, .timerOnly:
                return self.typeName
            }
        }
    }
}

extension CompSimSolveGroup {
    var orderedSolves: [CompSimSolve] {
        // CSTODO + date order
        return (self.solves!.allObjects as! [CompSimSolve]).sorted(by: {$0.date! > $1.date!})
    }
    
    var avg: CalculatedAverage? {
        return StopwatchManager.getCalculatedAverage(forSolves: self.solves!.allObjects as! [Solve], name: String(localized: "Compsim Group"), isCompsim: true)
    }
}

extension Solve: Comparable {
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
    
    public static func < (lhs: Solve, rhs: Solve) -> Bool {
        return lhs.timeIncPen < rhs.timeIncPen
    }

    // I don't know if i need both but better safe than sorry
    public static func > (lhs: Solve, rhs: Solve) -> Bool {
        return lhs.timeIncPen > rhs.timeIncPen
    }
}


enum Penalty: Int16, Hashable {
    case none
    case plustwo
    case dnf
    
    func exportName() -> String? {
        return switch self {
        case .plustwo:
            "PlusTwo"
        case .dnf:
            "DNF"
        default:
            nil
        }
    }
}

#warning("NEVER CHANGE ORDER OR WILL BRICK")
enum SessionType: Int16 {
    case standard
    case algtrainer
    case multiphase
    case playground
    case compsim
    case timerOnly
    
    func name() -> String {
        switch self {
        case .standard:
            "Standard"
        case .algtrainer:
            "Algorithm Trainer"
        case .multiphase:
            "Multiphase"
        case .playground:
            "Playground"
        case .compsim:
            "Compsim"
        case .timerOnly:
            "Timer Only"
        }
    }
    
    func description() -> String {
        switch self {
        case .standard:
            return String(localized: "Standard session has one scramble type that cannot be changed later on.")
        case .algtrainer:
            return String(localized: "Algorithm trainer, to train a specific subset of algorithms.")
        case .multiphase:
            return String(localized: "A multiphase session gives you the ability to breakdown your solves into sections, such as memo/exec stages in blindfolded solving or stages in 3x3 solves.\n\nTap anywhere on the timer during a solve to record a phase lap. You can access your breakdown statistics in each time card and view overall statistics in the Stats view.")
        case .playground:
            return String(localized: "A playground session allows you to quickly change the scramble type within a session without having to specify a scramble type for the whole session.")
        case .compsim:
            return String(localized: "A compsim (Competition Simulation) session mimics a competition scenario better by recording a non-rolling session. Your solves will be split up into averages of 5 that can be accessed in your times and statistics view.\n\nStart by choosing a target to reach.")
        case .timerOnly:
            return String(localized: "Timer only sessions do not have a scramble or a session type. Solves will be recorded and stats calculated, but no scrambles are associated with solves.")
        }
    }
    
    func iconName() -> String {
        switch self {
        case .standard:
            "timer.square"
        case .algtrainer:
            "command.square"
        case .multiphase:
            "square.stack"
        case .playground:
            "square.on.square"
        case .compsim:
            "globe.asia.australia"
        case .timerOnly:
            "timer"
        }
    }
    
    @ViewBuilder func icon(size: CGFloat = 24) -> some View {
        Image(systemName: self.iconName()).font(.system(size: size * 0.88))
    }
}


// MARK: - Wrappers
struct PuzzleType {
    let name: String
    let cstimerName: String
    let imageName: String
//    let puzzle: OrgWorldcubeassociationTnoodleScramblesPuzzleRegistry
}


struct AppZoom: RawRepresentable, Identifiable {
    static let allCases = [DynamicTypeSize.xSmall,
                           DynamicTypeSize.small,
                           DynamicTypeSize.medium,
                           DynamicTypeSize.large,
                           DynamicTypeSize.xLarge,
                           DynamicTypeSize.xxLarge,
                           DynamicTypeSize.xxxLarge,
    ]
    
    static private let appZoomNames: [DynamicTypeSize: String] = [
        DynamicTypeSize.xSmall: String(localized: "Extra Small"),
        DynamicTypeSize.small: String(localized: "Small"),
        DynamicTypeSize.medium: String(localized: "Medium"),
        DynamicTypeSize.large: String(localized: "Large (Default)"),
        DynamicTypeSize.xLarge: String(localized: "Extra Large"),
        DynamicTypeSize.xxLarge: String(localized: "Extra Extra Large"),
        DynamicTypeSize.xxxLarge: String(localized: "Extra Extra Extra Large"),
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


struct SessionTypeIcon {
    var size: CGFloat = 26
    var iconName: String = ""
    var padding: (leading: CGFloat, trailing: CGFloat) = (8, 4)
}
