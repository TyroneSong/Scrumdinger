//
//  CardView.swift
//  Scrumdinger
//
//  Created by 宋璞 on 2022/6/30.
//

import SwiftUI

struct CardView: View {
    let scrum: DailyScrum
    var body: some View {
        VStack(alignment: .leading) {
            Text(scrum.title)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            
            HStack {
                Label("\(scrum.attendees.count)", systemImage: "person.3")
                    .accessibilityLabel("\(scrum.attendees.count) attendees")
                Spacer()
                Label("\(scrum.lengthInMinutes)", systemImage: "clock")
                    .accessibilityLabel("\(scrum.lengthInMinutes) minute meeting")
                    .labelStyle(.trailingIcon)
            }
            .font(.caption)
                
        }
        .padding()
        .foregroundColor(scrum.theme.accentColor)
    }
}

struct CardView_Previews: PreviewProvider {
    static var scrum0 = DailyScrum.sampleData[0]
    static var scrum1 = DailyScrum.sampleData[1]
    static var scrum2 = DailyScrum.sampleData[2]
    static var previews: some View {
        List {
//            ForEach(DailyScrum.sampleData, id: \Self) { scrum in
                CardView(scrum: scrum0)
                    .background(scrum0.theme.mainColor)
                    .previewLayout(.fixed(width: 400, height: 60))
        CardView(scrum: scrum1)
            .background(scrum1.theme.mainColor)
            .previewLayout(.fixed(width: 400, height: 60))
        CardView(scrum: scrum2)
            .background(scrum2.theme.mainColor)
            .previewLayout(.fixed(width: 400, height: 60))
//            }
        }
    }
}
