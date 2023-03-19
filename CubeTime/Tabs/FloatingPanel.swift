import SwiftUI

struct FloatingPanel: View {
    @State private var height: CGFloat
    
    @Binding var stage: Int
    
    @State var oldStage: Int
    @State var isPressed: Bool = false
    
    private let minHeight: CGFloat = 0
    private var maxHeight: CGFloat
    
    var stages: [CGFloat]
    let views: [AnyView]
    
#warning("TODO: use that one func for each tupleview type when making a real package")
    
    init<A: View, B: View, C: View>(
        currentStage: Binding<Int>,
        maxHeight: CGFloat,
        stages: [CGFloat],
        @ViewBuilder content: @escaping () -> TupleView<(A, B, C)>) {
            self.maxHeight = maxHeight
            self.stages = stages
            
            self._stage = currentStage
            self._oldStage = State(initialValue: currentStage.wrappedValue)
            
            self._height = State(initialValue: stages[currentStage.wrappedValue])
            
            let c = content().value
            
            self.views = [AnyView(c.0), AnyView(c.1), AnyView(c.2)]
        }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color("overlay1"))
                    .frame(width: 360, height: height + 18)
                    .shadowDark(x: 0, y: 3)
                    .zIndex(1)
                
                ZStack {
                    Capsule()
                        .fill(isPressed ? Color("indent0") : Color("indent1"))
                        .scaleEffect(isPressed ? 1.12 : 1.00)
                        .frame(width: 36, height: 6)
                }
                .frame(width: 360, height: 18, alignment: .center)
                .background(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color("overlay1"))
                        .frame(width: 360, height: 18)
                )
                .zIndex(2)
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
                                withAnimation(.customSlowSpring) {
                                    stage = nearest
                                }
                                oldStage = nearest
                            }
                        }
                        .onEnded() { value in
                            withAnimation(.customSlowSpring) {
                                self.isPressed = false
                                let n = stages.nearest(to: height + value.predictedEndTranslation.height)!
                                stage = n.0
                                height = Double(n.1)
                            }
                        }
                )
            }
            .frame(width: 360, height: height + 18)
            
            
            // view
            ZStack(alignment: .top) {
                Rectangle()
                    .fill(Color("overlay1"))
                    .frame(width: 360, height: height)
                    .cornerRadius(6, corners: [.topLeft, .topRight])

                views[stage]
                    .frame(width: 360, height: height, alignment: .top)
                    .clipped()
                    .animation(.none, value: stage)
                    .zIndex(100)
            }
            .zIndex(3)
        }
        .frame(width: 360)
        .onChange(of: stages) { newValue in
            height = newValue[stage]
        }
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
