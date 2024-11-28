import SwiftUI
import UIKit
import Foundation

// MARK: - Share Button
final class ShareButtonUIViewController: UIViewController {
    var hostingController: UIHostingController<CTButton<Label<Text, Image>>>!
    
    required init?(coder: NSCoder) {
        fatalError("error")
    }
    
    init(toShare: String, buttonText: String) {
        super.init(nibName: nil, bundle: nil)
        self.hostingController = UIHostingController(rootView: CTButton(type: .coloured(nil), size: .large, expandWidth: true, onTapRun: { [weak self] in
            guard let self = self else { return }
            let activityViewController = UIActivityViewController(activityItems: [toShare], applicationActivities: nil)
            activityViewController.isModalInPresentation = !UIDevice.deviceIsPad
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        }) {
            Label(buttonText, systemImage: "square.and.arrow.up")
        })
    }
    
    override func viewDidLoad() {
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(hostingController)
        
        self.view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        NSLayoutConstraint.activate([
            hostingController.view.widthAnchor.constraint(equalTo: view.widthAnchor),
            hostingController.view.heightAnchor.constraint(equalTo: view.heightAnchor),
            hostingController.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            hostingController.view.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

struct CTShareButton: UIViewControllerRepresentable {
    let toShare: String
    let buttonText: String
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let shareButtonUIViewController = ShareButtonUIViewController(toShare: toShare, buttonText: buttonText)
        shareButtonUIViewController.view?.backgroundColor = .clear
        shareButtonUIViewController.hostingController.view?.backgroundColor = .clear
        
        return shareButtonUIViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}


// MARK: - Copy Button
struct CTCopyButton: View {
    let toCopy: String
    let buttonText: LocalizedStringKey
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    @State private var offsetValue: CGFloat = -25
    
    var body: some View {
        CTButton(type: .coloured(nil), size: .large, expandWidth: true, onTapRun: {
            UIPasteboard.general.string = toCopy
            
            withAnimation(Animation.customSlowSpring.delay(0.25)) {
                self.offsetValue = 0
            }
            
            withAnimation(Animation.customFastEaseOut.delay(2.25)) {
                self.offsetValue = -25
            }
        }) {
            HStack(spacing: 8) {
                ZStack {
                    if self.offsetValue != 0 {
                        Image(systemName: "doc.on.doc")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(Color("accent"))
                           
                    }
                    
                    
                    Image(systemName: "checkmark")
                        .font(.subheadline.weight(.semibold))
                        .clipShape(Rectangle().offset(x: self.offsetValue))
                }
                .frame(width: 20)
                
                if (dynamicTypeSize <= .xLarge) {
                    Text(buttonText)
                }
            }
        }
        .frame(height: 35)
    }
}


// MARK: - Hierarchical Button
enum CTButtonType {
    case mono
    case coloured(Color?)
    case halfcoloured(Color?)
    case lightMono
    case disabled
}

enum CTButtonSize {
    case bubble, small, medium, large, ultraLarge
}

struct CTButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.00)
            .opacity(configuration.isPressed ? 0.80 : 1.00)
            .animation(Animation.customFastSpring, value: configuration.isPressed)
    }
}

struct CTButton<Base: View>: View {
    let button: Button<CTBubble<Base>>
    
    init(type: CTButtonType,
         size: CTButtonSize,
         outlined: Bool=false,
         square: Bool=false,
         hasShadow: Bool=true,
         hasBackground: Bool=true,
         hasMaterial: Bool=true,
         supportsDynamicResizing: Bool=true,
         expandWidth: Bool=false,
         onTapRun: @escaping () -> Void,
         @ViewBuilder _ content: @escaping () -> Base) {
        
        self.button = Button {
            DispatchQueue.main.async {
                onTapRun()
            }
        } label: {
            CTBubble(type: type,
                     size: size,
                     outlined: outlined,
                     square: square,
                     hasShadow: hasShadow,
                     hasBackground: hasBackground,
                     hasMaterial: hasMaterial,
                     supportsDynamicResizing: supportsDynamicResizing,
                     expandWidth: expandWidth,
                     content: content)
        }
    }
    
    var body: some View { self.button.buttonStyle(CTButtonStyle()) }
}


#warning("todo: set image scale here instead of per button -> inconsistent!")
struct CTBubble<V: View>: View {
    let content: V
    
    let size: CTButtonSize
    
    let colourBg: Color
    let colourFg: Color
    let colourShadow: Color
    
