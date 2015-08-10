//
//  TextDrawer.h
//  TiperKeyboard2
//
//  Created by Kevin Taniguchi on 8/9/15.
//  Copyright (c) 2015 Kevin Taniguchi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TextDrawer : NSObject

- (void)drawCurvedStringOnLayer:(CALayer *)layer withAttributedText:(NSAttributedString *)text atAngle:(CGFloat)angle withRadius:(CGFloat)radius;

@end
