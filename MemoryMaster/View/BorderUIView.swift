//
//  BorderUIView.swift
//  Recite
// 
//  Draw a top line for QATableViewCell
//
//  Created by apple on 22/9/2017.
//  Copyright © 2017 greatwall. All rights reserved.
//

import UIKit

class BorderUIView: UIView {

    override func draw(_ rect: CGRect) {
        super .draw(rect)
        
        let ctx = UIGraphicsGetCurrentContext()
        
        ctx?.setStrokeColor(CustomColor.wordGray.cgColor)
        ctx?.setLineWidth(1)
//        ctx?.setFillColor(UIColor.clear.cgColor)
        
        ctx?.setLineJoin(CGLineJoin.round)
        ctx?.setLineCap(CGLineCap.round)
        
        drawLeftCorner(ctx!)
        
        drawLine(ctx!, rect)
        
        drawRightCorner(ctx!, rect)
    }

    func drawLine(_ ctx: CGContext, _ rect: CGRect) {
        let points1 = [CGPoint(x: 10, y: 1), CGPoint(x: rect.size.width - 10, y: 1)]
        ctx.addLines(between: points1)
        ctx.strokePath()
    }
    
    func drawLeftCorner(_ ctx: CGContext) {
        ctx.addArc(center: CGPoint(x: 10, y: 11), radius: 10, startAngle: .pi, endAngle: 1.5 * .pi, clockwise: false)
        ctx.strokePath()
    }
    
    func drawRightCorner(_ ctx: CGContext, _ rect:CGRect) {
        ctx.addArc(center: CGPoint(x: rect.size.width - 10, y: 11), radius: 10, startAngle: 1.5 * .pi, endAngle: 2 * .pi, clockwise: false)
        ctx.strokePath()
    }
    
}
