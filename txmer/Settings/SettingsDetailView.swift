//
//  SettingsDetailView.swift
//  txmer
//
//  Created by Tim Xie on 9/12/21.
//

import SwiftUI

@available(iOS 15.0, *)
struct SettingsDetailView: View {
    var animation: Namespace.ID
    var tabRouter: TabRouter
    
    
    var body: some View {
        if tabRouter.showDetail {
            VStack {
//                Image()
                Text("hi")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .padding()
//                    .background(Color.red)
                
                Spacer()
                
            }
            .background(.ultraThinMaterial)
        }
    }
}