    @ScaledMetric var dynamicHeight: CGFloat = 0
    var staticHeight: CGFloat = 0
    
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.colorScheme) private var colourScheme
    
    let horizontalPadding: CGFloat
    let fontType: Font
    
    let square: Bool
    
    let hasShadow: Bool
    let hasBackground: Bool
    let hasMaterial: Bool

    let supportsDynamicResizing: Bool
    
    let expandWidth: Bool
    
    var cornerRadius: CGFloat = 6
    
    @State private var hovering: Bool = false
    
    init(type: CTButtonType,
         size: CTButtonSize,
         outlined: Bool=false,
         square: Bool=false,
         hasShadow: Bool=true,
         hasBackground: Bool=true,
         hasMaterial: Bool=true,
         supportsDynamicResizing: Bool=true,
         expandWidth: Bool=false,
         content: @escaping () -> V) {

        switch (type) {
        case .mono:
            self.colourBg = Color("overlay0")
            self.colourFg = Color("dark")
            self.colourShadow = Color.black.opacity(0.07)
            
        case .halfcoloured(let colour):
            self.colourBg = Color("overlay0")
            self.colourFg = colour ?? Color("accent")
            self.colourShadow = Color.black.opacity(0.07)
            
        case .coloured(let colour):
            self.colourBg = colour?.opacity(0.25) ?? Color("accent").opacity(0.22)
            self.colourFg = colour ?? Color("accent")
            self.colourShadow = colour?.opacity(0.16) ?? Color("accent").opacity(0.08)
            
        case .disabled:
            self.colourBg = Color("grey").opacity(0.15)
            self.colourFg = Color("grey")
            self.colourShadow = Color.clear
            
        case .lightMono:
            self.colourBg = Color("indent0").opacity(0.28)
            self.colourFg = Color("dark")
            self.colourShadow = Color.clear
        }

        
        self.supportsDynamicResizing = supportsDynamicResizing
        
        self.size = size
        
        switch (size) {
        case .bubble:
            if (supportsDynamicResizing) {
                self._dynamicHeight = ScaledMetric(wrappedValue: 20, relativeTo: .caption2)
            } else {
                self.staticHeight = 20
            }
            
            self.cornerRadius = 4
            
            self.horizontalPadding = 3
            self.fontType = Font.caption2.weight(.medium)

        case .small:
            if (supportsDynamicResizing) {
                self._dynamicHeight = ScaledMetric(wrappedValue: 28, relativeTo: .callout)
            } else {
                self.staticHeight = 28
            }
            
            self.horizontalPadding = 8
            self.fontType = Font.callout.weight(.medium)
            
            
        case .medium:
            if (supportsDynamicResizing) {
                self._dynamicHeight = ScaledMetric(wrappedValue: 32, relativeTo: .body)
            } else {
                self.staticHeight = 32
            }
            
            self.horizontalPadding = 10
            self.fontType = Font.body.weight(.medium)
            
            
        case .large:
            if (supportsDynamicResizing) {
                self._dynamicHeight = ScaledMetric(wrappedValue: 35, relativeTo: .body)
            } else {
                self.staticHeight = 35
            }
            
            self.horizontalPadding = 12
            self.fontType = Font.body.weight(.medium)
        
        case .ultraLarge:
            if (supportsDynamicResizing) {
                self._dynamicHeight = ScaledMetric(wrappedValue: 48, relativeTo: .title3)
            } else {
                self.staticHeight = 48
            }
            
            self.horizontalPadding = 16
            self.fontType = Font.title3.weight(.semibold)
            
        }
        
        self.square = square
        
        self.hasShadow = hasShadow
        self.hasBackground = hasBackground
        self.hasMaterial = hasMaterial
        self.expandWidth = expandWidth
        
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            let frameHeight: CGFloat = (self.supportsDynamicResizing ? self.dynamicHeight : self.staticHeight)
            
            if (self.hasBackground && colourScheme == .light && self.hasMaterial) {
                RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
                    .fill(Material.regularMaterial)
                    .frame(width: square ? frameHeight : nil, height: frameHeight)
            }
            
            RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous)
                .fill(self.hasBackground ? self.colourBg.opacity(0.92) : Color.white.opacity(0.001))
                .frame(width: square ? frameHeight : nil, height: frameHeight)
                .if(colourScheme == .light) { view in
                    view
                        .shadow(color: self.hasShadow
                                ? self.colourShadow
                                : Color.clear,
                                radius: self.hasShadow ? 4 : 0,
                                x: 0,
                                y: self.hasShadow ? 1 : 0)
                }
            
