//
//  common.m
//  findit
//
//  Created by Hongmin Wang on 5/14/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "common.h"

@implementation SKColor(Hexadecimal)
+ (SKColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    
    return [SKColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

+ (SKColor *)randomColor {
    /*NSArray* colors = @[@"#66CCCC",@"#CCFF66",@"#FF99CC",@"#FF9999",@"#FFCC99",@"#FF6666",@"#FFFF66",@"#99CC66",@"#FF9999",@"#99CC33"
                        ,@"#FF9900",@"#FFCC00",@"#FF0033",@"#FF9966",@"#FF9900",@"#CCFF00",@"#CC3399",@"#99CC33",@"#FF6600",@"#993366"
                        ,@"#66CCCC",@"#990066",@"#FFCC00",@"#CC0033",@"#FFCC33",@"#ff0033",@"#ffff00",@"#ff0033"
                        ,@"#006699",@"#ffff33",@"#ffcc00",@"#009999",@"#cc3366",@"#ff0033",@"#cccc00",@"#ff9933",@"#663399",@"#cc3333"
                        ,@"#ffcccc",@"#99cc00",@"#ff6600"];*/
    
    NSArray* colors = @[@"#66CCCC",@"#CCFF66",@"#FF99CC",@"#FF9999",@"#FFCC99",@"#FF6666",@"#FFFF66",@"#99CC66",@"#FF9999",@"#99CC33"
                        ,@"#FF9900",@"#FFCC00",@"#FF9966",@"#FF9900",@"#CCFF00",@"#CC3399",@"#99CC33",@"#FF6600",@"#993366"
                        ,@"#66CCCC",@"#990066",@"#FFCC00",@"#FFCC33",@"#ffff00"
                        ,@"#006699",@"#ffff33",@"#ffcc00",@"#009999",@"#cc3366",@"#cccc00",@"#ff9933",@"#663399",@"#cc3333"
                        ,@"#ffcccc",@"#99cc00",@"#ff6600"];
    
    static u_int32_t random = 0;
    //u_int32_t random = arc4random_uniform([colors count]);
    return [SKColor colorWithHexString: [colors objectAtIndex:random++ % (colors.count)] alpha:1];
}

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation SKAction(EaseInOut)
+ (SKAction *)EaseInOutMoveByX:(CGFloat)deltaX y:(CGFloat)deltaY duration:(NSTimeInterval)sec {
    SKAction* action = [SKAction moveByX:deltaX y:deltaY duration:sec];
    action.timingMode = SKActionTimingEaseInEaseOut;
    return action;
}

+ (SKAction *)EaseInOutRotateByAngle:(CGFloat)radians duration:(NSTimeInterval)sec {
    SKAction* action = [SKAction rotateByAngle:radians duration:sec];
    action.timingMode = SKActionTimingEaseInEaseOut;
    return action;
}

+ (SKAction *)EaseInOutScaleXBy:(CGFloat)xScale y:(CGFloat)yScale duration:(NSTimeInterval)sec {
    SKAction* action = [SKAction scaleXBy:xScale y:yScale duration:sec];
    action.timingMode = SKActionTimingEaseInEaseOut;
    return action;
}


+ (SKAction *)_waitForDuration:(CGFloat)duration {
    if (duration == 0) {
        return [SKAction waitForDuration:0.0001];
    }
    return [SKAction waitForDuration:duration];
}
@end


///////////////////////////////////////////////////////////////////////////////////////////////////
CGFloat DistanceBetweenPoints(CGPoint first, CGPoint second) {
    return hypotf(second.x - first.x, second.y - first.y);
}


CGFloat ValueOfIndexInTextArray(NSArray* arr, int index) {
    if ([arr count] > index) {
        return [[arr objectAtIndex:index] doubleValue];
    }
    
    return 0;
}


CGFloat ValueOfIndexInTextArrayWithDefaultValue(NSArray* arr, int index, CGFloat defaultValue) {
    if ([arr count] > index) {
        return [[arr objectAtIndex:index] doubleValue];
    }
    
    return defaultValue;
}