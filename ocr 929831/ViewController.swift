//
//  ViewController.swift
//  ocr 929831
//
//  Created by Nathaniel Ogunye on 12/12/2022.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func didTapStartButton(_ sender: Any) {
        requestAuthorizationForCapture()
    }
}


extension ViewController {
    
    private func requestAuthorizationForCapture() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            navigateToPreview()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                self?.navigateToPreview()
            }
        case .restricted:
            return
        case .denied:
            return
        @unknown default:
            return
        }
    }
    
    private func navigateToPreview() {
        DispatchQueue.main.async { [weak self] in
            guard let vc = self?.storyboard?.instantiateViewController(withIdentifier: "CameraPreviewStoryboard") as? CameraPreviewViewController else { return }
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
