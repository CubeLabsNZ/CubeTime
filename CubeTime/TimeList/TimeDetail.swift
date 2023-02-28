// PHASES

/*
 if let phases = self.phases {
     VStack {
         HStack {
             Image(systemName: "square.stack.3d.up.fill")
                 .symbolRenderingMode(.hierarchical)
                 .font(.system(size: 26, weight: .semibold))
                 .foregroundColor(colourScheme == .light ? .black : .white)
             
             Text("Multiphase Breakdown")
                 .font(.body.weight(.semibold))
                 .foregroundColor(colourScheme == .light ? .black : .white)
             
             Spacer()
             
         }
         .padding(.leading, 12)
         .padding(.trailing)
         .padding(.top, 12)
         
         Divider()
             .padding(.leading)
         
         
         VStack(alignment: .leading, spacing: 4) {
             ForEach(Array(zip(phases.indices, phases)), id: \.0) { index, phase in
                 
                 HStack {
                     if index == 0 {
                         Image(systemName: "\(index+1).circle")
                             .font(.body.weight(.medium))
                         
                         Text("+"+formatSolveTime(secs: phase))
                     } else {
                         if index < phases.count {
                             let phaseDifference = phases[index] - phases[index-1]
                             
                             Image(systemName: "\(index+1).circle")
                                 .font(.body.weight(.medium))
                             
                             Text("+"+formatSolveTime(secs: phaseDifference))
                         }
                     }
                     
                     Spacer()
                     
                     Text("("+formatSolveTime(secs: phase)+")")
                         .foregroundColor(Color(uiColor: .systemGray))
                         .font(.body)
                 }
             }
         }
         .padding([.bottom, .horizontal], 12)
     }
     .background(Color(uiColor: colourScheme == .light ? .white : .systemGray6).clipShape(RoundedRectangle(cornerRadius:10)))
     .padding(.trailing)
     .padding(.leading)
 }
 */



