//
//  ViewController.swift
//  Microphone
//
//  Created by Abdullah Rafsan on 7/20/23.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var microphoneToggleButton: UIButton!
    var audiosession:AVAudioSession!
    var audioengine:AVAudioEngine!
    var isWorking = false
    var isGranted = false
    var volume:Float = 3.87
    
    override func viewDidLoad() {
        super.viewDidLoad()
        preparetool()
    }
    
    // Prepare the application
    func preparetool(){
        do{
            audiosession = AVAudioSession.sharedInstance()
            audioengine = AVAudioEngine()
            audioengine.inputNode.volume = volume
            audioengine.mainMixerNode.outputVolume = volume
            try audiosession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audiosession.setActive(true)
            switch audiosession.recordPermission {
            case AVAudioSession.RecordPermission.granted:
                isGranted = true
                break
            case AVAudioSession.RecordPermission.denied:
                isGranted = false
                alert("রেকর্ড করবার অনুমতি পাওয়া যায়নি !")
                break
            case AVAudioSession.RecordPermission.undetermined:
                audiosession.requestRecordPermission(){
                    (given) in
                    if given{
                        self.isGranted = true
                        self.alert("কাজের জন্য প্রস্তুত !")
                    }
                    else{
                        self.isGranted = false
                        self.alert("রেকর্ড করবার অনুমতি পাওয়া যায়নি !")
                    }
                }
                break
            default:
                break
            }
        }
        
        catch {
            isWorking = false
            changeButtonAppearance()
            alert("দুঃখিত, কিছু একটা সমস্যা হয়েছে । দয়া করে আবার চেষ্টা করুন ।")
        }
    }
    
    
    @IBAction func start(){
        if isWorking {
            haltWork()
        }
        else {
            performWork()
        }
        
    }
    
    func changeButtonAppearance(){
        if isWorking {
            microphoneToggleButton.backgroundColor = UIColor.systemRed
            microphoneToggleButton.setTitle("থামুন", for: .normal)
        }
        else{
            microphoneToggleButton.backgroundColor = UIColor(named: "AccentColor")
            microphoneToggleButton.setTitle("শুরু করুন", for: .normal)
        }
    }
    
    func performWork(){
        if isGranted {
            isWorking = true
            changeButtonAppearance()
            do{
                audioengine.connect(self.audioengine.inputNode, to: self.audioengine.mainMixerNode, format: self.audioengine.inputNode.outputFormat(forBus: 0))
                try audioengine.start()
            }
            catch{
                isWorking = false
                changeButtonAppearance()
                alert("দুঃখিত, কিছু একটা সমস্যা হয়েছে । দয়া করে আবার চেষ্টা করুন ।")
            }
        }
        else{
            isWorking = false
            changeButtonAppearance()
            alert("রেকর্ড করবার অনুমতি পাওয়া যায়নি !")
        }
        
    }
    
    func haltWork(){
        audioengine.stop()
        isWorking = false
        changeButtonAppearance()
    }
    
    // Show alerts
    func alert(_ msg:String){
        let alertcontroller = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ঠিক আছে", style: .cancel)
        alertcontroller.addAction(ok)
        present(alertcontroller, animated: true)
    }
    
}

