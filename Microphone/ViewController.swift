//
//  ViewController.swift
//  Microphone
//
//  Created by Abdullah Rafsan on 7/20/23.
//

import UIKit
import AVFoundation


class ViewController: UIViewController {
    
    @IBOutlet weak var microphoneToggleButton: UIButton!
    var audiosession:AVAudioSession!
    var audioengine:AVAudioEngine!
    var isWorking = false
    var isGranted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        preparetool()
        start()
    }
    
    @objc func handleRouteChange(notification:Notification){
        
        guard let userInfo = notification.userInfo,
              let reasonKey = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonKey) else {
            return
        }
        switch reason {
        case .newDeviceAvailable:
            if !audiosession.currentRoute.outputs.filter({ $0.portName.lowercased().contains("idam") }).isEmpty {
                performWork()
            }
        case .oldDeviceUnavailable:
            let _ = audiosession.currentRoute.outputs.filter(){
                pd in
                if !pd.portName.lowercased().contains("idam") {
                    haltWork()
                    alert("আইফোনকে ম্যাক থেকে বিচ্ছিন্ন করা হয়েছে ।")
                }
                
                return true
            }
        default: ()
        }
    }
    
    
    // Prepare the application
    /*
     Try to prepare the AVAudioSession, ask for recording permission
     and set appropriate recording state
     */
    func preparetool(){
        do{
            
            audiosession = AVAudioSession.sharedInstance()
            audioengine = AVAudioEngine()
            try audiosession.setCategory(.playAndRecord, mode: .videoRecording, options: [.duckOthers ,.defaultToSpeaker])
            try audiosession.setActive(true)
            NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
            switch audiosession.recordPermission {
            case AVAudioSession.RecordPermission.granted:
                isGranted = true
                break
            case AVAudioSession.RecordPermission.denied:
                isGranted = false
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
            alert("দুঃখিত, কিছু একটা সমস্যা হয়েছে । দয়া করে আবার চেষ্টা করুন ।")
        }
    }
    
    // Button action
    @IBAction func start(){
            if isWorking {
                haltWork()
            }
            else {
                performWork()
            }
    }
    
    // Change the button style depending on the state
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
    
    // Start operation
    /*
     If we are permitted then check we are connected to the IDAM output,
     otherwise do nothing or show appropriate error
     
     */
    func performWork(){
        if isGranted {
            if audiosession.currentRoute.outputs[0].portName.lowercased().contains("idam") {
                do{
                    audioengine.connect(self.audioengine.inputNode, to: self.audioengine.mainMixerNode, format: self.audioengine.inputNode.outputFormat(forBus: 0))
                    try audioengine.start()
                    isWorking = true
                }
                catch{
                    isWorking = false
                    alert("দুঃখিত, সার্ভিসটি চালু করা যায়নি ।")
                }
            }
            else{
                isWorking = false
                alert("Audio MIDI Setup অ্যাপ থেকে আপনার আইফোনটি Enable করুন")
            }
        }
        else{
            isWorking = false
            alert("রেকর্ড করবার অনুমতি পাওয়া যায়নি !")
        }
        changeButtonAppearance()
    }
    
    // Stop operation
    func haltWork(){
        audioengine.stop()
        isWorking = false
        changeButtonAppearance()
    }
    
    // Create and show alerts
    func alert(_ msg:String){
        let alertcontroller = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        let ok = UIAlertAction(title: "ঠিক আছে", style: .cancel)
        alertcontroller.addAction(ok)
        present(alertcontroller, animated: true)
    }
    
}