            Group {
                if (dynamicTypeSize > .xLarge) {
                    content
                        .labelStyle(.iconOnly)
                } else {
                    content
                        .labelStyle(.titleAndIcon)
                        .modifier(DynamicText())
                }
            }
            .foregroundColor(self.colourFg)
            .font(self.fontType)
            .padding(.horizontal, square ? 0 : self.horizontalPadding)
            .if(self.size == .bubble) { view in
                view.padding(.trailing, 1)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: self.cornerRadius, style: .continuous))
        .fixedSize(horizontal: !expandWidth, vertical: true)
    }
}


// MARK: - Close Button
struct CTCloseButton: View {
    let hasBackgroundShadow: Bool
    let supportsDynamicResizing: Bool
    let onTapRun: () -> Void
    
    init(hasBackgroundShadow: Bool=false, supportsDynamicResizing: Bool=true, onTapRun: @escaping () -> Void) {
        self.hasBackgroundShadow = hasBackgroundShadow
        self.supportsDynamicResizing = supportsDynamicResizing
        self.onTapRun = onTapRun
    }
    
    var body: some View {
        CTButton(type: .mono, size: .medium, square: true, hasShadow: hasBackgroundShadow, hasBackground: hasBackgroundShadow, supportsDynamicResizing: supportsDynamicResizing, onTapRun: self.onTapRun) {
            if (supportsDynamicResizing) {
                Image(systemName: "xmark")
                    .imageScale(.medium)
            } else {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
            }
            
                
        }
    }
}


// MARK: - Done Button
struct CTDoneButton: View {
    let onTapRun: () -> ()
    
    init(onTapRun: @escaping () -> ()) {
        self.onTapRun = onTapRun
    }
    
    var body: some View {
        Button {
            self.onTapRun()
        } label: {
            Text("Done")
                .font(.body.weight(.medium))
        }
        .tint(Color("accent"))
    }
}



// MARK: - Overriden UI Elements
// delayed context menu animation
struct ContextMenuButton: View {
    var delay: Bool
    var action: () -> Void
    var title: String
    var systemImage: String? = nil
    var disableButton: Bool? = nil
    
    init(delay: Bool, action: @escaping () -> Void, title: String, systemImage: String?, disableButton: Bool?) {
        self.delay = delay
        self.action = action
        self.title = title
        self.systemImage = systemImage
        self.disableButton = disableButton
    }
    
    var body: some View {
        Button(role: systemImage == "trash" ? .destructive : nil, action: delayedAction) {
            HStack {
                Text(title)
                if image != nil {
                    Image(uiImage: image!)
                }
            }
        }
        .disabled(disableButton ?? false)
    }
    
    private var image: UIImage? {
        if let systemName = systemImage {
            let config = UIImage.SymbolConfiguration(font: .preferredFont(forTextStyle: .body), scale: .medium)
            
            return UIImage(systemName: systemName, withConfiguration: config)
        } else {
            return nil
        }
    }
    private func delayedAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + (delay ? 0.8 : 0)) {
            self.action()
        }
    }
}

struct SessionPickerMenu<Content: View>: View {
    let content: Content
    let sessions: [Session]?
    let clickSession: (Session) -> ()
    
    @inlinable init(sessions: [Session]?,
                    clickSession: @escaping (Session) -> (),
                    @ViewBuilder label: () -> Content = { Label("Move To", systemImage: "arrow.up.right") }) {
        self.sessions = sessions
        self.clickSession = clickSession
        self.content = label()
    }

    var body: some View {
        Menu {
            Text("Only compatible sessions are shown")
            if let sessions = sessions {
                let unpinnedidx = sessions.firstIndex(where: {!$0.pinned}) ?? sessions.count
                let pinned = sessions[0..<unpinnedidx]
                let unpinned = sessions[unpinnedidx..<sessions.count]
                
                Divider()
                
                Section("Pinned Sessions") {
                    ForEach(pinned) { session in
                        Button {
                            clickSession(session)
                        } label: {
                            Label(session.name!, systemImage: SessionType(rawValue:session.sessionType)!.iconName())
                        }
                    }
                }
                
                Section("Other Sessions") {
                    ForEach(unpinned) { session in
                        Button {
                            clickSession(session)
                        } label: {
                            Label(session.name!, systemImage: SessionType(rawValue:session.sessionType)!.iconName())
                        }
                    }
                }
            } else {
                Text("Loading...")
            }
        } label: {
            content
        }
    }
}
