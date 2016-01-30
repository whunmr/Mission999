//
//  Cannon.h
//  findit
//
//  Created by Hongmin Wang on 6/7/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface Cannon : SKSpriteNode<Updatable>
+(Cannon*)cannon: (NSString*)param;
-(void)update:(CFTimeInterval)currentTime;
@end
