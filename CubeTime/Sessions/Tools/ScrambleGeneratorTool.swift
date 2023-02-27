//
//  ScrambleGeneratorTool.swift
//  CubeTime
//
//  Created by trainz-are-kul on 26/02/23.
//

import SwiftUI

class ScramblesListWrapper {
    var scrambles: [String] = []
}

class ScrambleThread: Thread {
    let waiter = DispatchGroup()
    
    let semaphore: DispatchSemaphore
    var isolate: OpaquePointer?
    let scrGen: ScrambleGenerator
    let count: Int
    let scrType: Int32
    
    var thread: OpaquePointer? = nil
    
    
    init(isolate: OpaquePointer?, semaphore: DispatchSemaphore, scrGen: ScrambleGenerator, count: Int, scrType: Int32) {
        self.isolate = isolate
        self.semaphore = semaphore
        self.scrGen = scrGen
        self.count = count
        self.scrType = scrType
        super.init()
    }

    override func start() {
        NSLog("THREAD STARTED")
//        let ret = graal_attach_thread(isolate, &thread)
//        let ret = graal_create_isolate(nil, &isolate, &thread)
//        NSLog("graal_attach_thread: \(ret)")
        waiter.enter()
        super.start()
    }
    
    override func main() { // Thread's starting point
        graal_create_isolate(nil, &isolate, &thread)
        while (true) {
//            let scramble = tnoodle_lib_scramble(thread, scrType)
                    
            let s = String(cString: tnoodle_lib_scramble(thread, scrType))
            
            
            
            semaphore.wait()
            if scrGen.scrambles.unsafelyUnwrapped.count < count {
                DispatchQueue.main.async { [self] in
                    scrGen.scrambles!.append(s)
                    semaphore.signal()
                }
            } else {
                semaphore.signal()
                break
            }
        }
        
        graal_detach_thread(thread);
//        graal_tear_down_isolate(thread)
        waiter.leave()
        NSLog("Thread DOne")
    }
    override func cancel() {
        graal_detach_thread(thread);
//        graal_tear_down_isolate(thread)
        waiter.leave()
    }
    
    func join() {
        waiter.wait()
    }
}


class ScrambleGenerator: ObservableObject {
    @Published var numScramble: Int? = nil
    @Published var scrambleType: Int = 1
    
    @Published var scrambles: [String]?
    
    func generate() {
        let semaphore = DispatchSemaphore(value: 1)
        var isolate: OpaquePointer? = nil
        let i = graal_create_isolate(nil, &isolate, nil)
        NSLog("graal_create_isolate: \(i)")
        let arrayWrapper = ScramblesListWrapper()
        
        scrambles = []
        
        let threads = (0..<ProcessInfo.processInfo.processorCount).map {_ in
            let t = ScrambleThread(isolate: isolate, semaphore: semaphore, scrGen: self, count: numScramble!, scrType: Int32(scrambleType))
            t.qualityOfService = .utility
            return t
        }
        threads.forEach {$0.start()}
        NSLog("STARTED")
    }
}

struct ScrambleGeneratorTool: View {
    @Binding var showOverlay: Tool?
    var namespace: Namespace.ID
    @StateObject var scrambleGenerator = ScrambleGenerator()
    
    var body: some View {
        VStack {
            ToolHeader(name: "Scramble Generator", image: "macstudio", showOverlay: $showOverlay, namespace: namespace)
            VStack {
                TextField("Number of scrambles", text: Binding(get: {
                    if let num = scrambleGenerator.numScramble {
                        return String(num)
                    } else {
                        return ""
                    }
                }, set: { val in
                    scrambleGenerator.numScramble = Int(val.components(separatedBy:CharacterSet.decimalDigits.inverted)
                        .joined())
                }))
                
                
                Picker("", selection: $scrambleGenerator.scrambleType) {
                    ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                        Text(element.name).tag(index)
                            .font(.system(size: 15, weight: .regular))
                    }
                }

                HierarchialButton(type: .coloured, size: .large, onTapRun: {
                    scrambleGenerator.generate()
                }) {
                    Text("Generate!")
                }
                .disabled(scrambleGenerator.numScramble == nil)
                
                ProgressView(value: Double(scrambleGenerator.scrambles?.count ?? 0), total: Double(scrambleGenerator.numScramble ?? 0))
                
                
                
                HierarchialButton(type: .coloured, size: .large, onTapRun: {
                    let activityVC = UIActivityViewController(activityItems: scrambleGenerator.scrambles!, applicationActivities: nil)
                    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
                }) {
                    Text("Share")
                }
                .disabled(scrambleGenerator.scrambles?.count != scrambleGenerator.numScramble)
                
                Spacer()
            }.padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("base").ignoresSafeArea())
    }
}

struct ScrambleGeneratorTool_Previews: PreviewProvider {
    @Namespace static private var namespace
    static var previews: some View {
        ScrambleGeneratorTool(showOverlay: .constant(nil), namespace: namespace)
    }
}
