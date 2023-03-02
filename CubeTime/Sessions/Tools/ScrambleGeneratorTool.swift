//
//  ScrambleGeneratorTool.swift
//  CubeTime
//
//  Created by trainz-are-kul on 26/02/23.
//

import SwiftUI

class ScrambleThread: Thread {
    let waiter = DispatchGroup()
    
    let semaphore: DispatchSemaphore
    let scrGen: ScrambleGenerator
    let count: Int
    let scrType: Int32
    
    var isolate: OpaquePointer?
    var thread: OpaquePointer?
    
    
    init(isolate: OpaquePointer?, semaphore: DispatchSemaphore, scrGen: ScrambleGenerator, count: Int, scrType: Int32) {
        self.isolate = isolate
        self.semaphore = semaphore
        self.scrGen = scrGen
        self.count = count
        self.scrType = scrType
        super.init()
    }

    override func start() {
        #if DEBUG
        NSLog("SCRAMBLETHREAD: START CALLED")
        #endif
        
        waiter.enter()
        super.start()
    }
    
    override func main() { // Thread's starting point
        #if DEBUG
        NSLog("SCRAMBLETHREAD: MAIN CALLED")
        #endif
        
        
//        graal_create_isolate(nil, &isolate, &thread)
        graal_attach_thread(isolate, &thread)
        while (true) {
            let s = String(cString: tnoodle_lib_scramble(thread, scrType))
            
            if isCancelled {
                break
            }
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
        
//        graal_tear_down_isolate(thread);
        graal_detach_thread(thread)
        waiter.leave()
        
        #if DEBUG
        NSLog("SCRAMBLETHREAD: THREAD DONE")
        #endif
    }
    override func cancel() {
        super.cancel()
        
        #if DEBUG
        NSLog("SCRAMBLETHREAD: CANCEL CALLED")
        #endif
    }
    
    func join() {
        waiter.wait()
    }
}


class ScrambleGenerator: ObservableObject {
    @Published var numScramble: Int? = nil
    @Published var scrambleType: Int = 1
    
    @Published var scrambles: [String]?
    
    var threads: [ScrambleThread]!
    
    var isolate: OpaquePointer?
    var thread: OpaquePointer?
    
    func generate() {
        let semaphore = DispatchSemaphore(value: 1)
        
        self.scrambles = []
        
        graal_create_isolate(nil, &isolate, &thread)
        
        self.threads = (0..<ProcessInfo.processInfo.processorCount).map {_ in
            let t = ScrambleThread(isolate: isolate, semaphore: semaphore, scrGen: self, count: numScramble!, scrType: Int32(scrambleType))
            t.qualityOfService = .utility
            return t
        }
        threads.forEach {$0.start()}
    }
    
    func cancel() {
        self.threads?.forEach({
            $0.cancel()
        })
        graal_tear_down_isolate(thread)
    }
}

struct ScrambleGeneratorTool: View {
    @StateObject var scrambleGenerator = ScrambleGenerator()
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @EnvironmentObject var fontManager: FontManager
    
    @State private var showShareSheet = false
    
    var body: some View {
        VStack {

            ToolHeader(name: tools[2].name, image: tools[2].iconName, onClose: scrambleGenerator.cancel, content: {
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
                                    let toShare: String = "Generated by CubeTime.\n" + scrambleGenerator.scrambles!.joined(separator: "\n")
                                    
                                    let activityViewController = UIActivityViewController(activityItems: [toShare], applicationActivities: nil)
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
                                                .font(Font(CTFontCreateWithFontDescriptor(fontManager.ctFontDescBold, 15, nil)))
                                                .offset(y: 1)
                                            
                                            Text(scramble)
                                                .font(Font(CTFontCreateWithFontDescriptor(fontManager.ctFontDesc, 17, nil)))
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
