//
//  TESTViewController.swift
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 8/9/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.
//

import UIKit

class TESTViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // createa a circular view / or a view with a circular layer
        
        view.backgroundColor = UIColor.whiteColor()

        
//        let bezierPath = UIBezierPath()
//        bezierPath.addArcWithCenter(view.center, radius: CGFloat(50.0), startAngle:CGFloat(0.0), endAngle: CGFloat (2 * M_PI), clockwise: true)
//        
//        let textLayer = CAShapeLayer()
//        textLayer.path = bezierPath.CGPath
//        textLayer.strokeColor = UIColor.orangeColor().CGColor
//        textLayer.fillColor = UIColor.greenColor().CGColor
//        textLayer.lineWidth = 2.0
//        
//        let drawer = TextDrawer()
//        let asdf = NSAttributedString(string: "asdfasdf asdfasdfsadf")
//        
//        view.layer.addSublayer(textLayer)
//        
//        drawer.drawCurvedStringOnLayer(view.layer, withAttributedText: asdf, atAngle: 25, withRadius: 50)
        
//        CAShapeLayer *progressLayer = [[CAShapeLayer alloc] init];
//        [progressLayer setPath:bezierPath.CGPath];
//        [progressLayer setStrokeColor:[UIColor colorWithWhite:1.0 alpha:0.2].CGColor];
//        [progressLayer setFillColor:[UIColor clearColor].CGColor];
//        [progressLayer setLineWidth:0.3 * self.bounds.size.width];
//        [progressLayer setStrokeEnd:volume/100];
//        [_circleView.layer addSublayer:progressLayer];
        
//        UIBezierPath *bezierPath = [UIBezierPath bezierPath];
//        [bezierPath addArcWithCenter:textView.f radius:50 startAngle:0 endAngle:2 * M_PI clockwise:YES];
        
        // call the layer function in its layer
        
//        let ct = CircleView(frame: view.frame)
//        ct.setRadius(50)
//        ct.setStartingAngle(180)
//        ct.setColor(UIColor.whiteColor())
//        ct.setString("asdfasdf asdfasdfasdf")
//        view.addSubview(ct)

//        let ct = CurvyTextView()
//        ct.frame = view.frame
//        ct.attributedString = NSAttributedString(string: "asdfasdf asdfasdfasdf")
//        view.addSubview(ct)
        
        let coreT = CoreTextArcView()
        coreT.backgroundColor = UIColor.orangeColor()
        coreT.frame = CGRectMake(100, 100, 200, 200)
        coreT.font = UIFont(name: "Helvetica", size: 10)
        
        let drawer = TextDrawer()
        var inReverse = ""
        
        for letter in "kv.taniguchi@gmail.com" {
            inReverse = "\(letter)" + inReverse
        }
        
        coreT.text = inReverse
        coreT.radius = 50
        coreT.arcSize = 180
        coreT.shiftV = -10
        view.addSubview(coreT)
    }
}
