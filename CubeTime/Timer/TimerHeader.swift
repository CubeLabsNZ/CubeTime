import SwiftUI

struct TimerHeader: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var tabRouter: TabRouter
    @EnvironmentObject var stopWatchManager: StopWatchManager
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    
    @AppStorage(gsKeys.showSessionName.rawValue) private var showSessionName: Bool = false
    
    @State private var toggleSessionName: Bool = false
    
    var targetFocused: FocusState<Bool>.Binding
    
    @State private var textRect = CGRect()
    
    
    var body: some View {
        HStack {
            // FIRST PART: ICON + SESSION NAME
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(uiColor: .systemGray4))
                    .frame(width: (toggleSessionName ^ showSessionName) ? nil : 35, height: 35)
                    .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
                
                HStack {
                    ZStack(alignment: .center) {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 35, height: 35)
                        
                        
                        Group {
                            switch SessionTypes(rawValue: stopWatchManager.currentSession.session_type)! {
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
                    }
                    
                    if (toggleSessionName ^ showSessionName) {
                        Text(stopWatchManager.currentSession.name ?? "Unknown Session Name")
                            .font(.system(size: 17, weight: .medium))
                            .padding(.trailing, 4)
                    }
                }
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    toggleSessionName.toggle()
                }
            }
            
            // SESSION TYPE NAME
            
            switch SessionTypes(rawValue: stopWatchManager.currentSession.session_type)! {
            case .standard:
                if !(toggleSessionName ^ showSessionName) {
                    Text("STANDARD SESSION")
                        .font(.system(size: 17, weight: .medium))
                        .padding(.trailing)
                }
            case .algtrainer:
                EmptyView()
                
            case .multiphase:
                if !(toggleSessionName ^ showSessionName) {
                    Text("MULTIPHASE")
                        .font(.system(size: 17, weight: .medium))
                }
                
                HStack(spacing: 0) {
                    Text("PHASES: ")
                        .font(.system(size: 15, weight: .regular))
                    
                    Text("\(stopWatchManager.phaseCount)")
                        .font(.system(size: 15, weight: .regular))
                    
                }
                .padding(.leading, 6)
                .padding(.trailing)
            case .playground:
                if !(toggleSessionName ^ showSessionName) {
                    Text("PLAYGROUND")
                        .font(.system(size: 17, weight: .medium))
                }
                    
                Picker("", selection: $stopWatchManager.playgroundScrambleType) {
                    ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                        Text(element.name).tag(index)
                            .font(.system(size: 15, weight: .regular))
                    }
                }
                .accentColor(accentColour)
                .pickerStyle(.menu)
                .padding(.leading, 6)
                .padding(.trailing)
                
            case .compsim:
                if !(toggleSessionName ^ showSessionName) {
                    Text("COMP SIM")
                        .font(.system(size: 17, weight: .medium))
                }
                
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
                            .font(.system(size: 17, weight: .regular))
                            .frame(width: textRect.width + CGFloat(stopWatchManager.targetStr.count > 6 ? 12 : 6))
                            .submitLabel(.done)
                            .focused(targetFocused)
                            .multilineTextAlignment(.leading)
                            .tint(accentColour)
                            .modifier(TimeMaskTextField(text: $stopWatchManager.targetStr, onReceiveAlso: { text in
                                if let time = timeFromStr(text) {
                                    (stopWatchManager.currentSession as! CompSimSession).target = time
                                    
                                    try! managedObjectContext.save()
                                }
                            }))
                            .padding(.trailing, 4)
                    }
                }
                .padding(.leading, 6)
                .padding(.trailing, 12)
                .foregroundColor(accentColour)
            }
        }
        .background(Color(uiColor: .systemGray5))
        .frame(height: 35)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .padding(.horizontal)
        .padding(.top, SetValues.hasBottomBar ? 0 : tabRouter.hideTabBar ? nil : 8)
        .padding(.trailing, 24)
    }
}
