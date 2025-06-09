//
//  SoundViewModel.swift
//  BabyBrunch
//
//  Created by test2 on 2025-06-02.
//

import Foundation
import AVFoundation
import SwiftUI

public class SoundViewModel: ObservableObject {
    @Published var player: AVAudioPlayer? = nil
    
    func playSound(resourceName: String, resourceFormat: String) {
        if let soundURL = Bundle.main.url(forResource: resourceName, withExtension: resourceFormat) {
            do {
                player = try AVAudioPlayer(contentsOf: soundURL)
                player?.currentTime = 0.0
                player?.prepareToPlay()
                player?.play()
            } catch {
                print("Couldn't play the sound")
            }
        } else {
            print("Can't find the sound")
        }
    }
    
}
