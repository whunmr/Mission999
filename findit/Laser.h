//
//  Laser.h
//  findit
//
//  Created by Hongmin Wang on 5/30/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface Laser : SKSpriteNode<Updatable>
+(Laser*)laser: (NSString*)param;
-(void)update:(CFTimeInterval)currentTime;
@end
