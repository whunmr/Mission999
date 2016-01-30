//
//  Woodbox.m
//  findit
//
//  Created by Hongmin Wang on 5/15/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "Woodbox.h"
#import "HMHero.h"

@implementation Woodbox

static SKAction* actionFoodStepOnWood;
static SKAction* actionBoxDropOnGround;

+ (void) initialize {
    actionFoodStepOnWood = [SKAction playSoundFileNamed:@"step_on_wood.mp3" waitForCompletion:NO];
    actionBoxDropOnGround = [SKAction playSoundFileNamed:@"box_drop_on_ground.mp3" waitForCompletion:NO];
}

+ (Woodbox*)woodbox {
    Woodbox* bp = [[Woodbox alloc] initWithImageNamed:@"box.png"];
    bp.name = @"box";
    
    bp.physicsBody.dynamic = YES;
    bp.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bp.size];
    bp.physicsBody.categoryBitMask = ground_category;
    bp.physicsBody.collisionBitMask = hero_category | ground_category | monster_category;
    bp.physicsBody.contactTestBitMask = hero_category | ground_category;
    bp.physicsBody.fieldBitMask = 0;
    bp.physicsBody.allowsRotation = NO;
    bp.physicsBody.friction = 0;
    bp.physicsBody.linearDamping = 0.98;
    bp.physicsBody.restitution = 0.0;
    bp.physicsBody.mass = bp.physicsBody.mass * 0.01;
    bp.xScale = bp.yScale = 0.4;
    return bp;
}

- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if ([body.node.name isEqualToString:@"hero"]) {
        if (fabs(contact.contactNormal.dx) < 0.02 &&  fabs(contact.contactNormal.dy) > 0.98) {
            HMHero* h = [HMHero hero];
            if (h.velocity.dy > 40) {
                [self runAction:actionFoodStepOnWood];
            }
            [[HMHero hero] jump_end_on_ground: nil];
            return;
        }
        
        if (fabs(contact.contactNormal.dy) < 0.02 &&  fabs(contact.contactNormal.dx) > 0.98) {
//            NSLog(@"box hit %@", body.node.name);
            self.physicsBody.affectedByGravity = NO;
            [self runAction:actionFoodStepOnWood];
            [self runAction:[SKAction moveByX:0 y:3.5 duration:0.1]];
            //[self.physicsBody applyImpulse:CGVectorMake(contact.contactNormal.dx > 0 ? 0.01 : -0.01, 0.02)];

//            self.physicsBody.affectedByGravity
//            [self.physicsBody applyForce:CGVectorMake(contact.contactNormal.dx * -10000, 0)];
            return;
        }
        return;
    }
    
    if ([body.node.name isEqualToString:@"ground"] || [body.node.name isEqualToString:@"box"]) {
        if (self.physicsBody.velocity.dy > 60)
            [self runAction:actionBoxDropOnGround];
        return;
    }
    
    if ([body.node conformsToProtocol:@protocol(SKContactable)]) {
        [((SKNode<SKContactable> *)body.node) contact_body:self.physicsBody with:contact];
        return;
    }
    //NSLog(@"box hit %@", body.node.name);

    //TODO: add sound
}

-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    self.physicsBody.affectedByGravity = YES;
//    NSLog(@"end contact with: %@", body.node.name);
}

@end
