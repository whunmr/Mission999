//
//  Bomb.h
//  findit
//
//  Created by Hongmin Wang on 5/13/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface Bomb : SKSpriteNode<SKContactable, Hurtable>
+(Bomb*)bomb;
@end
