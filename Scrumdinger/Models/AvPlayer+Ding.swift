//
//  AvPlayer+Ding.swift
//  Scrumdinger
//
//  Created by 宋璞 on 2022/7/1.
//

import AVFoundation
import Foundation

extension AVPlayer {
    static let sharedDingPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "ding", withExtension: "wav") else {
            fatalError("Failed to find sound file.")
        }
        return AVPlayer(url: url)
    }()
}
