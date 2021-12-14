import SwiftUI

struct StatsDetail: View {
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.dismiss) var dismiss
   
    let solves: CalculatedAverage
    let session: Sessions
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: colourScheme == .light ? .systemGray6 : .black)
                    .ignoresSafeArea()
                
                ScrollView {
                    
                    
                    
                    VStack (spacing: 10) {
                        HStack {
                            Text(formatSolveTime(secs: solves.average))
                                .font(.system(size: 34, weight: .bold))
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top)
                        
                        HStack (alignment: .center) {
                            Text(session.name ?? "Unknown session name")
                                .font(.system(size: 20, weight: .semibold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                            Spacer()
                            
                            Text(puzzle_types[Int(session.scramble_type)].name)
                                .font(.system(size: 16, weight: .semibold, design: .default))
                                .foregroundColor(Color(uiColor: .systemGray))
                        }
                        .padding(.horizontal)
                        
                        
                        ForEach(Array(zip(solves.accountedSolves.indices, solves.accountedSolves)), id: \.0) {index, solve in
                            VStack {
                                HStack {
                                    Text("\(index).")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(Color("AccentColor"))
                                    Text(formatSolveTime(secs: solve.time, penType: PenTypes.init(rawValue: solve.penalty)!))
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                    
                                    Spacer()
                                    
                                    Text(solve.date ?? Date(timeIntervalSince1970: 0), format: .dateTime.day().month().year())
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(uiColor: .systemGray))
                                }
                                .padding([.horizontal, .top], 10)
                                
                                HStack {
                                    Text(solve.scramble ?? "Failed to load scramble")
                                        .font(.system(size: 17, weight: .medium))
                                    
                                    Spacer()
                                }
                                .padding([.horizontal, .bottom], 10)
                                
                            }
                            .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius: 12)))
                            .padding(.horizontal)
                        }
                        
                        
                        
                        Text("\nRemember to gray out the worst and best times along with addding brackets <3")
                        
                        
                    }
                    .offset(y: -6)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle(solves.id)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .medium))
                                    .padding(.leading, -4)
                                Text("Stats")
                                    .padding(.leading, -4)
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                print("button pressed")
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color("AccentColor"))
                            }
                        }
                    }
                }
            }
        }
        
        
    }
}
