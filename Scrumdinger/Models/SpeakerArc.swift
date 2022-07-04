//
//  SpeakerArc.swift
//  Scrumdinger
//
//  Created by 宋璞 on 2022/7/1.
//

import SwiftUI

/// 发言者 弧度
struct SpeakerArc: Shape {
    
    /// 发言者序号
    let speakerIndex: Int
    /// 总发言人数
    let totalSpeakers: Int
    
    /// 每位发言者的弧度度数
    private var degreesPerSpeaker: Double {
        360.0 / Double(totalSpeakers)
    }
    
    /// 开始角度
    private var startAngle: Angle {
        Angle(degrees: degreesPerSpeaker * Double(speakerIndex) + 1.0)
    }
    
    /// 结束角度
    private var endAngle: Angle {
        Angle(degrees: startAngle.degrees + degreesPerSpeaker - 1.0)
    }
    
    func path(in rect: CGRect) -> Path {
        let diameter = min(rect.size.width, rect.size.height) - 24.0
        let radius = diameter / 2.0
        let center = CGPoint(x: rect.midX, y: rect.midY)
        return Path { path in
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
    }
}
