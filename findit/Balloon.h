//
//  Monster.h
//  findit
//
//  Created by Hongmin Wang on 1/8/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface Balloon : SKSpriteNode<SKContactable, Hurtable>
+(Balloon*)balloon;
@end
