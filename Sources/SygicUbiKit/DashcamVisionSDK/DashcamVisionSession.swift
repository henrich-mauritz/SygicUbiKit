import AVFoundation
import Foundation

// MARK: - DashcamVisionSession

class DashcamVisionSession: DashcamSession {
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        super.captureOutput(output, didOutput: sampleBuffer, from: connection)
        guard output is AVCaptureVideoDataOutput else { return }
        VisionManager.shared.processImage(sampleBuffer)
    }
}
