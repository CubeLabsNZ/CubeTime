//
//  TimerHeader.swift
//  CubeTime
//
//  Created by macos sucks balls on 5/15/22.
//

import SwiftUI

struct TimerHeader: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var stopWatchManager: StopWatchManager
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    var targetFocused: FocusState<Bool>.Binding? = nil
    
    @State private var textRect = CGRect()
    
    
    var body: some View {
        
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(uiColor: .systemGray4))
                    .frame(width: 35, height: 35)
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                switch SessionTypes(rawValue: stopWatchManager.currentSession.session_type)! {
                    // TODO extension for icon names
                case .standard:
                    Image(systemName: "timer.square")
                        .font(.system(size: 26, weight: .regular))
                case .algtrainer:
                    Image(systemName: "command.square")
                        .font(.system(size: 26, weight: .regular))
                case .multiphase:
                    Image(systemName: "square.stack")
                        .font(.system(size: 22, weight: .regular))
                case .playground:
                    Image(systemName: "square.on.square")
                        .font(.system(size: 22, weight: .regular))
                case .compsim:
                    Image(systemName: "globe.asia.australia")
                        .font(.system(size: 22, weight: .medium))
                }
            }
            
            // TOP BAR
            switch SessionTypes(rawValue: stopWatchManager.currentSession.session_type)! {
            case .standard:
                Text("STANDARD SESSION")
                    .font(.system(size: 17, weight: .medium))
                    .padding(.trailing)
            case .algtrainer:
                EmptyView()
                //                        Text("ALG TRAINER")
                //                            .font(.system(size: 17, weight: .medium))
                //                        Picker("", selection: $algTrainerSubset) {
                //                            Text("EG-1")
                //                                .font(.system(size: 15, weight: .regular))
                //                        }
                //                        .pickerStyle(.menu)
                //                        .padding(.leading, 6)
                //                        .padding(.trailing)
                //                        .accentColor(accentColour)
            case .multiphase:
                Text("MULTIPHASE")
                    .font(.system(size: 17, weight: .medium))
                
                HStack(spacing: 0) {
                    Text("PHASES: ")
                        .font(.system(size: 15, weight: .regular))
                    
                    Text("\(stopWatchManager.phaseCount)")
                        .font(.system(size: 15, weight: .regular))
                    
                    /// TEMPORARILY REMOVED THE PICKER UNTIL MULTIPHASE PLAYGROUND IS ADDED - MIGRATE TO THERE
                    
                    /*
                     Picker("", selection: $phaseCount) {
                     ForEach((2...8), id: \.self) { phase in
                     Text("\(phase)").tag(phase)
                     .font(.system(size: 15, weight: .regular))
                     }
                     }
                     .pickerStyle(.menu)
                     .frame(width: 8)
                     .onChange(of: phaseCount) { newValue in
                     (currentSession as! MultiphaseSession).phase_count = Int16(phaseCount)
                     
                     try! managedObjectContext.save()
                     }
                     */
                }
                .padding(.leading, 6)
                .padding(.trailing)
            case .playground:
                Text("PLAYGROUND")
                    .font(.system(size: 17, weight: .medium))
                
                Picker("", selection: $stopWatchManager.playgroundScrambleType) {
                    ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                        Text(element.name).tag(Int32(index))
                            .font(.system(size: 15, weight: .regular))
                    }
                }
                .accentColor(accentColour)
                .pickerStyle(.menu)
                .padding(.leading, 6)
                .padding(.trailing)
                
            case .compsim:
                Text("COMP SIM")
                    .font(.system(size: 17, weight: .medium))
                
                let solveth: Int = stopWatchManager.currentSolveth!+1
                
                Text("SOLVE \(solveth == 6 ? 1 : solveth)")
                    .font(.system(size: 15, weight: .regular))
                    .padding(.horizontal, 2)
                
                Divider()
                    .padding(.vertical, 4)
                
                HStack (spacing: 10) {
                    Image(systemName: "target")
                        .font(.system(size: 15))
                        .foregroundColor(accentColour)
                    
                    ZStack {
                        Text(stopWatchManager.targetStr == "" ? "0.00" : stopWatchManager.targetStr)
                            .background(GlobalGeometryGetter(rect: $textRect))
                            .layoutPriority(1)
                            .opacity(0)
                        
                        
                        TextField("0.00", text: $stopWatchManager.targetStr)
                            .frame(width: textRect.width + CGFloat(stopWatchManager.targetStr.count > 6 ? 12 : 6))
                        //                                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .submitLabel(.done)
                            .multilineTextAlignment(.leading)
                            .tint(accentColour)
                            .modifier(TimeMaskTextField(text: $stopWatchManager.targetStr, onReceiveAlso: { text in
                                if let time = timeFromStr(text) {
                                    (stopWatchManager.currentSession as! CompSimSession).target = time
                                    
                                    try! managedObjectContext.save()
                                }
                                //                                                timeNeededForTarget = stats.getTimeNeededForTarget()
                            }))
                            .padding(.trailing, 4)
                        //                                    .if (targetFocused != nil) { view in
                        //                                        view
                        //                                            .focused(targetFocused!)
                        //                                    }
                    }
                    
                }
                .padding(.leading, 6)
                .padding(.trailing, 12)
                .foregroundColor(accentColour)
                
                
                //                            TextField(compSimTarget, text: $compSimTarget)
                //                                .keyboardType(.decimalPad)
            }
        }
        .background(Color(uiColor: .systemGray5))
        .frame(height: 35)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(.horizontal)
        .if (targetFocused != nil) { view in
            view
                .padding(.top, SetValues.hasBottomBar ? 0 : (stopWatchManager.mode == .inspecting || stopWatchManager.mode == .running) ? nil : 8)
        }
        
    }
}

struct TimerHeader_Previews: PreviewProvider {
    static let moc = PersistenceController.shared.container.viewContext
    static let managers: [StopWatchManager] = {
        var swmanagers: [StopWatchManager] = []
        
        // https://swiftui-lab.com/random-lessons/#data-10
        
        // TODO for loop
        
        let session0 = Sessions(context: moc)
        session0.name = "Session 1 (Standard)"
        session0.scramble_type = 3
        session0.session_type = SessionTypes.standard.rawValue
        
        swmanagers.append(StopWatchManager(currentSession: session0, managedObjectContext: moc))
        
        let session1 = MultiphaseSession(context: moc)
        session1.name = "Session 2 (Muliphase)"
        session1.scramble_type = 4
        session1.phase_count = 4
        session1.session_type = SessionTypes.multiphase.rawValue
        
        swmanagers.append(StopWatchManager(currentSession: session1, managedObjectContext: moc))
        
        let session2 = Sessions(context: moc)
        session2.name = "Session 3 (Playground)"
        session2.scramble_type = 4
        session2.session_type = SessionTypes.playground.rawValue
        
        swmanagers.append(StopWatchManager(currentSession: session2, managedObjectContext: moc))
        
        let session3 = CompSimSession(context: moc)
        session3.name = "Session 4 (CompSim)"
        session3.scramble_type = 4
        session3.session_type = SessionTypes.compsim.rawValue
        
        swmanagers.append(StopWatchManager(currentSession: session3, managedObjectContext: moc))
        
        return swmanagers
    }()
    
    static var previews: some View {
        ForEach (Array(zip(managers.indices, managers)), id: \.0) { _, stopWatchManager in
            TimerHeader()
                .environmentObject(stopWatchManager)
                .environment(\.managedObjectContext, moc)
        }
    }
}
