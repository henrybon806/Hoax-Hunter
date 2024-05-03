////
////  Camera.swift
////  Hoax Hunter
////
////  Created by Henry Bonomolo on 11/29/23.
////
//
//import SwiftUI
//import AVFoundation
//
//
//struct Camera: UIViewControllerRepresentable {
//    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
//        var parent: Camera
//
//        init(parent: Camera) {
//            self.parent = parent
//        }
//
//        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//            // Process the live video feed here if needed
//        }
//    }
//    
//    var didCaptureImage: (UIImage) -> Void
//
//        func makeCoordinator() -> Coordinator {
//            return Coordinator(parent: self)
//        }
//
//        func makeUIViewController(context: Context) -> UIViewController {
//            let viewController = UIViewController()
//            let captureSession = AVCaptureSession()
//
//            guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
//                return viewController
//            }
//
//            do {
//                let input = try AVCaptureDeviceInput(device: frontCamera)
//                captureSession.addInput(input)
//            } catch {
//                return viewController
//            }
//
//            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//            previewLayer.videoGravity = .resizeAspectFill
//            previewLayer.frame = viewController.view.layer.bounds
//            viewController.view.layer.addSublayer(previewLayer)
//
//            let output = AVCaptureVideoDataOutput()
//            output.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "cameraQueue"))
//            captureSession.addOutput(output)
//
//            captureSession.startRunning()
//
//            return viewController
//        }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
//}
//
//struct ContentView: View {
//    var body: some View {
//        NavigationView {
//            Camera { image in
//                // Handle the captured image here
//                print("Image captured")
//            }
//            .navigationBarTitle("Camera Feed")
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//}
