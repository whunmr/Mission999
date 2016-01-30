//
//  GravityTrigger.h
//  findit
//
//  Created by Hongmin Wang on 10/6/15.
//  Copyright © 2015 www.whunmr.com. All rights reserved.
//

#import "common.h"
#import <SpriteKit/SpriteKit.h>

@interface GravityTrigger : SKSpriteNode<SKContactable>
+ (GravityTrigger*)gravityTrigger;
@end
