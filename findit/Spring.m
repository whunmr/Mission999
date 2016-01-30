//
//  Spring.m
//  findit
//
//  Created by Hongmin Wang on 5/27/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "Spring.h"
#import "HMHero.h"

static SKAction* actionSpringSound;

@interface Spring()
@property CGFloat force_;
@end


@implementation Spring

+(void)initialize {
    actionSpringSound = [SKAction playSoundFileNamed:@"jump1.wav" waitForCompletion:NO];
}

+(Spring*)spring: (NSString*)param {
    
    Spring* s = [[Spring alloc] initWithImageNamed:@"spring.png"];
    
    NSArray* ps = [param componentsSeparatedByString:@"/"];
    s.force_ = 1 + ValueOfIndexInTextArrayWithDefaultValue(ps, 1, 1.0)/2;
    
    s.name = @"ground_spring";

    s.physicsBody.dynamic = YES;
    //s.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:s.size];
    s.physicsBody = [SKPhysicsBody bodyWithTexture:[SKTexture textureWithImageNamed:@"spring.png"] size:s.size];
    s.physicsBody.categoryBitMask = ground_category;
    s.physicsBody.collisionBitMask = hero_category | ground_category | monster_category;
    s.physicsBody.contactTestBitMask = hero_category;
    s.physicsBody.fieldBitMask = 0;
    s.physicsBody.allowsRotation = NO;
    s.physicsBody.friction = 0;
    s.physicsBody.linearDamping = 0.92;
    s.physicsBody.mass = s.physicsBody.mass * 0.05;
    s.xScale = s.yScale = 0.4;
    
    return s;
}

- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if ([body.node.name isEqualToString:@"hero"]) {
        HMHero* h = [HMHero hero];
        
        if (([contact.bodyA.node.name isEqualToString:@"hero"] && contact.contactNormal.dy < -0.9 && fabs(contact.contactNormal.dx) < 0.1)
            || ( [contact.bodyB.node.name isEqualToString:@"hero"] && contact.contactNormal.dy > 0.9 && fabs(contact.contactNormal.dx) < 0.1 ) ){
            [self runAction:actionSpringSound];
            [h jump_end_on_ground: nil];
            [h.physicsBody applyImpulse:CGVectorMake(0, self.force_)];
            return;
        }
        
        return;
    }
    

    NSLog(@"spring hit %@", body.node.name);
}

-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
}
@end
