//
//  Monster.h
//  findit
//
//  Created by Hongmin Wang on 1/8/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface Monster : SKSpriteNode<SKContactable, Hurtable>
+(Monster*)monster;
-(void)update:(CFTimeInterval)currentTime;
@end
