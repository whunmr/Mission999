//
//  Shield.m
//  findit
//
//  Created by Hongmin Wang on 6/17/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "Shield.h"
#import "HMHero.h"

@implementation Shield

+(Shield*)shield:(NSString*)param {
    Shield* s = [[Shield alloc] initWithImageNamed:[NSString stringWithFormat:@"shield%@.png", [param substringFromIndex:2]]];
    
//    SKEmitterNode* effects = [SKEmitterNode nodeWithFileNamed:@"shield.sks"];
//    effects.xScale = effects.yScale = 0.2;
//    effects.zPosition = s.zPosition + 1;
//    [s addChild:effects];
    
    s.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:s.size];
    s.physicsBody.categoryBitMask = ground_category;
    s.physicsBody.collisionBitMask = 0;
    s.physicsBody.affectedByGravity = NO;
    s.physicsBody.contactTestBitMask = hero_category;
    s.physicsBody.fieldBitMask = 0;
    s.xScale = s.yScale = 0.4;
    s.physicsBody.mass = s.physicsBody.mass * 0.01;
    return s;
}

- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *) contact {
    self.blendMode = SKBlendModeAlpha;
    self.colorBlendFactor = 0.2;
    HMHero* h = [HMHero hero];
    self.zPosition = h.zPosition - 1;
    [h addShield:self];
}

-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
}

@end
