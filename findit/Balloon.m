//
//  Balloon.m
//  findit
//
//  Created by Hongmin Wang on 9/29/15.
//  Copyright © 2015 www.whunmr.com. All rights reserved.
//

#import "Balloon.h"
#import "HMHero.h"

@implementation Balloon

static SKAction* popSound;
static HMHero* h;

+ (void) initialize {
    popSound = [SKAction playSoundFileNamed:@"balloon_pop.mp3" waitForCompletion:NO];
}

+(Balloon*)balloon {
    Balloon* s = [[Balloon alloc] initWithImageNamed:@"balloon.png"];
    s.name = @"balloon";
    s.xScale = s.yScale = 0.4;
    
    s.physicsBody = [SKPhysicsBody bodyWithTexture:[SKTexture textureWithImageNamed:@"balloon.png"]
                                                    size:s.size];
    HMHero* h = [HMHero hero];
    s.physicsBody.mass = h.physicsBody.mass;
    
    s.physicsBody.dynamic = NO;
    s.physicsBody.categoryBitMask = balloon_category;
    s.physicsBody.collisionBitMask = hero_category | spikes_category | ground_category;
    s.physicsBody.contactTestBitMask = hero_category | ground_category;
    s.physicsBody.fieldBitMask = balloon_category;
    s.physicsBody.allowsRotation = NO;
    s.physicsBody.restitution = 0;
    
    [s runAction:[SKAction colorizeWithColor:[SKColor randomColor] colorBlendFactor:0.9 duration:0.1]];
    
    return s;
}

-(void)hurtby:(SKSpriteNode*)hurtSource with:(int)hurt {
    [self.parent runAction:popSound];
    
    NSArray<SKPhysicsJoint*>* joints = self.physicsBody.joints;
    for (SKPhysicsJoint* j in joints) {
        [self.parent.scene.physicsWorld removeJoint:j];
    }
    
    [self removeFromParent];
}

- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if ([body.node.name isEqualToString:@"hero"]) {
        HMHero* h = [HMHero hero];
        h.zRotation = 0;
        
        NSArray<SKPhysicsJoint*>* jarr = [h.physicsBody joints];
        if ([jarr count] > 0) {
            return;
        }
        
        CGPoint hero_position = [self.parent.scene convertPoint:h.position fromNode:self.parent];
        
        self.position = CGPointMake(h.position.x, h.position.y + self.size.height/2 + 5);
        
        SKPhysicsJointFixed* joint = [SKPhysicsJointFixed jointWithBodyA:self.physicsBody
                                                                   bodyB:h.physicsBody
                                                                  anchor:hero_position];
        [self.parent.scene.physicsWorld addJoint:joint];
        
        self.physicsBody.dynamic = YES;
        return;
    }
    
    if ([body.node conformsToProtocol:@protocol(SKContactable)]) {
        [((SKNode<SKContactable> *)body.node) contact_body:self.physicsBody with:contact];
        return;
    }
    
    //NSLog(@"balloon hit %@", body.node.name);
}


-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if ([body.node.name isEqualToString:@"hero"]) {
        return;
    }
    
    if ([body.node conformsToProtocol:@protocol(SKContactable)]) {
        [((SKNode<SKContactable> *)body.node) end_contact:self.physicsBody with:contact];
        return;
    }
}


@end
