//
//  QRScannerViewController.swift
//  infinity
//
//  Created by Hotha Santhanakrishnan Swarup on 5/9/18.
//  Copyright © 2020 Hotha Santhanakrishnan Swarup. All rights reserved.
//

import UIKit
import AVFoundation
import SafariServices

protocol QRScannerViewControllerDelegate: class {
    func didCapture(qrcode: String)
    func didTapTurnOnCamera()
}

class QRScannerViewController: UIViewController {
    @IBOutlet var previewView: CameraPreviewView!
    @IBOutlet var overlayView: CameraOverlayView!

    @IBOutlet var allowCameraAccessView: UIView!
    @IBOutlet var turnOnCameraButton: UIButton!
    @IBOutlet var allowCameraAccessTitleLabel: UILabel!

    var session: AVCaptureSession?
    let output = AVCaptureMetadataOutput()

    weak var delegate: QRScannerViewControllerDelegate?

    // MARK: - Init
    class func instantiate() -> QRScannerViewController {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "\(QRScannerViewController.self)")
        return viewController as! QRScannerViewController
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        registerForNotifications()
        setupCaptureSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        allowCameraAccessView.isHidden = false
        checkCameraPermission(onUserAction: false)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
        stopSession()
    }

    func resumeSession() {
        if session?.isRunning == false {
            session?.startRunning()
        }
    }
}

// MARK: - Action
extension QRScannerViewController {
    @objc func avCaptureInputFormatChangeNotification() {
        let previewLayer = previewView.videoPreviewLayer
        output.rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: overlayView.focusRect)
    }
}

// MARK: - Private
extension QRScannerViewController {
    private func registerForNotifications() {
        let notification = NSNotification.Name.AVCaptureInputPortFormatDescriptionDidChange
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(avCaptureInputFormatChangeNotification),
                                               name: notification,
                                               object: nil)
    }

    private func setupView() {
        allowCameraAccessTitleLabel.text = "Allow Camera Access"
    }
}

// MARK: - Camera
extension QRScannerViewController {
    func checkCameraPermission(onUserAction: Bool) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            allowCameraAccessView.isHidden = true
            startSession()
        case .notDetermined:
            requestCameraAccessPermission()
        case .denied, .restricted:
            if onUserAction {
                showSettingsAlert()
            }
        }
    }

    func requestCameraAccessPermission() {
        AVCaptureDevice.requestAccess(for: .video) { grant in
            if grant {
                DispatchQueue.main.async {
                    self.allowCameraAccessView.isHidden = true
                    self.startSession()
                }
            }
        }
    }

    func startSession() {
        self.session?.startRunning()
    }

    func stopSession() {
        session?.stopRunning()
    }

    /// sets up the camera session.
    func setupCaptureSession() {
        guard let device = findRearCamera() else {
            self.showNoRearDeviceAlert()
            return
        }

        // got the device, capture the input
        guard let input = try? AVCaptureDeviceInput.init(device: device) else {
            // return error, camera not available.
            return
        }

        self.session = AVCaptureSession.init()
        if self.session!.canAddInput(input) {
            self.session?.addInput(input)
        } else {
            // throw error, cannot add input
        }

        self.session?.addOutput(output)

        // intersted only in qr codes
        output.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        let rect = self.previewView.videoPreviewLayer.metadataOutputRectConverted(fromLayerRect:
            self.overlayView.focusRect)
        self.output.rectOfInterest = rect

        previewView.videoPreviewLayer.session = session
        previewView.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill

        // set up overlay view
        overlayView.setup()
    }

    // get device rear camera if available or nil
    func findRearCamera() -> AVCaptureDevice? {
        let types = deviceTypesAvailable()
        let discovery = AVCaptureDevice.DiscoverySession.init(deviceTypes: types,
                                                              mediaType: .video,
                                                              position: .back)

        return discovery.devices.first
    }

    private func deviceTypesAvailable() -> [AVCaptureDevice.DeviceType] {
        var deviceTypes = [AVCaptureDevice.DeviceType]()

        if #available(iOS 11.1, *) {
            deviceTypes.append(.builtInTrueDepthCamera)
        }

        if #available(iOS 10.2, *) {
            deviceTypes.append(.builtInDualCamera)
        } else {
            deviceTypes.append(.builtInDuoCamera)
        }

        deviceTypes.append(.builtInWideAngleCamera)
        return deviceTypes
    }
}

// MARK: - Alerts
extension QRScannerViewController {
    func showNoRearDeviceAlert() {
        // display alert that you dont have a rear device
    }

    @IBAction func showSettingsAlert() {
        // display settings alert
        let title = "Allow camera access"
        let message = "Go to Settings and enable camera"
        let alertController = UIAlertController.init(title: title,
                                                     message: message,
                                                     preferredStyle: .alert)

        let settingsAction = UIAlertAction.init(title: "Settings",
                                                style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            UIApplication.shared.open(settingsUrl)
        }

        let notNowAction = UIAlertAction.init(title: "Not Now",
                                                style: .default)

        alertController.addAction(notNowAction)
        alertController.addAction(settingsAction)

        self.present(alertController, animated: true, completion: nil)
    }

    @IBAction func makeButtonDoSomethingUseful() {
        let url: URL! = URL(string: "https://2020.iosconf.sg/schedule/")
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = self
        present(safariViewController, animated: true, completion: nil)
    }
}

// MARK: - SFSafariViewControllerDelegate
extension QRScannerViewController: SFSafariViewControllerDelegate {
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard let metaData = metadataObjects.first,
            metaData.type == AVMetadataObject.ObjectType.qr,
            let codeObj = metaData as? AVMetadataMachineReadableCodeObject,
            let qrCode = codeObj.stringValue else {
                // failed because of one of the reasons above.
                return
        }

        // got qr code
        if session?.isRunning == true {
            session?.stopRunning()
        }

        delegate?.didCapture(qrcode: qrCode)
    }
}
