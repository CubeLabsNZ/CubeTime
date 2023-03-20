import SwiftUI
import UIKit

struct FloatingPanel: View {
    @State private var height: CGFloat
    @State private var beginHeight: CGFloat
    
    @Binding var stage: Int
    
    @State var oldStage: Int
    @State var isPressed: Bool = false
    
    private let minHeight: CGFloat
    private let maxHeight: CGFloat
    
    var stages: [CGFloat]
    let views: [AnyView]
    
    
    init<A: View, B: View, C: View>(
        currentStage: Binding<Int>,
        stages: [CGFloat],
        @ViewBuilder content: @escaping () -> TupleView<(A, B, C)>) {
            self.maxHeight = stages.last ?? 300
            self.minHeight = stages.first ?? 0
            
            self.stages = stages
            
            self._stage = currentStage
            self._oldStage = State(initialValue: currentStage.wrappedValue)
            
            self._height = State(initialValue: stages[currentStage.wrappedValue])
            self._beginHeight = State(initialValue: stages[currentStage.wrappedValue])
            
            let c = content().value
            
            self.views = [AnyView(c.0), AnyView(c.1), AnyView(c.2)]
        }
    
    var body: some View {
        VStack(spacing: 0) {
            views[stage]
                .frame(width: 360, height: height, alignment: .top)
                .clipped()
                .animation(.none, value: stage)
            
                            
            DraggerView(onUpdate: { (heightDelta, projectedDelta, state)  in
                if (state == .began) {
                    self.beginHeight = self.height
                    
                } else if (state == .changed) {
                    self.height = max(min(self.beginHeight + heightDelta, self.maxHeight), self.minHeight)
                    
                    let nearest = stages.nearest(to: height)!.0
                    if (nearest != oldStage) {
                        withAnimation(.customSlowSpring) {
                            stage = nearest
                        }
                        oldStage = nearest
                    }
                } else if (state == .ended) {
                    let n = stages.nearest(to: self.height + projectedDelta)!
                    
                    withAnimation(.customSlowSpring) {
                        stage = n.0
                        height = max(min(Double(n.1), self.maxHeight), self.minHeight)
                    }
                }
            })
                .frame(width: 360, height: 18)
        }
        .clipped()
        .frame(width: 360)
        .background (
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(Color("overlay1"))
                .shadowDark(x: 0, y: 3)
        )
        .onChange(of: stages) { newValue in
            height = newValue[stage]
        }
    }
}

struct DraggerView: UIViewControllerRepresentable {
    let onUpdate: (CGFloat,
                   CGFloat,
                   UIPanGestureRecognizer.State) -> Void
    
    typealias UIViewControllerType = DraggerViewController
    
    func makeUIViewController(context: Context) -> DraggerViewController {
        return DraggerViewController(changeHeight: onUpdate)
    }
    
    func updateUIViewController(_ uiViewController: DraggerViewController, context: Context) { }
}

class DraggerViewController: UIViewController {
    var draggerCapsuleView = UIView(frame: .zero)
    
    var drag: UIPanGestureRecognizer!
    
    let onUpdate: (CGFloat,
                       CGFloat,
                       UIPanGestureRecognizer.State) -> ()
    
    init(changeHeight: @escaping (CGFloat,
                                  CGFloat,
                                  UIPanGestureRecognizer.State) -> ()) {
        self.onUpdate = changeHeight
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupGestures()
    }
    
    @objc private func panPanel(_ gestureRecogniser: UIPanGestureRecognizer) {
        let d = gestureRecogniser.translation(in: self.view).y
        let state = gestureRecogniser.state
        let v = gestureRecogniser.velocity(in: self.view).y
        let a = 1<<13
        
        let dProj = (v*v) / CGFloat(a) * (d > 0 ? 1.0 : -1.0)
        
        
        if (state == .began) {
            self.draggerCapsuleView.backgroundColor = UIColor(named: "indent0")!
            UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.76, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                self.draggerCapsuleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.12, 1.12);
            })
        } else if (state == .ended) {
            self.draggerCapsuleView.backgroundColor = UIColor(named: "indent1")!
            UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.76, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                self.draggerCapsuleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
            })
        }
        
        onUpdate(d, dProj, state)
    }
    
    private func setupGestures() {
        self.drag = UIPanGestureRecognizer(target: self, action: #selector(self.panPanel))
        drag.allowedScrollTypesMask = .all
        drag.maximumNumberOfTouches = 1
        drag.minimumNumberOfTouches = 1
        
        view.addGestureRecognizer(drag)
        view.isUserInteractionEnabled = true
    }
    
    private func setupView() {
        self.view = UIView(frame: .zero)
        view.backgroundColor = UIColor(named: "overlay1")!
        view.layer.cornerRadius = 6
        view.layer.cornerCurve = .continuous
        
        self.draggerCapsuleView = UIView(frame: .zero)
        draggerCapsuleView.layer.cornerRadius = 3
        draggerCapsuleView.layer.cornerCurve = .continuous
        draggerCapsuleView.backgroundColor = UIColor(named: "indent1")
        
        self.view.addSubview(draggerCapsuleView)
        self.draggerCapsuleView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            draggerCapsuleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            draggerCapsuleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            draggerCapsuleView.widthAnchor.constraint(equalToConstant: 36),
            draggerCapsuleView.heightAnchor.constraint(equalToConstant: 6),
        ])
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


struct PrevSolvesDisplay: View {
    @EnvironmentObject var stopwatchManager: StopwatchManager
    var count: Int?
    
    @State var solve: Solve? = nil
    
    var body: some View {
        if (SessionType(rawValue: stopwatchManager.currentSession.sessionType) == .compsim) {
            if let currentSolveGroup = stopwatchManager.compsimSolveGroups.first {
                TimeBar(solvegroup: currentSolveGroup, currentCalculatedAverage: .constant(nil), isSelectMode: .constant(false), current: true)
                    .frame(height: 55)
            }
        } else {
            HStack {
                ForEach((count != nil)
                        ? stopwatchManager.solvesByDate.suffix(count!)
                        : stopwatchManager.solvesByDate, id: \.self) { solve in
                    
                    TimeCard(solve: solve, currentSolve: $solve)
                }
            }
            .sheet(item: self.$solve) { item in
                TimeDetailView(for: item, currentSolve: $solve)
            }
        }
    }
}
