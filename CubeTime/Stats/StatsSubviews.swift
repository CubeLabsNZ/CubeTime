import SwiftUI
import CoreData

struct StatsBlock<Content: View>: View {
    @Environment(\.colorScheme) var colourScheme
    @AppStorage(asKeys.gradientSelected.rawValue) private var gradientSelected: Int = 6
    
    let dataView: Content
    let title: String
    let blockHeight: CGFloat?
    let bigBlock: Bool
    let coloured: Bool
    
    
    init(_ title: String, _ blockHeight: CGFloat?, _ bigBlock: Bool, _ coloured: Bool, @ViewBuilder _ dataView: () -> Content) {
        self.dataView = dataView()
        self.title = title
        self.bigBlock = bigBlock
        self.coloured = coloured
        self.blockHeight = blockHeight
    }
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    HStack {
                        Text(title)
                            .font(.footnote.weight(.medium))
                            .foregroundColor(
                                title == "CURRENT STATS"
                                ? Color("dark")
                                : coloured
                                ? Color.white
                                  : Color("grey")
                            )
                        
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.top, 9)
                .padding(.leading, 12)
                
                dataView
            }
        }
        .frame(height: blockHeight)
        .if(coloured) { view in
            view.background(getGradient(gradientArray: CustomGradientColours.gradientColours, gradientSelected: gradientSelected)                                        .clipShape(RoundedRectangle(cornerRadius: 12)))
        }
        .if(!coloured) { view in
            view.background(
                (title == "CURRENT STATS"
                    ? Color("overlay0")
                    : Color("overlay1"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            )
        }
        .if(bigBlock) { view in
            view.padding(.horizontal)
        }
    }
}



struct StatsBlockText: View {
    @Environment(\.colorScheme) var colourScheme
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @AppStorage(asKeys.gradientSelected.rawValue) private var gradientSelected: Int = 6
    
    let displayText: String
    let colouredText: Bool
    let colouredBlock: Bool
    let displayDetail: Bool
    let nilCondition: Bool
    
    @ScaledMetric private var blockHeightSmall = 75
    
    
    init(_ displayText: String, _ colouredText: Bool, _ colouredBlock: Bool, _ displayDetail: Bool, _ nilCondition: Bool) {
        self.displayText = displayText
        self.colouredText = colouredText
        self.colouredBlock = colouredBlock
        self.displayDetail = displayDetail
        self.nilCondition = nilCondition
    }
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                
                HStack {
                    if nilCondition {
                        Text(displayText)
                            .font(.largeTitle.weight(.bold))
                            .frame(minWidth: 0, maxWidth: globalGeometrySize.width/2 - 42, alignment: .leading)
                            .modifier(DynamicText())
                            .padding(.bottom, 2)
                        
                            .if(!colouredText) { view in
                                view.foregroundColor(
                                    colouredBlock
                                    ? .white
                                    : Color("dark")
                                )
                            }
                            .if(colouredText) { view in
                                view.gradientForeground(gradientSelected: gradientSelected)
                            }
                        
                            
                        
                    } else {
                        VStack {
                            Text("-")
                                .font(.title.weight(.medium))
                                .foregroundColor(colouredBlock
                                                 ? Color(0xF6F7FC) // hardcoded
                                                 : Color("grey"))
                                .padding(.top, 20)
                            
                            Spacer()
                        }
                    }
                    
                    Spacer()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
            }
            .padding(.bottom, 4)
            .padding(.leading, 12)
            .frame(height: blockHeightSmall)
            
            
            if displayDetail {
                Spacer()
            }
        }
    }
}

struct StatsBlockDetailText: View {
    @Environment(\.colorScheme) var colourScheme
    let calculatedAverage: CalculatedAverage
    let colouredBlock: Bool
    
    var body: some View {
        let _ = NSLog("calculated average : \(calculatedAverage.name)")
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                ForEach(calculatedAverage.accountedSolves!, id: \.self) { solve in
                    let discarded = calculatedAverage.trimmedSolves!.contains(solve)
                    let time = formatSolveTime(secs: solve.time, penType: PenTypes(rawValue: solve.penalty)!)
                    Text(discarded ? "("+time+")" : time)
                        .font(.body)
                        .foregroundColor(
                            discarded
                            ? colouredBlock
                              ? Color("indent2")
                              : Color("grey")
                            : colouredBlock
                              ? .white
                              : Color("dark")
                        )
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 2)
                }
            }
            Spacer()
        }
        .padding(.bottom, 9)
        .padding(.leading, 12)
    }
}

struct StatsBlockSmallText: View {
    @Environment(\.colorScheme) var colourScheme
    @ScaledMetric private var bigSpacing: CGFloat = 2
    @ScaledMetric private var spacing: CGFloat = -4
        
    var titles: [String]
    var data: [CalculatedAverage?]
    @Binding var presentedAvg: CalculatedAverage?
    
    init(_ titles: [String], _ data: [CalculatedAverage?], _ presentedAvg: Binding<CalculatedAverage?>) {
        self.titles = titles
        self.data = data
        self._presentedAvg = presentedAvg
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: bigSpacing) {
            ForEach(Array(zip(titles.indices, titles)), id: \.0) { index, title in
                HStack {
                    VStack(alignment: .leading, spacing: spacing) {
                        Text(title)
                            .font(.footnote.weight(.medium))
                            .foregroundColor(Color(uiColor: .systemGray))
                        
                        if let datum = data[index] {
                            Text(formatSolveTime(secs: datum.average ?? 0, penType: datum.totalPen))
                                .font(.title2.weight(.bold))
                                .foregroundColor(Color("dark"))
                                .modifier(DynamicText())
                        } else {
                            Text("-")
                                .font(.title3.weight(.medium))
                                .foregroundColor(Color("grey"))
                        }
                    }
                    
                    Spacer()
                }
                .padding(.leading, 12)
                .contentShape(Rectangle())
                .onTapGesture {
                    if data[index] != nil {
                        presentedAvg = data[index]
                    }
                }
            }
        }
        .padding(.top, 16)
    }
}
