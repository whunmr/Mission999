//
//  Laser.h
//  findit
//
//  Created by Hongmin Wang on 5/30/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface LaserX : SKSpriteNode<Updatable>
+(LaserX*)laserX: (NSString*)param;
-(void)update:(CFTimeInterval)currentTime;
@end
