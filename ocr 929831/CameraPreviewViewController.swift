//
//  CameraPreviewViewController.swift
//  ocr 929831
//
//  Created by Nathaniel Ogunye on 19/12/2022.
//

import UIKit
import AVFoundation
import Vision

class CameraPreviewViewController: UIViewController {
    
    private let session: AVCaptureSession = AVCaptureSession()
    
    private let videoOutput:AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
        
    private let previewView: PreviewView = {
        
        let preview = PreviewView()
        
        preview.previewLayer.videoGravity = .resizeAspectFill
        
        preview.translatesAutoresizingMaskIntoConstraints = false
        
        return preview
    }()
    
    
    private let captureButton: UIButton = {
        let button = UIButton()
        
        button.backgroundColor = .systemBlue
        button.setTitle("Capture", for: .normal)
        button.layer.cornerRadius = 8
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        previewView.session = session
        
        view.addSubview(previewView)
        view.addSubview(captureButton)
        
        configureConstraints()
        
        addCameraDeviceToCaptureSession()
        addInterruptObservers()
        setupVideoDataCapture()
    }
    
    
    private func configureConstraints() {
        let previewViewConstraints = [
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        let captureButtonConstraints = [
            captureButton.heightAnchor.constraint(equalToConstant: 52),
            captureButton.widthAnchor.constraint(equalToConstant: 172),
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ]
        
        
        NSLayoutConstraint.activate(previewViewConstraints)
        NSLayoutConstraint.activate(captureButtonConstraints)
    }
}

// MARK: - Utils Extension

extension CameraPreviewViewController {
    
    private func addCameraDeviceToCaptureSession() {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {return}
                
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
                
                
                
                DispatchQueue.global(qos: .background).async { [weak self] in
                    self?.session.startRunning()
                }
            }
        } catch {
            print(error.self)
        }
    }
    
    private func addInterruptObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: session)
    }
    
    @objc private func sessionWasInterrupted(notification: NSNotification) {
        print("Interrupted")
    }
    
    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        print("Interruption Ended")
    }
    
    private func setupVideoDataCapture() {
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "Sample Buffer Delegate", qos: .background, attributes: []))
        
        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
    }
    
    private func recognizeTextHandle(request: VNRequest, error: Error?) {
        guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }
            let recognizedStrings = observations.compactMap { observation in
                // Return the string of the top VNRecognizedText instance.
                return observation.topCandidates(1).first?.string
            }

        print(recognizedStrings)
    }
}


extension CameraPreviewViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let requestHandler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer)
        
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandle)
        
        request.recognitionLevel = .accurate
        
        
        do {
            try requestHandler.perform([request])
        } catch {
            print(error.self)
        }
    }
    
}
