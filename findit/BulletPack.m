//
//  BulletPack.m
//  findit
//
//  Created by Hongmin Wang on 5/5/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "BulletPack.h"
#import "HMHero.h"

@implementation BulletPack
static SKAction* add_bullets_sound;

+(BulletPack*)bulletPack {
    BulletPack* bp = [[BulletPack alloc] initWithImageNamed:@"bullet_pack.png"];
    bp.name = @"star";
    bp.physicsBody.dynamic = YES;
    bp.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(85, 85)];
    bp.physicsBody.categoryBitMask = star_category;
    bp.physicsBody.collisionBitMask = star_category | ground_category;
    bp.physicsBody.contactTestBitMask = hero_category;
    bp.physicsBody.fieldBitMask = 0;
    bp.physicsBody.allowsRotation = NO;
    
    //SKEmitterNode* star = [SKEmitterNode nodeWithFileNamed:@"monster_fire.sks"];
    bp.xScale = bp.yScale = 0.2;
    //[bp addChild:star];
    
    return bp;
}

- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if (add_bullets_sound == nil) {
        add_bullets_sound = [SKAction playSoundFileNamed:@"add_bullets.mp3" waitForCompletion:YES];
    }
    
    if ([body.node.name isEqualToString:@"hero"]) {
        [[HMHero hero] add_bullet:10];
        [[HMHero hero] runAction:add_bullets_sound];
        [self removeFromParent];
        return;
    }
    
    NSLog(@"bulletpack hit %@", body.node.name);
}

-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
}
@end
