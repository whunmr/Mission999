//
//  Bullet.m
//  findit
//
//  Created by Hongmin Wang on 5/5/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet

+(Bullet*)bullet {
    Bullet* bullet = [[Bullet alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(4, 2)];
    
    bullet.name = @"bullet";
    bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize: bullet.size];
    bullet.physicsBody.dynamic = YES;
    bullet.physicsBody.affectedByGravity = NO;
    bullet.physicsBody.categoryBitMask = bullet_category;
    bullet.physicsBody.collisionBitMask = monster_category | ground_category;
    bullet.physicsBody.contactTestBitMask = monster_category |  ground_category | hero_category | balloon_category;
    bullet.physicsBody.fieldBitMask = 0;
    bullet.physicsBody.usesPreciseCollisionDetection = true;
    return bullet;
}

- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if ([body.node.name isEqualToString:@"ground"]) {
        [self removeFromParent];
        return;
    }
    
    if ([body.node conformsToProtocol:@protocol(Hurtable)]) {
        [(SKNode<Hurtable>*)body.node hurtby:self with:1];
        [self removeFromParent];
        return;
    }
    
    /*if ([body.node conformsToProtocol:@protocol(SKContactable)]) {
        [((SKNode<SKContactable> *)body.node) contact_body:self.physicsBody with:contact];
        return;
    }*/
    
    NSLog(@"bullet hit %@", body.node.name);
    [self removeFromParent];
}

-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
}

@end
