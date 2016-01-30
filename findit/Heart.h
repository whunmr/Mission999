//
//  Heart.h
//  findit
//
//  Created by Hongmin Wang on 5/11/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface Heart : SKSpriteNode<SKContactable>
+ (Heart*)new_heart:(CGPoint)position;
+ (Heart*)new_disapearable_heart:(CGPoint)position;
@end
