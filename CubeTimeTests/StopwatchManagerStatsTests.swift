//
//  StopwatchManagerTests.swift
//  CubeTimeTests
//
//  Created by trainz-are-kul on 27/02/23.
//

import XCTest
@testable import CubeTime

let moc = PersistenceController.preview.container.viewContext

struct TestSolveWrapper {
    let time: Double
    let pen: Penalty
    
    init(_ time: Double, _ pen: Penalty? = nil) {
        self.time = time
        self.pen = pen ?? .none
    }
    
    func toSlove(_ session: Sessions) -> Solves {
        let solveItem = Solves(context: moc)
        solveItem.date = Date()
        solveItem.penalty = pen.rawValue
        solveItem.time = time
        solveItem.scramble = "Scramble"
        solveItem.session = session
        solveItem.scramble_type = 1
        solveItem.scramble_subtype = 0
        return solveItem
    }
}

struct TestCalculatedAverageWrapper {
    
    //    let discardedIndexes: [Int]
    let average: Double?
    let countedSolves: [Solves]
    let trimmedSolves: [Solves]
    let totalPen: Penalty
    let swm: StopwatchManager

    
    init(average: Double?, countedSolves: [TestSolveWrapper], trimmedSolves: [TestSolveWrapper], totalPen: Penalty) {
        self.average = average
        self.totalPen = totalPen
        
        
        let session = Sessions(context: moc) // Must use this variable else didset will fire prematurely
        session.scramble_type = 1
        session.session_type = SessionType.playground.rawValue
        session.name = "Default Session"
        
        self.countedSolves = countedSolves.map {$0.toSlove(session)}
        self.trimmedSolves = trimmedSolves.map {$0.toSlove(session)}
        
        
        self.swm = StopwatchManager(currentSession: session, managedObjectContext: moc)
        try! moc.save()
        swm.statsGetFromCache()
    }
    
    
    
    func test(calculatedAverage: CalculatedAverage) {
        XCTAssertEqual(calculatedAverage.totalPen, self.totalPen)
        if totalPen != .dnf {
            XCTAssertEqual(calculatedAverage.average!, self.average!, accuracy: 0.001)
            XCTAssertEqual(Set(calculatedAverage.accountedSolves!), Set(trimmedSolves + countedSolves))
            XCTAssertEqual(Set(calculatedAverage.trimmedSolves!), Set(trimmedSolves))
            //XCTAssert(calculatedAverage.trimmedSolves!.elementsEqual(trimmedSolves, by: {$0.objectID.uriRepresentation().absoluteString == $1.objectID.uriRepresentation().absoluteString}))
        }
    }
}

typealias TCAWrapper = TestCalculatedAverageWrapper



final class TestRegular: XCTestCase {
    var testData: [TestCalculatedAverageWrapper]! = nil
    
    override func setUpWithError() throws {
        self.testData = [
            TCAWrapper(
                average: nil,
                countedSolves: [.init(1.456, .dnf), .init(1.328, .dnf), .init(1.335, .dnf), .init(1.863, .dnf), .init(2.386, .dnf)],
                trimmedSolves: [],
                totalPen: .dnf
            ),
            TCAWrapper(
                average: nil,
                countedSolves: [.init(1.456, .dnf), .init(1.328), .init(1.335, .dnf), .init(1.863), .init(2.386, .dnf)],
                trimmedSolves: [],
                totalPen: .dnf
            ),
            TCAWrapper(
                average: nil,
                countedSolves: [.init(1.456), .init(1.328, .dnf), .init(1.335), .init(1.863), .init(2.386, .dnf)],
                trimmedSolves: [],
                totalPen: .dnf
            ),
            TCAWrapper(
                average: 4.654 / 3,
                countedSolves: [.init(1.456), .init(1.335), .init(1.863)],
                trimmedSolves: [.init(1.328), .init(2.386)],
                totalPen: .none
            )
        ]
    }

    func testExample() throws {
        #warning("TODO check more than just .average")
        for test in testData {
            test.test(calculatedAverage: test.swm.bestAo5!)
        }
    }
}

#warning("TODO: test performance")
