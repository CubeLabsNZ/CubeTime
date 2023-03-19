import SwiftUI
import SwiftfulLoadingIndicators
import CoreData

enum StatsBlockColour {
    case clear, coloured, `default`
}

struct StatsBlock<Content: View>: View {
    @Preference(\.isStaticGradient) private var isStaticGradient
    @EnvironmentObject var gradientManager: GradientManager
    
    let dataView: Content
    let title: String
    let blockHeight: CGFloat?
    
    let isBigBlock: Bool
    let background: (AnyView, StatsBlockColour)
    let isTappable: Bool
    
    
    init(title: String,
         blockHeight: CGFloat?,
         isBigBlock: Bool=false,
         background: StatsBlockColour = .default,
         isTappable: Bool=true,
         @ViewBuilder _ dataView: () -> Content) {
        self.title = title
        self.blockHeight = blockHeight
        
        self.isBigBlock = isBigBlock
        
        switch (background) {
        case .default:
            self.background = (AnyView(isTappable
                                      ? Color("overlay0")
                                       : Color("overlay1")), .default)
        
        case .coloured:
            self.background = (AnyView(Color.red), .coloured)
             
        case .clear:
            self.background = (AnyView(Color.white.opacity(0.0001)), .clear)
        }
        
        self.isTappable = isTappable
        
        self.dataView = dataView()
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundColor(
                    background.1 != .default
                    ? Color.white
                    : Color("grey")
                )
                .frame(maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, 8)
            
            dataView
        }
        .frame(height: blockHeight)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(.horizontal, 12)
        .background(
            (self.background.1 == .coloured
            ? AnyView(getGradient(gradientSelected: gradientManager.appGradient, isStaticGradient: isStaticGradient))
            : self.background.0)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        )
        .padding(.horizontal, isBigBlock ? nil : 0)
    }
}



struct StatsBlockText: View {
    @Environment(\.globalGeometrySize) var globalGeometrySize
    @EnvironmentObject var gradientManager: GradientManager
    @Preference(\.isStaticGradient) private var isStaticGradient

    
    let displayText: String
    let colouredText: Bool
    let colouredBlock: Bool
    let displayDetail: Bool
    let nilCondition: Bool
    
    @ScaledMetric private var blockHeight: CGFloat
    
    
    init(displayText: String,
         colouredText: Bool=false,
         colouredBlock: Bool=false,
         displayDetail: Bool=false,
         nilCondition: Bool,
         blockHeight: CGFloat=75) {
        self.displayText = displayText
        self.colouredText = colouredText
        self.colouredBlock = colouredBlock
        self.displayDetail = displayDetail
        self.nilCondition = nilCondition
        self._blockHeight = ScaledMetric(wrappedValue: blockHeight)
    }
    
    var body: some View {
        ZStack {
            if nilCondition {
                Group {
                    if (colouredText) {
                        Text(displayText)
                            .foregroundStyle(getGradient(gradientSelected: gradientManager.appGradient, isStaticGradient: isStaticGradient))
                    } else {
                        Text(displayText)
                            .foregroundColor(
                                colouredBlock
                                ? .white
                                : Color("dark")
                            )
                    }
                }
                .font(.largeTitle.weight(.bold))
                .modifier(DynamicText())
            } else {
                Text("-")
                    .font(.title.weight(.medium))
                    .foregroundColor(colouredBlock
                                     ? Color(hex: 0xF6F7FC) // hardcoded
                                     : Color("grey"))
            }
            
            Spacer()
        }
        .padding(.bottom, 6)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
    }
}

struct StatsBlockDetailText: View {
    let calculatedAverage: CalculatedAverage
    let colouredBlock: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                
                ForEach(calculatedAverage.accountedSolves!, id: \.self) { solve in
                    let discarded = calculatedAverage.trimmedSolves!.contains(solve)
                    let time = formatSolveTime(secs: solve.time, penType: Penalty(rawValue: solve.penalty)!)
                    
                    Text(discarded ? "("+time+")" : time)
                        .font(.body)
                        .foregroundColor(
                            discarded
                            ? colouredBlock
                              ? Color("indent1")
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
        .padding(.bottom, 12)
    }
}

struct StatsBlockSmallText: View {
    @ScaledMetric private var spacing: CGFloat = -4
    
    let titles: [String]
    let data: [StatResult]
    @Binding var presentedAvg: CalculatedAverage?
    let blockHeight: CGFloat
    
    init(titles: [String],
         data: [StatResult],
         presentedAvg: Binding<CalculatedAverage?>,
         blockHeight: CGFloat) {
        self.titles = titles
        self.data = data
        self._presentedAvg = presentedAvg
        self.blockHeight = blockHeight
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(Array(zip(data.indices, zip(data, titles))), id: \.0) { (index, arg1) in
                let (stat, title) = arg1
                VStack(alignment: .leading, spacing: spacing) {
                    Text(title)
                        .font(.footnote.weight(.medium))
                        .foregroundColor(Color("grey"))
                    
                    
                    switch stat {
                    case .loading:
                        LoadingIndicator(animation: .circleRunner, color: Color("accent"), size: .small, speed: .fast)
                    case .notEnoughDetail:
                        Text("-")
                            .font(.title3.weight(.medium))
                            .foregroundColor(Color("grey"))
                    case .error(let error):
                        Text(error.localizedDescription)
                            .font(.title2)
                            .foregroundColor(Color("dark"))
                            .modifier(DynamicText())
                    case .value(let statValue):
                        Text(statValue.formatted)
                            .font(.title2.weight(.bold))
                            .foregroundColor(Color("dark"))
                            .modifier(DynamicText())
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    //                    presentedAvg = stat
                }
                
                if (index < titles.count-1) {
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(height: blockHeight-28-20)
        .padding(.top, 28)
        .padding(.bottom, 20)
    }
}
