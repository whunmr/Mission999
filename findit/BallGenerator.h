//
//  BallGenerator.h
//  findit
//
//  Created by Hongmin Wang on 6/14/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface BallGenerator : SKSpriteNode
+(BallGenerator*)ballGenerator:(NSString*)param atPos:(CGPoint)pos parent:(SKNode*)parent;
@end
