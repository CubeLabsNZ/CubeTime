import SwiftUI

#warning("TODO: convert to TextFieldStyle")
struct ManualInputTextField: ViewModifier {
    @Binding var text: String
    @State var userDotted = false
    
    var onReceiveAlso: ((String) -> Void)?
    func body(content: Content) -> some View {
        content
            .keyboardType(text.count > 2 ? .numberPad : .decimalPad)
            .onChange(of: text) { newValue in
                refilter()
                
                onReceiveAlso?(text)
            }
    }
    
    func refilter() {
        var filtered: String!
        
        let dotCount = text.filter({ $0 == "."}).count
        
        // Let the user dot if the text is more than 1, less than six (0.xx.) and there are 2 dots where the last was just entered
        if text == "." || ( text.count > 1 && text.count < 6 && text.last! == "." && dotCount < 3 ) {
            userDotted = true
        } else if dotCount == 0 {
            userDotted = false
        }
        
        
        if userDotted {
            var removedfirstdot = !(dotCount == 2)
            
            filtered = String(
                text
                    .filter {
                        // Remove only first of 2 dots
                        if removedfirstdot {
                            return $0.isNumber || $0 == "."
                        } else {
                            if $0 == "." {
                                removedfirstdot = true
                                return false
                            } else {
                                return $0.isNumber
                            }
                        }
                    }
                    .replacingOccurrences(of: "^0+", with: "", options: .regularExpression) // Remove leading 0s
            )
            let dotindex = filtered.firstIndex(of: ".")!
            
            let from = filtered.index(dotindex, offsetBy: -2, limitedBy: filtered.startIndex) ?? filtered.startIndex
            let to = filtered.index(dotindex, offsetBy: 3, limitedBy: filtered.endIndex) ?? filtered.endIndex
            
            
            filtered = String(filtered[from..<to])
        } else {
            filtered = String(
                text.filter { $0.isNumber } // Remove a non numbers
                    .replacingOccurrences(of: "^0+", with: "", options: .regularExpression) // Remove leading 0s
                    .prefix(6)
            )
            if filtered.count > 2 {
                filtered.insert(".", at: filtered.index(filtered.endIndex, offsetBy: -2))
            } else if filtered.count > 0 {
                filtered = "0." + repeatElement("0", count: 2 - filtered.count) + filtered
            }
            if filtered.count > 5 {
                filtered.insert(":", at: filtered.index(filtered.endIndex, offsetBy: -5))
            }
        }
        
        text = filtered
    }
}
