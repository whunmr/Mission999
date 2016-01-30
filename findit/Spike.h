//
//  Spike.h
//  findit
//
//  Created by Hongmin Wang on 5/28/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface Spike : SKSpriteNode<SKContactable>
+(Spike*)spike:(NSString*)param;
@end
