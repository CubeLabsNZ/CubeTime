//
//  TimesView.swift
//  txmer
//
//  Created by Tim Xie on 25/11/21.
//

import SwiftUI

func getDismiss() {
    if #available(iOS 15.0, *) {
        
    } else {
        
    }
}

@available(iOS 15.0, *)
struct TimesView: View {
    @State private var showingPopupSlideover = false
    
    /*
     let columns: [GridItem] = [
     GridItem(.fixed(Int(UIScreen.main.bounds.size.width) - 16*2 - 2*11), spacing: 11),
     GridItem(.fixed(Int(UIScreen.main.bounds.size.width) - 16*2 - 2*11), spacing: 11),
     GridItem(.fixed(Int(UIScreen.main.bounds.size.width) - 16*2 - 2*11), spacing: 11)
     ]
     */
    
    let columns = [
        // GridItem(.adaptive(minimum: 112), spacing: 11)
        GridItem(spacing: 10),
        GridItem(spacing: 10),
        GridItem(spacing: 10)
    ]
    
    let values = SetValues()
    
    
    
    var solves: FetchedResults<Solves>
    
    
    
    var body: some View {
        
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(solves, id: \.self) { item in // foreach currentsesion.solves TODO
                TimeCard(solve: item, showingPopupSlideover: showingPopupSlideover)
            }
        }
        .padding(.leading)
        .padding(.trailing)
    }
}


//struct TimesView_Previews: PreviewProvider {
//    static var previews: some View {
//        SolvePopupView()
//    }
//}

