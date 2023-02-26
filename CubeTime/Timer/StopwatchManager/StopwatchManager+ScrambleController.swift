import Foundation
import SwiftUI

extension StopwatchManager {
    func safeGetScramble() -> String {
        var isolate: OpaquePointer? = nil
        var thread: OpaquePointer? = nil
        
        
        graal_create_isolate(nil, &isolate, &thread)
                
        let s = String(cString: tnoodle_lib_scramble(thread, currentSession.scramble_type))
        
        graal_tear_down_isolate(thread);
            
        return s
    }
    
    
    func rescramble() {
        #if DEBUG
        NSLog("rescramble")
        #endif
        
        prevScrambleStr = scrambleStr
        scrambleStr = nil
        if mode == .stopped {
            self.timerColour = Color.Timer.loading
        }
        scrambleSVG = nil
        let newWorkItem = DispatchWorkItem {
            #if DEBUG
            NSLog("running work item")
            #endif
            
            
            let scrTypeAtWorkStart = self.currentSession.scramble_type
            let scramble = self.safeGetScramble()

            #warning("TODO switch to mutex or something")
            if scrTypeAtWorkStart == self.currentSession.scramble_type {
                DispatchQueue.main.async {
                    self.scrambleStr = scramble
                    self.timerColour = Color.Timer.normal
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
