import Foundation
import SwiftUI

class ScrambleController: ObservableObject {    
    @Published var scrambleType: Int32 {
        didSet {
            rescramble()
        }
    }
    
    var scrambleWorkItem: DispatchWorkItem?
    var prevScrambleStr: String! = nil
    
    let onSetScrambleStr: ((_ newScr: String?) -> ())?
    
    @Published var scrambleSVG: String? = nil
    @Published var scrambleStr: String? = nil {
        didSet {
            onSetScrambleStr?(scrambleStr)
        }
    }
    
    init(scrambleType: Int32 = 1, onSetScrambleStr: ((_ newScr: String?) -> ())? = nil) {
        self.scrambleType = scrambleType
        self.onSetScrambleStr = onSetScrambleStr
    }
    
    func safeGetScramble() -> String {
        var isolate: OpaquePointer? = nil
        var thread: OpaquePointer? = nil
        
        graal_create_isolate(nil, &isolate, &thread)
        
        let s = String(cString: tnoodle_lib_scramble(thread, scrambleType))
        
        graal_tear_down_isolate(thread);
            
        return s
    }
    
    
    func rescramble() {
        #if DEBUG
        NSLog("Rescramble called")
        #endif
        
        prevScrambleStr = scrambleStr
        scrambleStr = nil
        scrambleSVG = nil
        let newWorkItem = DispatchWorkItem {
            let scrTypeAtWorkStart = self.scrambleType
            let scramble = self.safeGetScramble()

            if scrTypeAtWorkStart == self.scrambleType {
                DispatchQueue.main.async {
                    self.scrambleStr = scramble
                }
                
                var isolate: OpaquePointer? = nil
                var thread: OpaquePointer? = nil
                
                
                
                graal_create_isolate(nil, &isolate, &thread)
                
                var svg: String!
                
                scramble.withCString { s in
                    svg = String(cString: tnoodle_lib_draw_scramble(thread, scrTypeAtWorkStart, s))
                }
                
                graal_tear_down_isolate(thread);
                
            
                DispatchQueue.main.async {
                    self.scrambleSVG = svg
                }
            } else {
                self.scrambleWorkItem?.cancel()
            }
        }
        scrambleWorkItem = newWorkItem
        DispatchQueue.global(qos: .userInitiated).async(execute: newWorkItem)
    }
}
