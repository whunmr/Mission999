//
//  DeadHero.h
//  findit
//
//  Created by hmwang on 15/11/13.
//  Copyright © 2015年 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface DeadHero : SKSpriteNode<SKContactable>
+ (DeadHero*)dead_hero:(CGPoint)position;
@end
