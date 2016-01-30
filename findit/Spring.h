//
//  Spring.h
//  findit
//
//  Created by Hongmin Wang on 5/27/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface Spring : SKSpriteNode<SKContactable>
+(Spring*)spring: (NSString*)param;
@end
