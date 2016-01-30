//
//  GravityTrigger.m
//  findit
//
//  Created by Hongmin Wang on 10/6/15.
//  Copyright © 2015 www.whunmr.com. All rights reserved.
//

#import "GravityTrigger.h"

@implementation GravityTrigger

+ (GravityTrigger*)gravityTrigger {
    GravityTrigger* gt = [[GravityTrigger alloc] initWithImageNamed:@"gravity.png"];

    gt.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:gt.size];
    gt.physicsBody.allowsRotation = NO;
    gt.physicsBody.dynamic = NO;
    
    gt.physicsBody.categoryBitMask = key_category;
    gt.physicsBody.collisionBitMask = key_category | ground_category;
    gt.physicsBody.contactTestBitMask = hero_category;
    gt.physicsBody.fieldBitMask = 0;
    
    gt.xScale = gt.yScale = 0.5;
    
    SKEmitterNode* e = [SKEmitterNode nodeWithFileNamed:@"magic_ball.sks"];
    [gt addChild:e];
    
    return gt;
}

/////////////////////////////////////////////////////////////////////////////////
- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    self.physicsBody.contactTestBitMask = 0;
    self.parent.scene.physicsWorld.gravity = CGVectorMake(self.parent.scene.physicsWorld.gravity.dx, self.parent.scene.physicsWorld.gravity.dy * -1);
    
    [self runAction:
        [SKAction sequence:
            @[
                [SKAction waitForDuration:1]
              , [SKAction runBlock:^{self.physicsBody.contactTestBitMask = hero_category; }]
            ]
        ]
     ];
}

-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
}

@end
