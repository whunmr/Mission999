//
//  Shield.h
//  findit
//
//  Created by Hongmin Wang on 6/17/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "common.h"

@interface Shield : SKSpriteNode<SKContactable>
+(Shield*)shield:(NSString*)param;
@end
