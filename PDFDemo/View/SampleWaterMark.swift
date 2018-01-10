//
//  SampleWaterMark.swift
//  PDFDemo
//
//  Created by Shawn Roller on 1/10/18.
//  Copyright © 2018 Shawn Roller. All rights reserved.
//

import UIKit
import PDFKit

class SampleWaterMark: PDFPage {

    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        
        let watermark: NSString = "SAMPLE CHAPTER"
        let color = UIColor(red: 0.941, green: 0.082, blue: 0.208, alpha: 0.5)
        let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: color, .font: UIFont.boldSystemFont(ofSize: 64)]
        let watermarkSize = watermark.size(withAttributes: attributes)
        
        // Save graphics state before making changes
        UIGraphicsPushContext(context)
        context.saveGState()
        
        let pageBounds = bounds(for: box)
        
        // Move and flip the context so it's right side up
        context.translateBy(x: pageBounds.size.width - watermarkSize.width, y: (pageBounds.size.height - (watermarkSize.height * 2)) / 2)
        context.rotate(by: CGFloat.pi / 4)
        context.scaleBy(x: 1, y: -1)
        
        watermark.draw(at: CGPoint(x: 0, y: 0), withAttributes: attributes)
        
        // Restore graphics context
        context.restoreGState()
        UIGraphicsPopContext()
        
        super.draw(with: box, to: context)
    }
    
}
