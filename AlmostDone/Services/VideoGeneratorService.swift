//
//  VideoGeneratorService.swift
//  AlmostDone
//
//  Created by cybercrot on 19.11.2025.
//

import Foundation
import AVFoundation
import UIKit

class VideoGeneratorService {
    static let shared = VideoGeneratorService()
    
    private init() {}
    
    // Cached resources for performance
    private var cachedGlowGradient: CGGradient?
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
    
    private func getGlowGradient() -> CGGradient {
        if let cached = cachedGlowGradient {
            return cached
        }
        // Увеличенная яркость свечения: более яркие alpha компоненты
        let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [
                UIColor.systemYellow.withAlphaComponent(0.6).cgColor,  // Увеличено с 0.3 до 0.6
                UIColor.systemOrange.withAlphaComponent(0.35).cgColor, // Увеличено с 0.15 до 0.35
                UIColor.black.withAlphaComponent(0.0).cgColor
            ] as CFArray,
            locations: [0, 0.5, 1]
        )!
        cachedGlowGradient = gradient
        return gradient
    }
    
    func generateNewYearVideo(from victories: [AlmostMoment], onProgress: ((Double) -> Void)? = nil) async throws -> URL {
        let videoSize = CGSize(width: 1000, height: 1000) // Square format 1000x1000
        let videoDuration: TimeInterval = Double(victories.count) * 3.0 + 3.0 // 3 seconds per victory + 3s intro
        
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("newYearVideo-\(UUID().uuidString).mp4")
        
        // Remove existing file if any
        try? FileManager.default.removeItem(at: outputURL)
        
        let videoWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoSize.width,
            AVVideoHeightKey: videoSize.height
        ]
        
        let videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: videoWriterInput, sourcePixelBufferAttributes: nil)
        
        guard videoWriter.canAdd(videoWriterInput) else {
            throw NSError(domain: "VideoGenerator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Cannot add video input"])
        }
        
        videoWriter.add(videoWriterInput)
        videoWriter.startWriting()
        videoWriter.startSession(atSourceTime: .zero)
        
        let frameDuration = CMTime(seconds: 1.0/30.0, preferredTimescale: 600)
        var frameCount: Int64 = 0
        let totalFrames = Int64(videoDuration * 30)
        
        // 1. Intro Scene ("My Victories")
        let introImage = createIntroImage(size: videoSize)
        let fadeFrames = 15 // Fade transition frames (0.5 seconds at 30fps)
        for i in 0..<90 { // 3 seconds
            if !videoWriterInput.isReadyForMoreMediaData { continue }
            let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
            
            // No fade in at the start - start fully visible
            let alpha: CGFloat = 1.0
            if let buffer = createPixelBufferWithAlpha(from: introImage, alpha: alpha, size: videoSize) {
                adaptor.append(buffer, withPresentationTime: presentationTime)
                frameCount += 1
                onProgress?(Double(frameCount) / Double(totalFrames))
            }
        }
        
        // 2. Victory Scenes
        for (victoryIndex, victory) in victories.enumerated() {
            let image: UIImage
            if let mediaURL = victory.mediaURLValue,
               let loadedImage = MediaService.shared.loadImage(from: mediaURL) {
                image = loadedImage
            } else {
                image = createPlaceholderImage(for: victory)
            }
            
            // Create static bubble image ONCE
            let staticBubbleImage = createStaticBubbleImage(for: victory, size: videoSize)
            
            // Show image for 3 seconds (90 frames)
            for i in 0..<90 {
                if !videoWriterInput.isReadyForMoreMediaData { continue }
                
                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
                
                // Animation Parameters
                let progress = Double(i) / 90.0
                // Pulsing: 1.0 -> 1.05 -> 1.0
                let scale = 1.0 + 0.05 * sin(progress * .pi)
                // Floating: Up and down - уменьшено на 50% для более спокойного покачивания
                let yOffset = 10.0 * sin(progress * 2 * .pi) // Было 20.0, теперь 10.0
                
                // Render frame using optimized method
                var frameImage = renderOptimizedFrame(
                    bgImage: image,
                    bubbleImage: staticBubbleImage,
                    victory: victory,
                    size: videoSize,
                    scale: scale,
                    yOffset: yOffset
                )
                
                // Fade transitions - optimized: calculate alpha but render directly
                var alpha: CGFloat = 1.0
                if i < fadeFrames {
                    // Fade in at start of scene
                    alpha = CGFloat(i) / CGFloat(fadeFrames)
                } else if i >= 90 - fadeFrames {
                    // Fade out at end of scene (except last victory)
                    if victoryIndex < victories.count - 1 {
                        let fadeOutProgress = CGFloat(i - (90 - fadeFrames)) / CGFloat(fadeFrames)
                        alpha = 1.0 - fadeOutProgress
                    }
                }
                
                // Draw directly to buffer with alpha (skip intermediate UIImage for fade)
                if let buffer = createPixelBufferWithAlpha(from: frameImage, alpha: alpha, size: videoSize) {
                    adaptor.append(buffer, withPresentationTime: presentationTime)
                    frameCount += 1
                    onProgress?(Double(frameCount) / Double(totalFrames))
                }
            }
        }
        
        // Fill remaining frames
        while frameCount < totalFrames {
            if !videoWriterInput.isReadyForMoreMediaData { continue }
            let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameCount))
            if let buffer = createPixelBuffer(from: UIImage.blackImage(size: videoSize), size: videoSize) {
                adaptor.append(buffer, withPresentationTime: presentationTime)
                frameCount += 1
                onProgress?(Double(frameCount) / Double(totalFrames))
            }
        }
        
        videoWriterInput.markAsFinished()
        await videoWriter.finishWriting()
        
        if videoWriter.status == .failed {
            throw videoWriter.error ?? NSError(domain: "VideoGenerator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Video writing failed"])
        }
        
        return outputURL
    }
    
    private func createPlaceholderImage(for victory: AlmostMoment) -> UIImage {
        let size = CGSize(width: 1000, height: 1000)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background Gradient
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor] as CFArray, locations: [0, 1])!
            context.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            
            // Just a simple placeholder background, info will be overlaid later
        }
    }
    
    private func createIntroImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // Background Gradient
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [UIColor.systemYellow.cgColor, UIColor.systemOrange.cgColor] as CFArray, locations: [0, 1])!
            context.cgContext.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])
            
            // Text
            let text = "MY VICTORIES"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 100, weight: .black),
                .foregroundColor: UIColor.white
            ]
            let textSize = text.size(withAttributes: attributes)
            text.draw(at: CGPoint(x: (size.width - textSize.width)/2, y: (size.height - textSize.height)/2), withAttributes: attributes)
            
            let yearText = String(Calendar.current.component(.year, from: Date()))
            let yearAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 60, weight: .bold),
                .foregroundColor: UIColor.white.withAlphaComponent(0.8)
            ]
            let yearSize = yearText.size(withAttributes: yearAttr)
            yearText.draw(at: CGPoint(x: (size.width - yearSize.width)/2, y: (size.height + textSize.height)/2 + 20), withAttributes: yearAttr)
        }
    }
    
    private func createStaticBubbleImage(for victory: AlmostMoment, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let centerX = size.width / 2
            let centerY = size.height / 2
            let bubbleSize: CGFloat = 490 // Reduced by 30% (700 * 0.7 = 490)
            
            // Define bubbleRect first (needed for shadow calculation)
            let bubbleRect = CGRect(
                x: centerX - bubbleSize / 2,
                y: centerY - bubbleSize / 2,
                width: bubbleSize,
                height: bubbleSize
            )
            
            // 1. Glow Layer - matching TimelineBubbleView exactly
            // For victory: Circle with blur effect (simulated with multiple layers)
            let glowSize = bubbleSize * 1.4
            let glowRect = CGRect(
                x: centerX - glowSize / 2,
                y: centerY - glowSize / 2,
                width: glowSize,
                height: glowSize
            )
            
            // Simulate blur with multiple semi-transparent circles
            for i in 0..<5 {
                let blurRadius = CGFloat(i) * 4.0
                let blurAlpha = 0.6 * (1.0 - CGFloat(i) * 0.15)
                let blurRect = glowRect.insetBy(dx: -blurRadius, dy: -blurRadius)
                UIColor.systemYellow.withAlphaComponent(blurAlpha).setFill()
                context.cgContext.fillEllipse(in: blurRect)
            }
            
            // 2. Shadow on bubble - matching TimelineBubbleView (draw BEFORE bubble)
            // shadow(color: bubbleColor.opacity(0.2), radius: 10, x: 0, y: 5)
            let shadowRect = bubbleRect.offsetBy(dx: 0, dy: 5)
            // Simulate blur radius 10 with multiple layers
            for i in 0..<3 {
                let blurRadius = CGFloat(i) * 3.5
                let blurRect = shadowRect.insetBy(dx: -blurRadius, dy: -blurRadius)
                let blurPath = UIBezierPath(ovalIn: blurRect)
                UIColor.systemYellow.withAlphaComponent(0.2 * (1.0 - CGFloat(i) * 0.25)).setFill()
                context.cgContext.addPath(blurPath.cgPath)
                context.cgContext.fillPath()
            }
            
            // 3. Soap Bubble Layer - RadialGradient: от полупрозрачного желтого на краях до почти прозрачного в центре
            let bubblePath = UIBezierPath(ovalIn: bubbleRect)
            
            // Radial gradient: от почти прозрачного в центре (0.0125) до полупрозрачного на краях (0.1375) - уменьшено еще на 50%
            let radialGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor.systemYellow.withAlphaComponent(0.0125).cgColor,
                    UIColor.systemYellow.withAlphaComponent(0.1375).cgColor
                ] as CFArray,
                locations: [0, 1]
            )!
            context.cgContext.addPath(bubblePath.cgPath)
            context.cgContext.clip()
            context.cgContext.drawRadialGradient(
                radialGradient,
                startCenter: CGPoint(x: centerX, y: centerY),
                startRadius: 0,
                endCenter: CGPoint(x: centerX, y: centerY),
                endRadius: bubbleSize / 2,
                options: []
            )
            context.cgContext.resetClip()
            
            // 3.5. Второй круг пузыря - меньшего размера, светлее, с радиальным градиентом
            let secondBubbleSize = bubbleSize * 0.75 // 75% от основного размера
            let secondBubbleRect = CGRect(
                x: centerX - secondBubbleSize / 2,
                y: centerY - secondBubbleSize / 2,
                width: secondBubbleSize,
                height: secondBubbleSize
            )
            let secondBubblePath = UIBezierPath(ovalIn: secondBubbleRect)
            
            // Более светлый желтый цвет, прозрачный в центре, полупрозрачный на краях (уменьшено еще на 50%)
            let secondRadialGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor.systemYellow.withAlphaComponent(0.0).cgColor, // Полностью прозрачный в центре
                    UIColor.systemYellow.withAlphaComponent(0.1).cgColor // Светлее основного круга на краях (было 0.2)
                ] as CFArray,
                locations: [0, 1]
            )!
            context.cgContext.addPath(secondBubblePath.cgPath)
            context.cgContext.clip()
            context.cgContext.drawRadialGradient(
                secondRadialGradient,
                startCenter: CGPoint(x: centerX, y: centerY),
                startRadius: 0,
                endCenter: CGPoint(x: centerX, y: centerY),
                endRadius: secondBubbleSize / 2,
                options: []
            )
            context.cgContext.resetClip()
            
            // 3. StrokeBorder with LinearGradient - matching TimelineBubbleView
            // White gradient: 0.6 -> 0.1 -> 0.3 (topLeading to bottomTrailing)
            let borderGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor.white.withAlphaComponent(0.6).cgColor,
                    UIColor.white.withAlphaComponent(0.1).cgColor,
                    UIColor.white.withAlphaComponent(0.3).cgColor
                ] as CFArray,
                locations: [0, 0.5, 1]
            )!
            context.cgContext.saveGState()
            context.cgContext.addPath(bubblePath.cgPath)
            context.cgContext.setLineWidth(1)
            context.cgContext.replacePathWithStrokedPath()
            context.cgContext.clip()
            // Draw gradient from topLeading to bottomTrailing
            let topLeading = CGPoint(x: bubbleRect.minX, y: bubbleRect.minY)
            let bottomTrailing = CGPoint(x: bubbleRect.maxX, y: bubbleRect.maxY)
            context.cgContext.drawLinearGradient(
                borderGradient,
                start: topLeading,
                end: bottomTrailing,
                options: []
            )
            context.cgContext.resetClip()
            context.cgContext.restoreGState()
            
            // 4. Inner shadow simulation - matching TimelineBubbleView
            // stroke with blur (simulated with semi-transparent stroke)
            context.cgContext.saveGState()
            context.cgContext.addPath(bubblePath.cgPath)
            context.cgContext.setLineWidth(4)
            context.cgContext.setStrokeColor(UIColor.systemYellow.withAlphaComponent(0.3).cgColor)
            // Simulate blur with multiple strokes
            for i in 0..<3 {
                let strokeAlpha = 0.3 * (1.0 - CGFloat(i) * 0.2)
                context.cgContext.setStrokeColor(UIColor.systemYellow.withAlphaComponent(strokeAlpha).cgColor)
                context.cgContext.setLineWidth(4 - CGFloat(i))
                context.cgContext.strokePath()
            }
            context.cgContext.restoreGState()
            
            // 5. Specular highlight (Reflection) - matching TimelineBubbleView exactly
            // Ellipse at 15% from top-left, 35% width, 20% height, rotated -45 degrees
            let highlightWidth = bubbleSize * 0.35
            let highlightHeight = bubbleSize * 0.20
            let highlightX = bubbleRect.minX + bubbleSize * 0.15
            let highlightY = bubbleRect.minY + bubbleSize * 0.15
            let highlightRect = CGRect(
                x: highlightX,
                y: highlightY,
                width: highlightWidth,
                height: highlightHeight
            )
            
            // Draw rotated highlight with radial gradient: прозрачный по краям, opacity 0.35 в центре
            context.cgContext.saveGState()
            context.cgContext.translateBy(x: centerX, y: centerY)
            context.cgContext.rotate(by: -CGFloat.pi / 4) // -45 degrees
            context.cgContext.translateBy(x: -centerX, y: -centerY)
            
            // Радиальный градиент для блика: от прозрачного на краях до 0.35 в центре
            let highlightPath = UIBezierPath(ovalIn: highlightRect)
            let highlightGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor.white.withAlphaComponent(0.35).cgColor, // В центре opacity 0.35
                    UIColor.white.withAlphaComponent(0.0).cgColor   // Прозрачный на краях
                ] as CFArray,
                locations: [0, 1]
            )!
            
            // Центр градиента - центр овала
            let highlightCenter = CGPoint(
                x: highlightRect.midX,
                y: highlightRect.midY
            )
            let highlightRadius = max(highlightRect.width, highlightRect.height) / 2
            
            context.cgContext.addPath(highlightPath.cgPath)
            context.cgContext.clip()
            context.cgContext.drawRadialGradient(
                highlightGradient,
                startCenter: highlightCenter,
                startRadius: 0,
                endCenter: highlightCenter,
                endRadius: highlightRadius,
                options: []
            )
            context.cgContext.resetClip()
            context.cgContext.restoreGState()
            
            // 6. Date at top of bubble (outside)
            let dateText = Self.dateFormatter.string(from: victory.timestamp)
            let dateAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 47, weight: .bold), // Increased by 30% (36 -> 47)
                .foregroundColor: UIColor.white,
                .shadow: NSShadow() // Add shadow for better visibility
            ]
            if let shadow = dateAttr[.shadow] as? NSShadow {
                shadow.shadowColor = UIColor.black.withAlphaComponent(0.5)
                shadow.shadowOffset = CGSize(width: 0, height: 2)
                shadow.shadowBlurRadius = 4
            }
            
            let dateSize = dateText.size(withAttributes: dateAttr)
            dateText.draw(
                at: CGPoint(
                    x: centerX - dateSize.width / 2,
                    y: bubbleRect.minY - dateSize.height - 40
                ),
                withAttributes: dateAttr
            )
            
            // 8. Category Icon (centered in bubble) - using category icon
            let iconSize: CGFloat = bubbleSize * 0.4
            // Use category icon instead of trophy
            if let iconImage = UIImage.from(systemName: victory.categoryEnum.iconName, pointSize: iconSize, weight: .regular, color: .white) {
                let iconRect = CGRect(
                    x: centerX - iconSize / 2,
                    y: centerY - iconSize / 2,
                    width: iconSize,
                    height: iconSize
                )
                
                // Draw icon with shadow
                context.cgContext.saveGState()
                context.cgContext.setShadow(offset: CGSize(width: 0, height: 0), blur: 8, color: UIColor.orange.withAlphaComponent(0.8).cgColor)
                iconImage.draw(in: iconRect)
                context.cgContext.restoreGState()
            }
            
            // 9. Info Text - below bubble
            var currentY = bubbleRect.maxY + 40
            let textWidth = size.width - 100 // Padding 50 on each side
            
            // Helper for centered text with shadow
            func drawCenteredText(_ text: String, font: UIFont, color: UIColor, y: CGFloat) -> CGFloat {
                let attr: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .shadow: NSShadow()
                ]
                if let shadow = attr[.shadow] as? NSShadow {
                    shadow.shadowColor = UIColor.black.withAlphaComponent(0.8)
                    shadow.shadowOffset = CGSize(width: 0, height: 2)
                    shadow.shadowBlurRadius = 4
                }
                
                let textSize = text.boundingRect(
                    with: CGSize(width: textWidth, height: .infinity),
                    options: .usesLineFragmentOrigin,
                    attributes: attr,
                    context: nil
                ).size
                
                let rect = CGRect(
                    x: (size.width - textSize.width) / 2,
                    y: y,
                    width: textSize.width,
                    height: textSize.height
                )
                
                text.draw(in: rect, withAttributes: attr)
                return y + textSize.height + 16 // Return next Y
            }
            
            // Overcame: [Obstacle]
            let obstacleText = "Overcame: \(victory.obstacleEnum.displayName)"
            currentY = drawCenteredText(obstacleText, font: .systemFont(ofSize: 42, weight: .semibold), color: .white, y: currentY) // Increased by 30% (32 -> 42)
            
            // Feeling: [VictoryFeeling]
            if let feeling = victory.victoryFeeling, !feeling.isEmpty {
                let feelingText = "Feeling: \(feeling)"
                currentY = drawCenteredText(feelingText, font: .systemFont(ofSize: 42, weight: .semibold), color: .systemYellow, y: currentY) // Increased by 30% (32 -> 42)
            }
            
            // Story Text
            if let text = victory.text, !text.isEmpty {
                // Wrap text if too long
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let textAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.italicSystemFont(ofSize: 36), // Increased by 30% (28 -> 36)
                    .foregroundColor: UIColor.white.withAlphaComponent(0.9),
                    .paragraphStyle: paragraphStyle,
                    .shadow: NSShadow()
                ]
                if let shadow = textAttr[.shadow] as? NSShadow {
                    shadow.shadowColor = UIColor.black.withAlphaComponent(0.8)
                    shadow.shadowOffset = CGSize(width: 0, height: 1)
                    shadow.shadowBlurRadius = 2
                }
                
                let rect = CGRect(x: 50, y: currentY + 10, width: size.width - 100, height: size.height - currentY - 20)
                text.draw(in: rect, withAttributes: textAttr)
            }
        }
    }
    
    private func renderOptimizedFrame(bgImage: UIImage, bubbleImage: UIImage, victory: AlmostMoment, size: CGSize, scale: Double, yOffset: Double) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            // 1. Black background
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // 2. Golden Glow Background Gradient (radial from center) - увеличенная яркость
            let glowCenter = CGPoint(x: size.width / 2, y: size.height / 2 + yOffset)
            let glowRadius = size.width * 0.75 // Увеличен радиус для более яркого свечения (было 0.6)
            let glowGradient = getGlowGradient()
            context.cgContext.drawRadialGradient(
                glowGradient,
                startCenter: glowCenter,
                startRadius: 0,
                endCenter: glowCenter,
                endRadius: glowRadius,
                options: [.drawsAfterEndLocation]
            )
            
            // 3. Draw static bubble with transformation
            context.cgContext.saveGState()
            
            // Translate to center to scale from center
            context.cgContext.translateBy(x: size.width / 2, y: size.height / 2 + yOffset)
            context.cgContext.scaleBy(x: scale, y: scale)
            
            // Draw bubble image centered
            bubbleImage.draw(at: CGPoint(x: -size.width / 2, y: -size.height / 2))
            
            context.cgContext.restoreGState()
            
            // 4. Victory Feeling - REMOVED (moved to static bubble image)
        }
    }
    
    private func getCategoryIconText(for category: Category) -> String {
        // Using emoji as simple representation since we can't easily render SF Symbols in Core Graphics
        switch category {
        case .love: return "❤️"
        case .career: return "💼"
        case .sport: return "🏃"
        case .travel: return "✈️"
        case .creativity: return "🎨"
        case .extreme: return "🔥"
        case .health: return "🏥"
        case .other: return "⭐"
        }
    }
    
    private func createPixelBufferWithAlpha(from image: UIImage, alpha: CGFloat, size: CGSize) -> CVPixelBuffer? {
        // If alpha is 1.0, use regular method
        if alpha >= 0.999 {
            return createPixelBuffer(from: image, size: size)
        }
        
        // Otherwise, draw with alpha directly to buffer
        guard let buffer = createEmptyPixelBuffer(size: size) else { return nil }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        guard let context = createContext(for: buffer, size: size) else {
            return nil
        }
        
        // Clear buffer
        context.clear(CGRect(origin: .zero, size: size))
        
        // Fill black background
        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Draw image with alpha
        context.setAlpha(alpha)
        if let cgImage = image.cgImage {
            context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        }
        
        return buffer
    }
    
    private func createEmptyPixelBuffer(size: CGSize) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        return buffer
    }
    
    private func createContext(for buffer: CVPixelBuffer, size: CGSize) -> CGContext? {
        return CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        )
    }
    
    private func createPixelBuffer(from image: UIImage, size: CGSize) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue!,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue!
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            attrs,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
        
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        )
        
        guard let cgContext = context else {
            return nil
        }
        
        // Clear the buffer first
        cgContext.clear(CGRect(origin: .zero, size: size))
        
        // Draw the image
        if let cgImage = image.cgImage {
            cgContext.draw(cgImage, in: CGRect(origin: .zero, size: size))
        }
        
        return buffer
    }
}

// UIImage extensions
extension UIImage {
    func scaled(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    static func blackImage(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

