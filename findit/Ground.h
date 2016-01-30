//
//  Ground.h
//  findit
//
//  Created by Hongmin Wang on 5/3/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface Ground : SKSpriteNode<SKContactable, Customizeable>
+(Ground*)newGroundBlock:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h r:(CGFloat)r c:(SKColor*)c fill_flag:(NSString*)fill_flag;

-(void)final_colorize;

@property BOOL isGlass;
@property BOOL isSand;
@property BOOL isStepDownable;
@property BOOL isSticky;
@property BOOL isStaticSpikes;
@property BOOL isBombable;
@property BOOL isSpikeAround;
@property BOOL isDynamicBlock;

@end
