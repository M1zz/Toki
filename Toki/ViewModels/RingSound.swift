//
//  RingSound.swift
//  Toki
//
//  Created by POS on 7/8/25.
//

import AudioToolbox
import AVFoundation

/// 소리 혹은 진동을 재생하는 함수
func ring() {
    let ringMode = UserDefaults.standard.string(forKey: "ringMode") ?? RingMode.sound.rawValue

    if ringMode == RingMode.vibration.rawValue {
        /// 진동
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    } else {
        /// 소리
        let soundID: SystemSoundID = 1005
        AudioServicesPlaySystemSound(soundID)
    }
}
