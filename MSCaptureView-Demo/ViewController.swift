//
//  ViewController.swift
//  MSCaptureView-Demo
//
//  Created by Steve Sheets on 8/15/20.
//  Copyright © 2020 Steve Sheets. All rights reserved.
//

import Cocoa
import MSCaptureView

class ViewController: NSViewController {

    @IBOutlet weak var captureView: MSCaptureView!
    
    @IBOutlet weak var previewButton: NSButton!
    @IBOutlet weak var fileButton: NSButton!
    @IBOutlet weak var startButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!
    
    @IBAction func previewAction(_ sender: Any) {
        if captureView.hasPreview {
            captureView.hidePreview()
        } else {
            captureView.showPreview()
        }
        
        updateUI()
    }
    
    @IBAction func fileAction(_ sender: Any) {
        guard let window = self.view.window else { return }
        
        let aPanel = NSSavePanel()
        
        aPanel.canCreateDirectories = true
        aPanel.showsTagField = false
        aPanel.nameFieldStringValue = "captureView.mov"
        if let dir = FileManager.default.urls(for: .moviesDirectory, in: .userDomainMask).first {
            aPanel.directoryURL = dir
        }
        
        aPanel.beginSheetModal(for: window, completionHandler: { [weak self] num in
            guard let strongSelf = self, num == .OK, let url = aPanel.url  else { return }

            do {
                try FileManager.default.removeItem(at: url)
            }
            catch {
            }
            
            strongSelf.captureView.use(url: url)
            
            strongSelf.updateUI()
        })
    }
    
    @IBAction func startAction(_ sender: Any) {
        guard captureView.hasPreview, captureView.hasURL, !captureView.isCapturing else { return }
        
        captureView.startCapture()
        
        updateUI()
    }
    
    @IBAction func stopAction(_ sender: Any) {
        guard captureView.hasPreview, captureView.hasURL, captureView.isCapturing else { return }
        
        captureView.stopCapture()
        
        updateUI()
    }
    
    // MARK: Functions
    
    public func updateUI() {
        if !captureView.hasCaptureAuthorization {
            previewButton.isEnabled = false;
            previewButton.title = "Show Preview"
            fileButton.isEnabled = false;
            fileButton.title = "Select File"
            startButton.isEnabled = false;
            stopButton.isEnabled = false;

            return
        }
        
        if captureView.hasPreview && captureView.hasURL && captureView.isCapturing {
            previewButton.isEnabled = false;
            previewButton.title = "Hide Preview"
            
            fileButton.isEnabled = false;
            fileButton.title = "File Ready"

            startButton.isEnabled = false;
            
            stopButton.isEnabled = true;
        }
        else if captureView.hasPreview && captureView.hasURL && !captureView.isCapturing {
            previewButton.isEnabled = true;
            previewButton.title = "Hide Preview"
            
            fileButton.isEnabled = true;
            fileButton.title = "File Ready"

            startButton.isEnabled = true;
            
            stopButton.isEnabled = false;
        }
        else if captureView.hasURL {
            previewButton.isEnabled = true;
            previewButton.title = "Show Preview"
            
            fileButton.isEnabled = true;
            fileButton.title = "File Ready"

            startButton.isEnabled = false;
            
            stopButton.isEnabled = false;
        }
        else if captureView.hasPreview {
            previewButton.isEnabled = true;
            previewButton.title = "Hide Preview"
            
            fileButton.isEnabled = true;
            fileButton.title = "Select File"

            startButton.isEnabled = false;
            
            stopButton.isEnabled = false;
        }
        else {
            previewButton.isEnabled = true;
            previewButton.title = "Show Preview"
            
            fileButton.isEnabled = true;
            fileButton.title = "Select File"

            startButton.isEnabled = false;
            
            stopButton.isEnabled = false;
        }
    }
    
    // MARK: Lifecycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewButton.isEnabled = false;
        fileButton.isEnabled = false;
        startButton.isEnabled = false;
        stopButton.isEnabled = false;

        MSCaptureView.requestCaptureAuthorization() { [weak self] in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.previewButton.isEnabled = true;
                strongSelf.fileButton.isEnabled = true;
            }
        }
        captureView.captureRecordingStartedEvent = { [weak self] _ in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.updateUI()
            }
        }
        captureView.captureRecordingStoppedEvent = { [weak self] _ in
            guard let strongSelf = self else { return }
            
            strongSelf.captureView.clearURL()
            
            DispatchQueue.main.async {
                strongSelf.updateUI()
            }
        }
    }

}

