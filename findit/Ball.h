//
//  Ball.h
//  findit
//
//  Created by Hongmin Wang on 6/14/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface Ball : SKSpriteNode<SKContactable>
+(Ball*)ball:(CGFloat)lifeDuration;
@end
