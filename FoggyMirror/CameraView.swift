import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    @Binding var session: AVCaptureSession?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        
        // Check camera permission first
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthStatus {
        case .authorized:
            setupCamera(in: view)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupCamera(in: view)
                    } else {
                        self.showPermissionDeniedMessage(in: view)
                    }
                }
            }
        case .denied, .restricted:
            showPermissionDeniedMessage(in: view)
        @unknown default:
            showPermissionDeniedMessage(in: view)
        }
        
        return view
    }
    
    private func setupCamera(in view: UIView) {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("Failed to get front camera")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            
            // Mirror the front camera - disable auto adjustment first
            if let connection = previewLayer.connection {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true
            }
            
            view.layer.addSublayer(previewLayer)
            
            DispatchQueue.global(qos: .background).async {
                captureSession.startRunning()
            }
            
            DispatchQueue.main.async {
                self.session = captureSession
            }
        } catch {
            print("Failed to create camera input: \(error)")
            showErrorMessage(in: view, message: "Camera setup failed")
        }
    }
    
    private func showPermissionDeniedMessage(in view: UIView) {
        let label = UILabel()
        label.text = "Camera access denied.\nPlease enable in Settings > Privacy & Security > Camera"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        label.backgroundColor = .black.withAlphaComponent(0.7)
        label.frame = view.bounds
        view.addSubview(label)
    }
    
    private func showErrorMessage(in view: UIView, message: String) {
        let label = UILabel()
        label.text = message
        label.textAlignment = .center
        label.textColor = .white
        label.backgroundColor = .black.withAlphaComponent(0.7)
        label.frame = view.bounds
        view.addSubview(label)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Update the preview layer frame if needed
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            previewLayer.frame = uiView.bounds
        }
    }
}
