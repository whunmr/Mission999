//
//  Decoration.m
//  findit
//
//  Created by Hongmin Wang on 6/7/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "Decoration.h"
#import "common.h"

@implementation Decoration
+(Decoration*)decoration: (NSString*)param {
    NSArray* ps = [param componentsSeparatedByString:@"/"];
    NSString* imageName = [NSString stringWithFormat:@"%@.png", [ps objectAtIndex:0]];
    
    Decoration* d = [[Decoration alloc] initWithImageNamed:imageName];
    
    if ([ps count] > 2) {
        d.physicsBody = [SKPhysicsBody bodyWithTexture:[SKTexture textureWithImageNamed:imageName] size:d.size];
        d.physicsBody.categoryBitMask = decoration_category;
        d.physicsBody.collisionBitMask = ground_category;
        d.physicsBody.allowsRotation = NO;
    }
    
    if ([[ps objectAtIndex:0] hasPrefix:@"D"]) {
        d.zPosition = k_hero_zposition - 1;
    } else {
        d.zPosition = k_hero_zposition + 1;
    }
    
    float scale = ValueOfIndexInTextArray(ps, 1);
    if (scale == 0) {
        scale = 0.4;
    }
    
    d.xScale = d.yScale = scale;

    /*d.physicsBody = [SKPhysicsBody bodyWithTexture:[SKTexture textureWithImageNamed:[NSString stringWithFormat:@"%@.png", param]] size:d.size];
    d.physicsBody.categoryBitMask = decoration_category;
    d.physicsBody.collisionBitMask = ground_category;
    d.physicsBody.allowsRotation  = NO;*/

    return d;
}
@end
