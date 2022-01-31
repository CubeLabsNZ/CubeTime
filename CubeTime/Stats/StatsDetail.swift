import SwiftUI
 
struct StatsDetail: View {
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .indigo
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.dismiss) var dismiss
   
    @State var offsetValue: CGFloat = -25
    
    @State var showSolve = false
    @State var solveToShow: Solves?
    
    let solves: CalculatedAverage
    let session: Sessions
    
    private let detailDateFormat: DateFormatter
    
    private let isCurrentCompSimAverage: Bool
    
//    let dateFormatter = DateFormatter()
//    dateFormatter.dateFormat = "h:mm a, MM/dd/yyyy"
    
    init(solves: CalculatedAverage , session: Sessions) {
        self.solves = solves
        self.session = session
        
        
        self.detailDateFormat = DateFormatter()
        
        detailDateFormat.locale = Locale(identifier: "en_US_POSIX")
        detailDateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        detailDateFormat.dateFormat = "h:mm a, MM/dd/yy"
        
        isCurrentCompSimAverage = solves.id == "Current Average"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                if solves.average != nil || isCurrentCompSimAverage {
                    if let solveToShow = solveToShow {
                        NavigationLink("", destination: TimeDetailViewOnly(solve: solveToShow, currentSolve: nil, timeListManager: nil), isActive: $showSolve)
                    }
                    ScrollView {
                        VStack (spacing: 12) {
                            if !isCurrentCompSimAverage {
                                HStack {
                                    Text(formatSolveTime(secs: solves.average!, penType: solves.totalPen))
                                        .font(.system(size: 34, weight: .bold))
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.top)
                            }
                            
                            HStack (alignment: .center) {
                                HStack (alignment: .center) {
                                    Text(session.name ?? "Unknown session name")
                                        .font(.system(size: 20, weight: .semibold, design: .default))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                    Spacer()
                                    
                                    switch SessionTypes(rawValue: session.session_type)! {
                                    case .standard:
                                        Text(puzzle_types[Int(session.scramble_type)].name)
                                            .font(.system(size: 16, weight: .semibold, design: .default))
                                            .foregroundColor(Color(uiColor: .systemGray))
                                    case .multiphase:
                                        HStack(spacing: 2) {
                                            Image(systemName: "square.stack")
                                                .font(.system(size: 14, weight: .semibold, design: .default))
                                                .foregroundColor(Color(uiColor: .systemGray))
                                            
                                            Text(puzzle_types[Int(session.scramble_type)].name)
                                                .font(.system(size: 16, weight: .semibold, design: .default))
                                                .foregroundColor(Color(uiColor: .systemGray))
                                        }
                                        
                                    case .compsim:
                                        HStack(spacing: 2) {
                                            Image(systemName: "globe.asia.australia")
                                                .font(.system(size: 16, weight: .bold, design: .default))
                                                .foregroundColor(Color(uiColor: .systemGray))
                                            
                                            Text(puzzle_types[Int(session.scramble_type)].name)
                                                .font(.system(size: 16, weight: .semibold, design: .default))
                                                .foregroundColor(Color(uiColor: .systemGray))
                                        }
                                    
                                    case .playground:
                                        Text("Playground")
                                            .font(.system(size: 16, weight: .semibold, design: .default))
                                            .foregroundColor(Color(uiColor: .systemGray))
                                    
                                    default:
                                        Text(puzzle_types[Int(session.scramble_type)].name)
                                            .font(.system(size: 16, weight: .semibold, design: .default))
                                            .foregroundColor(Color(uiColor: .systemGray))
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, isCurrentCompSimAverage ? 10 : -10)
                            
                            
                            VStack {
                                HStack {
                                    if SessionTypes(rawValue: session.session_type)! == .playground {
                                        Image(systemName: "square.filled.on.square")
                                            .symbolRenderingMode(.hierarchical)
                                            .font(.system(size: 26, weight: .semibold))
                                            .foregroundColor(colourScheme == .light ? .black : .white)
                                        
                                        Text("Playground")
                                            .font(.system(size: 17, weight: .semibold, design: .default))
                                    } else {
                                        Image(puzzle_types[Int(session.scramble_type)].name)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 32, height: 32)
                                            .padding(.leading, 2)
                                            .padding(.trailing, 4)
                                        
                                        Text(puzzle_types[Int(session.scramble_type)].name)
                                            .font(.system(size: 17, weight: .semibold, design: .default))
                                    }
                                    
                                    Spacer()
                                    
                                    Text((["2x2", "3x3", "Square-1", "Pyraminx", "Skewb", "3x3 OH", "3x3 BLD"].contains(puzzle_types[Int(session.scramble_type)].name)) ? "RANDOM STATE" : "RANDOM MOVES")
                                        .font(.system(size: 13, weight: .semibold, design: .default))
                                        .offset(y: 2)
                                                                        
                                }
                                .padding(.leading, 12)
                                .padding(.trailing)
                                .padding(.top, 12)
                                
                                VStack(spacing: 0) {
                                    ForEach(Array(zip(solves.accountedSolves!.indices, solves.accountedSolves!)), id: \.0) {index, solve in
                                        VStack(spacing: 0) {
                                            Divider()
                                                .padding(.leading)
                                                
                                            
                                            HStack(alignment: .bottom) {
                                                Text("\(index+1).")
                                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                                    .foregroundColor(accentColour)
                                                if solves.trimmedSolves!.contains(solve) {
                                                    Text("(" + formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!) + ")")
                                                        .font(.system(size: 17, weight: .bold))
                                                        .foregroundColor(Color(uiColor: .systemGray))
                                                } else {
                                                    Text(formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!))
                                                        .font(.system(size: 17, weight: .bold))
                                                }
                                                
                                                Spacer()
                                                
                                                
                                                
//                                                Text(solve.date ?? Date(timeIntervalSince1970: 0), format: .dateTime.hour().minute().second().day().month().year())
                                                Text(solve.date ?? Date(timeIntervalSince1970: 0), formatter: detailDateFormat)
                                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                                    .foregroundColor(Color(uiColor: .systemGray))
                                            }
                                            .padding(.top, 8)
                                            .padding(.horizontal)
                                            
                                            HStack {
                                                
                                                
                                                Text(solve.scramble ?? "Failed to load scramble")
                                                    .font(.system(size: solve.scramble_type == 7 ? ((UIScreen.screenWidth-32) / (42.00) * 1.42) : 16, weight: .regular, design: .monospaced))
                                                
                                                Spacer()
                                            }
                                            .padding(.horizontal)
                                            .padding(.bottom, (index != solves.accountedSolves!.indices.last!) ? 8 : 0)
                                        }
                                        .onTapGesture {
                                            solveToShow = solve
                                            showSolve = true
                                        }
                                    }
                                }
                                .padding(.bottom)
                            }
                            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:10)))
                            .padding(.top, -10)
                            .padding(.horizontal)
                        }
                        .offset(y: -6)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationTitle(solves.id == "Comp Sim Solve" ? "Comp Sim" : solves.id)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button {
                                    dismiss()
                                } label: {
//                                    Image(systemName: "chevron.left")
//                                        .font(.system(size: 17, weight: .medium))
//                                        .padding(.leading, -4)
//                                    Text(solves.id == "Comp sim solve" ? "Time list" : "Stats")
                                    Text("Done")
//                                        .padding(.leading, -4)
                                }
                            }
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button {
                                    UIPasteboard.general.string = {
                                        var str = "Generated by CubeTime.\n"
                                        str += "\(solves.id)"
                                        if let avg = solves.average {
                                            str+=": \(formatSolveTime(secs: avg, penType: solves.totalPen))"
                                        }
                                        str += "\n\n"
                                        str += "Time List:"
                                        
                                        for pair in zip(solves.accountedSolves!.indices, solves.accountedSolves!) {
                                            str += "\n\(pair.0 + 1). "
                                            let formattedTime = formatSolveTime(secs: pair.1.time, penType: PenTypes(rawValue: pair.1.penalty))
                                            if solves.trimmedSolves!.contains(pair.1) {
                                                str += "(" + formattedTime + ")"
                                            } else {
                                                str += formattedTime
                                            }
                                            
                                            str += ":\t"+pair.1.scramble!
                                        }
                                        
                                        return str
                                    }()
                                    withAnimation(Animation.interpolatingSpring(stiffness: 140, damping: 20).delay(0.25)) {
                                        self.offsetValue = 0
                                    }
                                    
                                    withAnimation(Animation.easeOut.delay(2.25)) {
                                        self.offsetValue = -25
                                    }
                                    
                                    
                                    

                                } label: {
                                    ZStack {
                                        if self.offsetValue != 0 {
                                            Image(systemName: "doc.on.doc")
    //                                        Text("Copy Average")
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundColor(accentColour)
                                               
                                        }
                                        
                                        
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .bold, design: .rounded))
                                            .clipShape(Rectangle().offset(x: self.offsetValue))
                                    }
                                    .frame(width: 20)
                                }
                            }
                        }
                    }
                } else {
                    Text("N/A")
                }
            }
        }
            .accentColor(accentColour)
    }
}
