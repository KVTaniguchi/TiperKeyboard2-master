//
//  TextDrawer.m
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 8/9/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.
//

#import "TextDrawer.h"

/** Degrees to Radian **/
#define degreesToRadians(degrees) (( degrees ) / 180.0 * M_PI )

/** Radians to Degrees **/
#define radiansToDegrees(radians) (( radians ) * ( 180.0 / M_PI ) )

@implementation TextDrawer

- (void)drawCurvedStringOnLayer:(CALayer *)layer withAttributedText:(NSAttributedString *)text atAngle:(CGFloat)angle withRadius:(CGFloat)radius {
    // angle in radians
    
    CGSize textSize = CGRectIntegral([text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                        options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                        context:nil]).size;
    
    float perimeter = 2 * M_PI * radius;
    float textAngle = (textSize.width / perimeter * 2 * M_PI);
    
    float textRotation;
    float textDirection;
    if (angle > degreesToRadians(10) && angle < degreesToRadians(170))
    {
        //bottom string
        textRotation = 0.5 * M_PI ;
        textDirection = - 2 * M_PI;
        angle += textAngle / 2;
    }
    else
    {
        //top string
        textRotation = 1.5 * M_PI ;
        textDirection = 2 * M_PI;
        angle -= textAngle / 2;
    }
    
    for (int c = 0; c < text.length; c++)
    {
        NSRange range = {c, 1};
        NSAttributedString* letter = [text attributedSubstringFromRange:range];
        CGSize charSize = CGRectIntegral([letter boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                              context:nil]).size;
        
        float letterAngle = ( (charSize.width / perimeter) * textDirection );
        
        float x = radius * cos(angle + (letterAngle/2));
        float y = radius * sin(angle + (letterAngle/2));
        
        //NSLog(@"Char %@ with size: %f x %f", letter, charSize.width, charSize.height);
        //NSLog(@"Char %@ with angle: %f x: %f y: %f", letter, angle, x, y);
        
        CATextLayer *singleChar = [self drawTextOnLayer:layer
                                               withText:letter
                                                  frame:CGRectMake(layer.frame.size.width/2 - charSize.width/2 + x,
                                                                   layer.frame.size.height/2 - charSize.height/2 + y,
                                                                   charSize.width, charSize.height)
                                                bgColor:nil
                                                opacity:1];
        
        singleChar.transform = CATransform3DMakeAffineTransform( CGAffineTransformMakeRotation(angle - textRotation) );
        
        angle += letterAngle;
    }
}


- (CATextLayer *)drawTextOnLayer:(CALayer *)layer
                        withText:(NSAttributedString *)text
                           frame:(CGRect)frame
                         bgColor:(UIColor *)bgColor
                         opacity:(float)opacity {
    
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    [textLayer setFrame:frame];
    [textLayer setString:text];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setBackgroundColor:bgColor.CGColor];
    [textLayer setContentsScale:[UIScreen mainScreen].scale];
    [textLayer setOpacity:opacity];
    [layer addSublayer:textLayer];
    return textLayer;
}

@end
