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
    @StateObject var scrambleGenerator = ScrambleGenerator()
    @EnvironmentObject var stopwatchManager: StopwatchManager
    
    @State private var showShareSheet = false
    
    var body: some View {
        VStack {

            ToolHeader(name: tools[2].name, image: tools[2].iconName, content: {
                
                Picker("", selection: $scrambleGenerator.scrambleType) {
                    ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                        Text(element.name).tag(index)
                            .font(.system(size: 15, weight: .regular))
                    }
                }
            })
            
            VStack {
                HStack {
                    ZStack {
                        TextField("Number of Scrambles...", text: Binding(get: {
                            if let num = scrambleGenerator.numScramble {
                                return String(num)
                            } else {
                                return ""
                            }
                        }, set: { val in
                            if let temp = Int(val.components(separatedBy:CharacterSet.decimalDigits.inverted)
                                .joined()) {
                                if (temp <= 5000) {
                                    scrambleGenerator.numScramble = temp
                                }
                            } else {
                                scrambleGenerator.numScramble = nil
                            }
                        }))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .frame(height: 35)
                        .foregroundColor((scrambleGenerator.numScramble == nil || scrambleGenerator.scrambles?.count != nil) ? Color("grey") : Color("dark"))
                        .disabled(scrambleGenerator.scrambles?.count != nil)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color("indent2"))
                    )
                    .animation(Animation.customDampedSpring, value: scrambleGenerator.numScramble)
                    
                    if let num = scrambleGenerator.numScramble {
                        if (num > 0 && (scrambleGenerator.scrambles?.count == nil)) {
                            HierarchialButton(type: .coloured, size: .large, onTapRun: {
                                scrambleGenerator.generate()
                            }) {
                                Text("Generate!")
                            }
                        }
                    }
                }
                
                if let num = scrambleGenerator.numScramble {
                    if let currentCount = scrambleGenerator.scrambles?.count {
                        if (currentCount >= 1) {
                            ProgressView(value: Double(scrambleGenerator.scrambles?.count ?? 0),
                                         total: Double(num))
                        }
                        
                        if (currentCount == num && num != 0) {
                            Text("Success!")
                                .font(.body.weight(.semibold))
                                .foregroundColor(Color.accentColor)
                            
                            HierarchialButton(type: .coloured, size: .large, onTapRun: {
                                self.showShareSheet = true
                            }) {
                                Text("Share")
                            }
                            .background(
                                ShareSheetViewController(isPresenting: self.$showShareSheet) {
                                    let activityViewController = UIActivityViewController(activityItems: [scrambleGenerator.scrambles!.reduce("", {return "\($0)\n\($1)"})], applicationActivities: nil)
                                    activityViewController.isModalInPresentation = true
                                    
                                    // something something ipad TODO
                                    /* if iPad, present as popoverpresentationcontroller
                                     
                                     if UIDevice.current.userInterfaceIdiom == .pad {
                                        av.popoverPresentationController?.sourceView = UIView()
                                     }
                                     */
                                    
                                    activityViewController.completionWithItemsHandler = { _, _, _, _ in
                                        self.showShareSheet = false
                                    }
                                    
                                    return activityViewController
                                }
                            )
                            
                            ScrollView {
                                LazyVStack(alignment: .leading) {
                                    ForEach(Array(zip(scrambleGenerator.scrambles!.indices, scrambleGenerator.scrambles!)), id: \.0) { index, scramble in
                                        HStack(alignment: .top) {
                                            Text("\(index+1). ")
                                                .font(Font(CTFontCreateWithFontDescriptor(stopwatchManager.ctFontDescBold, 15, nil)))
                                                .offset(y: 1)
                                            
                                            Text(scramble)
                                                .font(Font(CTFontCreateWithFontDescriptor(stopwatchManager.ctFontDesc, 17, nil)))
                                                .textSelection(.enabled)
                                                .padding(.bottom, 6)
                                        }
                                    }
                                }
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(12)
                            }
                            .background (
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color("overlay1"))
                            )
                        }
                    }
                }
                
                
                Spacer()
            }.padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("base").ignoresSafeArea())
    }
}
