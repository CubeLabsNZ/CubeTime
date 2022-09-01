import SwiftUI


struct FloatingPanelChild: View {
    @SceneStorage("CubeTime.FloatingPanel.height") private var height: Double = 50
    @Binding var stage: Int
    @State var oldStage: Int
    @State var isPressed: Bool = false
    private let minHeight: CGFloat = 0
    
    private var maxHeight: CGFloat
    var stages: [CGFloat]
    let items: [AnyView]
    
    // TODO use that one func for each tupleview type when making a real package
    
    init<A: View, B: View, C: View, D: View, E: View>(currentStage: Binding<Int>, maxHeight: CGFloat, stages: [CGFloat], @ViewBuilder content: @escaping () -> TupleView<(A, B, C, D, E)>) {
        self.maxHeight = maxHeight
        self.stages = stages
        self._stage = currentStage
        self._oldStage = State(initialValue: currentStage.wrappedValue)
        let c = content().value
        self.items = [AnyView(c.0), AnyView(c.1), AnyView(c.2), AnyView(c.3), AnyView(c.4)]
    }
    
    var body: some View {
                VStack(spacing: 0) {
                    ZStack {
                        Rectangle()
                            .fill(Color.white.opacity(0.6))
                            .background(.ultraThinMaterial)
                            
                            .frame(width: 360, height: height)
                        
                            .cornerRadius(10, corners: [.topLeft, .topRight])
                        
                       
                        items[stage]
//                        if height == stages[0] {
//                            items[0]
//                        } else if height == stages[1] {
//                            items[1]
//                        } else if height == stages[2] {
//                            items[2]
//                        } else if height == stages[3] {
//                            items[3]
//                        } else if height == stages[4] {
//                            items[4]
//                        } else {
//                            EmptyView()
//                        }
                        
                        
                    }
                        
                    Divider()
                        .frame(width: height == 0 ? 0 : 360)
                    
                    
                    // Dragger
                    ZStack {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 360, height: 18)
                            .cornerRadius(10, corners: height == 0 ? .allCorners : [.bottomLeft, .bottomRight])
//                            .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                        
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        self.isPressed = true
                                        // Just follow touch within bounds
                                        let newh = height + value.translation.height
                                        if newh > maxHeight {
                                            height = maxHeight
                                        } else if newh < minHeight {
                                            height = minHeight
                                        } else {
                                            height = newh
                                        }
                                        let nearest = stages.nearest(to: height)!.0
                                        if (nearest != oldStage) {
                                            withAnimation {
                                                stage = nearest
                                            }
                                            oldStage = nearest
                                        }
                                    }
                                
                                    .onEnded() { value in
                                        withAnimation(.spring()) {
                                            self.isPressed = false
                                            let n = stages.nearest(to: height + value.predictedEndTranslation.height)!
                                            stage = n.0
                                            height = Double(n.1)
                                        }
                                    }
                            )
                        
                        
                        Capsule()
                            .fill(Color(uiColor: isPressed ? .systemGray4 : .systemGray5))
                            .scaleEffect(isPressed ? 1.12 : 1.00)
                            .frame(width: 36, height: 6)
                    }
                }
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 0)
                .padding(.horizontal)
                .frame(width: 360)
    }
}

private extension Collection {
    subscript (safe index: Index?) -> Element? {
        guard let index = index else { return nil }
        return indices.contains(index) ? self[index] : nil
    }
}

private extension Array where Element: (Comparable & SignedNumeric) {
    func nearest(to value: Element) -> (offset: Int, element: Element)? {
        self.enumerated().min(by: {
            abs($0.element - value) < abs($1.element - value)
        })
    }
}

