//
//  BulletPack.h
//  findit
//
//  Created by Hongmin Wang on 5/5/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface BulletPack : SKSpriteNode<SKContactable>
+(BulletPack*)bulletPack;
@end
