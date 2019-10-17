//
//  ViewController.swift
//  P27CoreGraphics
//
//  Created by Chris Parker on 12/6/19.
//  Copyright © 2019 Chris Parker. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    var currentDrawType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawRectangle()
    }

     @IBAction func redrawTapped(_ sender: Any) {
        currentDrawType += 1
        
        if currentDrawType > 7 {
            currentDrawType = 0
        }
        
        switch currentDrawType {
        case 0:
            drawRectangle()
            
        case 1:
            drawCircle()
            
        case 2:
            drawCheckerboard()
            
        case 3:
            drawRotatedSquares()
            
        case 4:
            drawLines()
            
        case 5:
            drawImagesAndText()
            
        case 6:
            drawStarEmoji()
            
        case 7:
            drawTwin()
            
        default:
            break
        }
    }
    
    func drawRectangle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let renderedImage = renderer.image { ctx in
            //  awesome drawing code
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = renderedImage
    }
    
    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let renderedImage = renderer.image { ctx in
            //  awesome drawing code
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = renderedImage
    }
    
    func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let renderedImage = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            
            for row in 0 ..< 8 {
                for col in 0 ..< 8 {
                    if (row + col) % 2 == 0 {
                        ctx.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
                    }
                }
            }
        }
        
        imageView.image = renderedImage
    }
    
    func drawRotatedSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let renderedImage = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)  //  Shifts the rotation point to the centre of the image.
            
            let rotations = 16
            let amount = Double.pi / Double(rotations)
            
            for _ in 0 ..< rotations {
                ctx.cgContext.rotate(by: CGFloat(amount))
                ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        
        imageView.image = renderedImage
    }
    
    func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let renderedImage = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            var first = true
            var length: CGFloat = 256
            
            for _ in 0 ..< 256 {
                ctx.cgContext.rotate(by: .pi / 2)
                
                if first {
                    ctx.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }
                
                length *= 0.99
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        
        imageView.image = renderedImage
    }
    
    func drawImagesAndText() {
        // 1  Create a renderer at the correct size.
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let renderedImage = renderer.image { ctx in
            // 2  Define a paragraph style that aligns text to the center.
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            // 3  Create an attributes dictionary containing that paragraph style, and also a font.
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragraphStyle
            ]
            
            // 4  Wrap that attributes dictionary and a string into an instance of NSAttributedString.
            let string = "The best-laid schemes o'\nmice an' men gang aft agley"
            let attributedString = NSAttributedString(string: string, attributes: attrs)
            
            // 5  Load an image from the project and draw it to the context.  Origin is top left corner of renderer rectangle.
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            
            // 6  Update the image view with the finished result.
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
        
        imageView.image = renderedImage
    }
    
    func drawStarEmoji() {
        print("Star Emoji")
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let renderedImage = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            ctx.cgContext.setFillColor(UIColor.yellow.cgColor)
            
            var first = true
            let length: CGFloat = 200
            let radians = CGFloat(Measurement(value: 144, unit: UnitAngle.degrees).converted(to: UnitAngle.radians).value)
            
            ctx.cgContext.rotate(by: -(32 * .pi / 180))
            for _ in 0 ..< 6 {
                ctx.cgContext.rotate(by: radians)
                
                if first {
                    ctx.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }
                
            }
            
            ctx.cgContext.setStrokeColor(UIColor.yellow.cgColor)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = renderedImage
        
    }
    
    func drawTwin() {
        print("TWIN")
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let renderedImage = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 10, y: 150)
            ctx.cgContext.setLineWidth(2)
            
            let mult = 8
            
            //  T
            ctx.cgContext.move(to: CGPoint(x: 14 * mult, y: 10 * mult))
            ctx.cgContext.addLine(to: CGPoint(x: 20 * mult, y: 10 * mult))
            ctx.cgContext.move(to: CGPoint(x: 17 * mult, y: 10 * mult))
            ctx.cgContext.addLine(to: CGPoint(x: 17 * mult, y: 21 * mult))
            
            //  W
            ctx.cgContext.move(to: CGPoint(x: 22 * mult, y: 10 * mult))
            ctx.cgContext.addLine(to: CGPoint(x: 24 * mult, y: 21 * mult))
            ctx.cgContext.move(to: CGPoint(x: 24 * mult, y: 21 * mult))
            ctx.cgContext.addLine(to: CGPoint(x: 26 * mult, y: 10 * mult))
            ctx.cgContext.move(to: CGPoint(x: 26 * mult, y: 10 * mult))
            ctx.cgContext.addLine(to: CGPoint(x: 28 * mult, y: 21 * mult))
            ctx.cgContext.move(to: CGPoint(x: 28 * mult, y: 21 * mult))
            ctx.cgContext.addLine(to: CGPoint(x: 30 * mult, y: 10 * mult))
            
            //  I
            ctx.cgContext.move(to: CGPoint(x: 32 * mult, y: 10 * mult))
            ctx.cgContext.addLine(to: CGPoint(x: 32 * mult, y: 21 * mult))
            
            //  N
            ctx.cgContext.move(to: CGPoint(x: 34 * mult, y: 21 * mult))
            ctx.cgContext.addLine(to: CGPoint(x: 34 * mult, y: 10 * mult))
            ctx.cgContext.move(to: CGPoint(x: 34 * mult, y: 10 * mult))
            ctx.cgContext.addLine(to: CGPoint(x: 40 * mult, y: 21 * mult))
            ctx.cgContext.move(to: CGPoint(x: 40 * mult, y: 21 * mult))
            ctx.cgContext.addLine(to: CGPoint(x: 40 * mult, y: 10 * mult))
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        
        imageView.image = renderedImage
        
    }

}

