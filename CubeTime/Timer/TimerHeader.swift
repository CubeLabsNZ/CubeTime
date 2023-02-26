import SwiftUI

struct SessionIconView: View {
    let session: Sessions
    var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .fill(Color.clear)
                .frame(width: 35, height: 35)
            
            
            Group {
                switch SessionTypes(rawValue: session.session_type)! {
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
        .frame(width: 35, height: 35)
    }
}

struct TimerHeader: View {
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var tabRouter: TabRouter
    @EnvironmentObject var stopwatchManager: StopwatchManager
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .accentColor
    
    @AppStorage(gsKeys.showSessionName.rawValue) private var showSessionName: Bool = false
    
    @State private var toggleSessionName: Bool = false
    
    var targetFocused: FocusState<Bool>.Binding?
    
    @State private var textRect = CGRect()
    
    let previewMode: Bool
    
    var body: some View {
        HStack {
            if previewMode {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color("overlay0"))
                        .frame(width: 35, height: 35)
                        .shadowDark(x: 2, y: 0)
                    
                    HStack {
                        ZStack(alignment: .center) {
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 35, height: 35)
                            
                            
                            Group {
                                Image(systemName: "eyes")
                                    .font(.system(size: 22, weight: .regular))
                            }
                        }
                        
                        Text("PREVIEW")
                            .font(.system(size: 17, weight: .medium))
                            .padding(.trailing)
                    }
                }
            } else {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color("overlay0"))
                        .frame(width: (toggleSessionName ^ showSessionName) ? nil : 35, height: 35)
                        .shadowDark(x: 2, y: 0)
                    
                    HStack {
                        SessionIconView(session: stopwatchManager.currentSession)
                        
                        if (toggleSessionName ^ showSessionName) {
                            Text(stopwatchManager.currentSession.name ?? "Unknown Session Name")
                                .font(.system(size: 17, weight: .medium))
                                .padding(.trailing, 4)
                        }
                    }
                }
                .onTapGesture {
                    withAnimation(Animation.customSlowSpring) {
                        toggleSessionName.toggle()
                    }
                }
                
                // SESSION TYPE NAME
                
                switch SessionTypes(rawValue: stopwatchManager.currentSession.session_type)! {
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
                        
                        Text("\(stopwatchManager.phaseCount)")
                            .font(.system(size: 15, weight: .regular))
                        
                    }
//                    .padding(.leading, 6)
//                    .padding(.trailing)
                case .playground:
                    if !(toggleSessionName ^ showSessionName) {
                        Text("PLAYGROUND")
                            .font(.system(size: 17, weight: .medium))
                    }
                    
                    Picker("", selection: $stopwatchManager.playgroundScrambleType) {
                        ForEach(Array(zip(puzzle_types.indices, puzzle_types)), id: \.0) { index, element in
                            Text(element.name).tag(Int32(index))
                                .font(.system(size: 15, weight: .regular))
                        }
                    }
                    .accentColor(accentColour)
                    .pickerStyle(.menu)
//                    .padding(.leading, 6)
//                    .padding(.trailing)
//                    .fixedSize()
                    
                case .compsim:
                    if !(toggleSessionName ^ showSessionName) {
                        Text("COMP SIM")
                            .font(.system(size: 17, weight: .medium))
                    }
                    
                    let solveth: Int = stopwatchManager.currentSolveth!+1
                    
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
                            Text(stopwatchManager.targetStr == "" ? "0.00" : stopwatchManager.targetStr)
                                .background(GlobalGeometryGetter(rect: $textRect))
                                .layoutPriority(1)
                                .opacity(0)
                            
                            
                            TextField("0.00", text: $stopwatchManager.targetStr)
                                .font(.system(size: 17, weight: .regular))
                                .frame(width: textRect.width + CGFloat(stopwatchManager.targetStr.count > 6 ? 12 : 6))
                                .submitLabel(.done)
                                .focused(targetFocused!)
                                .multilineTextAlignment(.leading)
                                .tint(accentColour)
                                .modifier(TimeMaskTextField(text: $stopwatchManager.targetStr, onReceiveAlso: { text in
                                    if let time = timeFromStr(text) {
                                        (stopwatchManager.currentSession as! CompSimSession).target = time
                                        
                                        try! managedObjectContext.save()
                                    }
                                }))
                                .padding(.trailing, 4)
                        }
                    }
//                    .padding(.leading, 6)
//                    .padding(.trailing, 12)
                    .foregroundColor(accentColour)
                }
            }
        }
        .frame(height: 35)
        .background(
            Color("overlay1")
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .animation(Animation.customFastSpring, value: stopwatchManager.playgroundScrambleType)
        )
        .padding(.top, SetValues.hasBottomBar ? 0 : tabRouter.hideTabBar ? nil : 8)
    }
}
