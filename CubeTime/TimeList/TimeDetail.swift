//
//  TimeDetail.swift
//  CubeTime
//
//  Created by Tim Xie on 10/01/22.
//

import SwiftUI

struct TimeDetail: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    
    @AppStorage(asKeys.accentColour.rawValue) private var accentColour: Color = .accentColor

    
    @State var offsetValue: CGFloat = -25
    
    let scramble: String
    let time: String

    let phases: Array<Double>?
    
    @EnvironmentObject var stopWatchManager: StopWatchManager
    
    let solve: Solves
    @Binding var currentSolve: Solves?
    
    
    init(solve: Solves, currentSolve: Binding<Solves?>?) {
        
        self.solve = solve
        self._currentSolve = currentSolve ?? Binding.constant(nil)
        
        self.scramble = solve.scramble ?? "Retrieving scramble failed."
        self.time = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)

        
        if let multiphaseSolve = (solve as? MultiphaseSolve) {
            self.phases = multiphaseSolve.phases ?? [0.00, 0.00, 0.00, 0.00]
//            Array(zip(multiphaseSolve.phases!.indices, multiphaseSolve.phases!))
        } else {
            self.phases = nil
        }

        
    }
    
    var body: some View {
        NavigationView {
            TimeDetailViewOnly(solve: solve, currentSolve: $currentSolve)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        currentSolve = nil
                        
                        dismiss()
                        
                        if managedObjectContext.hasChanges {
                            try! managedObjectContext.save()
                        }
                    } label: {
                        Text("Done")
                    }
                }
                
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        copySolve(solve: solve)
                        
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
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(accentColour)
                                   
                            }
                            
                            
                            Image(systemName: "checkmark")
                                .font(Font.system(.footnote, design: .rounded).weight(.bold))
                                .clipShape(Rectangle().offset(x: self.offsetValue))
                        }
                        .frame(width: 20)
                    }
                }
            }
        }
    }
}





