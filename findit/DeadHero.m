//
//  DeadHero.m
//  findit
//
//  Created by hmwang on 15/11/13.
//  Copyright © 2015年 www.whunmr.com. All rights reserved.
//

#import "DeadHero.h"

@implementation DeadHero

static SKAction* meet_dead_hero_sound;

+(void)initialize {
    meet_dead_hero_sound = [SKAction playSoundFileNamed:@"sound/meet_dead_hero.mp3" waitForCompletion:NO];
}

+ (DeadHero*)dead_hero:(CGPoint)position {
    DeadHero* bp = [[DeadHero alloc] initWithImageNamed:@"deadhero.png"];
    bp.name = @"DH";
    bp.position = position;
    bp.xScale = bp.yScale = 0.5;
    
    bp.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bp.size];
    bp.physicsBody.dynamic = YES;
    bp.physicsBody.affectedByGravity = NO;
    bp.physicsBody.categoryBitMask = heart_category;
    bp.physicsBody.collisionBitMask = 0;
    bp.physicsBody.contactTestBitMask = hero_category;
    bp.physicsBody.fieldBitMask = 0;
    bp.physicsBody.allowsRotation = NO;
    
    bp.zRotation = ((float)rand() / RAND_MAX) * 3.14;
    bp.alpha = 0.3;
    
    
    CGFloat randomDelay = ((float)rand() / RAND_MAX);
    
    [bp runAction:[SKAction repeatActionForever:
                   [SKAction sequence:@[
                                     [SKAction waitForDuration:randomDelay],
                                     [SKAction fadeAlphaBy:0.5 duration:2],
                                     [SKAction fadeAlphaBy:-0.5 duration:2]
                                     ]]]];
    
    return bp;
}

- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if ([body.node.name isEqualToString:@"hero"]) {
        [self runAction:meet_dead_hero_sound];
    }
}

-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
}

@end
