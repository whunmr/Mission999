//
//  Ball.m
//  findit
//
//  Created by Hongmin Wang on 6/14/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "Ball.h"

@implementation Ball

+(Ball*)ball:(CGFloat)lifeDuration; {
    Ball* b = [[Ball alloc] initWithImageNamed:@"ball1.png"];
    b.physicsBody = [SKPhysicsBody bodyWithTexture:[SKTexture textureWithImageNamed:@"ball1.png"] size:b.size];
    
    b.physicsBody.categoryBitMask = bullet_category;
    b.physicsBody.collisionBitMask = ground_category | hero_category;
    b.physicsBody.contactTestBitMask = hero_category | monster_category | balloon_category;
    b.physicsBody.fieldBitMask = 0;
    b.physicsBody.affectedByGravity = NO;
    b.physicsBody.restitution = 1;
    b.physicsBody.allowsRotation = YES;
    b.xScale = b.yScale = 0.15;
    
    [b runAction:
         [SKAction group:@[
                           [SKAction sequence:@[[SKAction _waitForDuration:lifeDuration],[SKAction removeFromParent]]],
                           [SKAction repeatActionForever:  [SKAction rotateByAngle:D_2_R(360) duration:3]]
                           ]]

     ];
    
    return b;
}

- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if ([body.node conformsToProtocol:@protocol(Hurtable)]) {
        [(SKNode<Hurtable>*)body.node hurtby:self with:1];
        [self removeFromParent];
        return;
    }

    //NSLog(@"bullet hit %@", body.node.name);
    //[self removeFromParent];
}

-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
}

@end