struct TimeDetailViewOnly: View {
    @Environment(\.presentationMode) var presentation
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.globalGeometrySize) var globalGeometrySize
    
    @EnvironmentObject var stopWatchManager: StopWatchManager

    @Environment(\.dismiss) var dismiss
    private let titleDateFormat: DateFormatter
    
    @State var offsetValue: CGFloat = -25
    
    @FocusState private var commentFocus: Bool
    
    let solve: Solves
    
    // Copy all items out of solve that are used by the UI
    // This is so that when the item is deleted they don't reset to default values
    let date: Date
    let time: String
    let puzzle_type: PuzzleType
    let scramble: String
    let phases: Array<Double>?
    
    @Binding var currentSolve: Solves?
    
    @State private var userComment: String
    
    
    init(solve: Solves, currentSolve: Binding<Solves?>?){
        NSLog("Initi")
        self.solve = solve
        self.date = solve.date ?? Date(timeIntervalSince1970: 0)
        self.time = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
        self.puzzle_type = puzzle_types[Int(solve.scramble_type)]
        self.scramble = solve.scramble ?? "Retrieving scramble failed."
            
        if let multiphaseSolve = (solve as? MultiphaseSolve) {
            self.phases = multiphaseSolve.phases ?? [0.00, 0.00, 0.00, 0.00]
//            Array(zip(multiphaseSolve.phases!.indices, multiphaseSolve.phases!))
        } else {
            self.phases = nil
        }
        
        self._currentSolve = currentSolve ?? Binding.constant(nil)
        _userComment = State(initialValue: solve.comment ?? "")

        
        self.titleDateFormat = DateFormatter()
        
        titleDateFormat.locale = Locale(identifier: "en_US_POSIX")
        titleDateFormat.timeZone = TimeZone(secondsFromGMT: 0)
        titleDateFormat.dateFormat = "h:mm a, MMM d, yyyy"
    }
    
    var body: some View {
        ZStack {
            Color.bg(colourScheme)
                .ignoresSafeArea()
            
            GeometryReader { geo in
                ScrollView {
                    VStack (spacing: 12) {
                        HStack {
                            Text(time)
                                .font(.largeTitle.weight(.bold))
                            
                            switch solve.penalty {
                            case PenTypes.dnf.rawValue:
                                let rawTime = formatSolveTime(secs: solve.time)
                                Text("(\(rawTime))")
                                    .font(.largeTitle.weight(.bold))
                                
                                Spacer()
                                
                            case PenTypes.plustwo.rawValue:
                                Spacer()
                                
                                let addedTime = formatSolveTime(secs: (solve.time + 2))
                                Text("(\(addedTime))")
                                    .font(.title3.weight(.semibold))
                                    .foregroundColor(Color(uiColor: .systemGray))
                                    .padding(.leading)
                            default:
                                Spacer()
                            }
                            
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        HStack {
                            Text(date, formatter: titleDateFormat)
                                .font(.title2.weight(.semibold))
                                .foregroundColor(Color(uiColor: .systemGray))
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, -10)
                        
                        VStack {
                            HStack {
                                Image(puzzle_type.name)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    
                                    .padding(.leading, 2)
                                    .padding(.trailing, 4)
                                
                                Text(puzzle_type.name)
                                    .font(.body.weight(.semibold))
                                
                                Spacer()
                                
                                Text((["2x2", "3x3", "Square-1", "Pyraminx", "Skewb", "3x3 OH", "3x3 BLD"].contains(puzzle_type.name)) ? "RANDOM STATE" : "RANDOM MOVES")
                                    .font(.footnote.weight(.semibold))
                                    .offset(y: 2)
                            }
                            .padding(.leading, 12)
                            .padding(.trailing)
                            .padding(.top, 12)
                            
                            Divider()
                                .padding(.leading)
                            
                            // TODO check result instead != nil instead
                            
    //                        let brokenScramble: Bool = chtscramblesthatdontworkwithtnoodle.contains(puzzle_type.puzzle) && (date < Date(timeIntervalSince1970: TimeInterval(1643760000)))
                            
                            Group {
                                if puzzle_type.name == "Megaminx" {
                                    Text(scramble)
                                        .fixedSize(horizontal: true, vertical: false)
                                        .multilineTextAlignment(.leading)
                                        // WORKAROUND
                                        .minimumScaleFactor(0.00001)
                                        .scaledToFit()
                                } else {
                                    Text(scramble)
                                }
                            }
                            .font(Font(CTFontCreateWithFontDescriptor(stopWatchManager.ctFontDesc, 16, nil)))
                            .foregroundColor(colourScheme == .light ? .black : .white)
                            .padding([.horizontal], 12)
                            
                            
                            
                            Divider()
                                .padding(.leading)
                            
                            AsyncSVGView(puzzle: solve.scramble_type, scramble: scramble)
                                .frame(maxWidth: 300)
                                .padding(.bottom)
                                .padding(.horizontal, geo.size.width * 0.1)
                                .padding(.top, 12)
                            
                        }
                        .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous)))
                        
                        .padding(.top, -10)
                        .padding(.horizontal)
                        
                        VStack {
                            HStack {
                                Image(systemName: "square.text.square.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                
                                Text("Comment")
                                    .font(.body.weight(.semibold))
                                    .foregroundColor(colourScheme == .light ? .black : .white)
                                
                                Spacer()
                                
                            }
                            .padding(.leading, 12)
                            .padding(.trailing)
                            .padding(.top, 12)
                            
                            Divider()
                                .padding(.leading)
                            
                            ZStack {
                                TextEditor(text: $userComment)
                                    .focused($commentFocus)
                                    .padding(.horizontal)
                                    .padding(.bottom, 12)
                                    .onChange(of: userComment) { newValue in
                                        solve.comment = newValue
                                    }
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            HStack {
                                                Spacer()
                                                
                                                
                                                Button("Comment") {
                                                    commentFocus = false
                                                }
                                            }
                                        }
                                    }
                                
                                if userComment == "" {
                                    Text("Comment something...")
                                        .foregroundColor(Color(uiColor: .systemGray2))
                                        .padding(.vertical, 10)
                                        .offset(y: -4)
                                        .onTapGesture {
                                            commentFocus = true
                                        }
                                }
                                
                                Text(userComment)
                                    .opacity(0)
                                    .padding([.horizontal, .bottom])
                            }
                        }
                        .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:10)))
                        .padding(.horizontal)
                        
                        if let phases = self.phases {
                            VStack {
                                HStack {
                                    Image(systemName: "square.stack.3d.up.fill")
                                        .symbolRenderingMode(.hierarchical)
                                        .font(.system(size: 26, weight: .semibold))
                                        .foregroundColor(colourScheme == .light ? .black : .white)
                                    
                                    Text("Multiphase Breakdown")
                                        .font(.body.weight(.semibold))
                                        .foregroundColor(colourScheme == .light ? .black : .white)
                                    
                                    Spacer()
                                    
                                }
                                .padding(.leading, 12)
                                .padding(.trailing)
                                .padding(.top, 12)
                                
                                Divider()
                                    .padding(.leading)
                                
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(Array(zip(phases.indices, phases)), id: \.0) { index, phase in
                                        
                                        HStack {
                                            if index == 0 {
                                                Image(systemName: "\(index+1).circle")
                                                    .font(.body.weight(.medium))
                                                
                                                Text("+"+formatSolveTime(secs: phase))
                                            } else {
                                                if index < phases.count {
                                                    let phaseDifference = phases[index] - phases[index-1]
                                                    
                                                    Image(systemName: "\(index+1).circle")
                                                        .font(.body.weight(.medium))
                                                    
                                                    Text("+"+formatSolveTime(secs: phaseDifference))
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            Text("("+formatSolveTime(secs: phase)+")")
                                                .foregroundColor(Color(uiColor: .systemGray))
                                                .font(.body)
                                        }
                                    }
                                }
                                .padding([.bottom, .horizontal], 12)
                            }
                            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:10)))
                            .padding(.trailing)
                            .padding(.leading)
                        }
                        
                        
                        Button {
                            if currentSolve == nil {
                                dismiss()
                            }

                            currentSolve = nil

                            withAnimation {
                                stopWatchManager.delete(solve: solve)
                            }
                        } label: {
                            HStack {
                                Text("Delete Solve")
                                    .font(.body.weight(.medium))
                                    .foregroundColor(Color.red)
                                    .padding([.leading, .vertical], 14)
                                
                                Spacer()
                            }
                        }
                        .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:10)))
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .offset(y: -6)
                    .navigationBarTitle("", displayMode: .inline)
                }
            }
        }
    }
}
