
import UIKit

var height = CGFloat()

class CalendarLineView: UIView {

    func makeLine(at y: CGFloat, in rect: CGRect) -> UIBezierPath {
//        precondition((rect.minY...rect.maxY).contains(y))
        let line = UIBezierPath()
        line.move(to: CGPoint(x: rect.minX, y: y))
        line.addLine(to: CGPoint(x: rect.maxX, y: y))
        return line
    }
    
    func strokePath(_ path: UIBezierPath, width: CGFloat) {
        path.lineWidth = width
        
        // Line Color
        #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.28).setStroke()
        path.stroke()
    }
    
    var pixelUnit: CGFloat  {
        return 1.0 / UIScreen.main.scale
    }
    
    func round(from: CGFloat, fraction: CGFloat, down: Bool = true) -> CGFloat {
        let expanded = from / fraction
        let rounded = (down ? floor : ceil)(expanded)
        return rounded * fraction
    }
    
    func singlePixelLine(at y: CGFloat, in rect: CGRect, topBias: Bool = true) {
        let offset = pixelUnit/2.0
        let adjustedY = round(from: y - offset, fraction: pixelUnit, down: topBias) + offset
        let line = makeLine(at: adjustedY, in: rect)
        strokePath(line, width: pixelUnit)
    }
    
    func setHeight(_ setHi: CGFloat) {
        height = setHi
    }
    
    override func draw(_ rect: CGRect) {
        
        singlePixelLine(at: 0, in: rect, topBias: false)
        singlePixelLine(at: height * 1, in: rect, topBias: false)
        singlePixelLine(at: height * 2, in: rect, topBias: false)
        singlePixelLine(at: height * 3, in: rect, topBias: false)
        singlePixelLine(at: height * 4, in: rect, topBias: false)
        singlePixelLine(at: height * 5, in: rect, topBias: true)
        singlePixelLine(at: height * 6, in: rect, topBias: true)
        
//        let width = bounds.size.width
//        let height = bounds.size.height / 6
//        UIColor.black.set()
        
//        let point1Start = CGPoint(x: 0, y: 0)
//        let point1End = CGPoint(x: width, y: 0)
//        let point2Start = CGPoint(x: 0, y: height * 1)
//        let point2End = CGPoint(x: width, y: height * 1)
//        let point3Start = CGPoint(x: 0, y: height * 2)
//        let point3End = CGPoint(x: width, y: height * 2)
//        let point4Start = CGPoint(x: 0, y: height * 3)
//        let point4End = CGPoint(x: width, y: height * 3)
//        let point5Start = CGPoint(x: 0, y: height * 4)
//        let point5End = CGPoint(x: width, y: height * 4)
//        let point6Start = CGPoint(x: 0, y: height * 5)
//        let point6End = CGPoint(x: width, y: height * 5)
//        let point7Start = CGPoint(x: 0, y: height * 6)
//        let point7End = CGPoint(x: width, y: height * 6)
        
//        let path = UIBezierPath()
//        path.lineWidth = 1
//
//        path.move(to: point1Start)
//        path.addLine(to: point1End)
//        path.stroke()
//
//        path.move(to: point2Start)
//        path.addLine(to: point2End)
//        path.stroke()
//
//        path.move(to: point3Start)
//        path.addLine(to: point3End)
//        path.stroke()
//
//        path.move(to: point4Start)
//        path.addLine(to: point4End)
//        path.stroke()
//
//        path.move(to: point5Start)
//        path.addLine(to: point5End)
//        path.stroke()
//
//        path.move(to: point6Start)
//        path.addLine(to: point6End)
//        path.stroke()
//
//        path.move(to: point7Start)
//        path.addLine(to: point7End)
//        path.stroke()
        
//        let weekRect1 = CGRect(x: 0, y: 0, width: width, height: height)
//        let weekRect2 = CGRect(x: 0, y: height * 1 , width: width, height: height)
//        let weekRect3 = CGRect(x: 0, y: height * 2 , width: width, height: height)
//        let weekRect4 = CGRect(x: 0, y: height * 3 , width: width, height: height)
//        let weekRect5 = CGRect(x: 0, y: height * 4 , width: width, height: height)
//        let weekRect6 = CGRect(x: 0, y: height * 5 , width: width, height: height)
//
//
//        var path = UIBezierPath()
//        path.lineWidth = 1.0
//
//        path = UIBezierPath(rect: weekRect1)
//        path.stroke()
//        path = UIBezierPath(rect: weekRect2)
//        path.stroke()
//        path = UIBezierPath(rect: weekRect3)
//        path.stroke()
//        path = UIBezierPath(rect: weekRect4)
//        path.stroke()
//        path = UIBezierPath(rect: weekRect5)
//        path.stroke()
//        path = UIBezierPath(rect: weekRect6)
//        path.stroke()
        
    }
}
