import UIKit
import AVFoundation

class RootViewController: UIViewController {
    
    var microphoneToggleButton: UIButton!
    var permissionButton: UIButton!
    var audiosession:AVAudioSession!
    var audioengine:AVAudioEngine!
    var isWorking = false
    var isGranted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
		microphoneToggleButton = UIButton(frame: CGRect(x: 150, y: 150, width: 100, height: 60))
		microphoneToggleButton.backgroundColor = UIColor.systemGreen
        microphoneToggleButton.setTitle("Start", for: .normal)
		microphoneToggleButton.addTarget(self, action: #selector(start), for: .touchUpInside)
		

		view.backgroundColor = .white
		view.addSubview(microphoneToggleButton)
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
                    alert("iPhone disconnected.")
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
				isGranted = false
                audiosession.requestRecordPermission(){
                    (given) in
                    if given{
                        self.isGranted = true
                        self.alert("Ready to roll")
                    }
                    else{
                        self.isGranted = false
                        self.alert("Recording permission not granted !")
                    }
                }
                break
            default:
                break
            }
        }
        
        catch {
            alert("Fatal ! Try again.")
        }
    }
    
    // Button action
    @objc func start(){
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
            microphoneToggleButton.setTitle("Stop", for: .normal)
        }
        else{
            microphoneToggleButton.backgroundColor = UIColor.systemGreen
            microphoneToggleButton.setTitle("Start", for: .normal)
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
                    alert("Failed to start service")
                }
            }
            else{
                isWorking = false
                alert("Enable your iPhone from the Audio MIDI Setup app.")
            }
        }
        else{
            isWorking = false
            alert("Record permission not granted !")
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
        let ok = UIAlertAction(title: "OK", style: .cancel)
        alertcontroller.addAction(ok)
        present(alertcontroller, animated: true)
    }
    
}