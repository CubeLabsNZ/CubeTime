import Foundation
import SwiftUI



extension Solve {
    var timeText: String {
        get {
            return formatSolveTime(secs: self.time, penType: Penalty(rawValue: self.penalty)!)
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
            let scrname = puzzleTypes[Int(scrambleType)].name
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

extension CompSimSolveGroup {
    var orderedSolves: [CompSimSolve] {
        // CSTODO + date order
        return (self.solves!.allObjects as! [CompSimSolve]).sorted(by: {$0.date! > $1.date!})
    }
    
    var avg: CalculatedAverage? {
        return StopwatchManager.getCalculatedAverage(forSolves: self.solves!.allObjects as! [Solve], name: "Comp Sim Group", isCompsim: true)
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
}

enum SessionType: Int16 {
    case standard
    case algtrainer
    case multiphase
    case playground
    case compsim
}


// MARK: - Wrappers
struct PuzzleType {
    let name: String
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


struct SessionTypeIcon {
    var size: CGFloat = 26
    var iconName: String = ""
    var padding: (leading: CGFloat, trailing: CGFloat) = (8, 4)
    var weight: Font.Weight = .regular
}
