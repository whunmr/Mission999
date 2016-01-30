//
//  Spike.m
//  findit
//
//  Created by Hongmin Wang on 5/28/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//

#import "Spike.h"
#import "HMHero.h"

@implementation Spike

+(Spike*)spike:(NSString*)param {
    NSString* img = @"spikes.png";
    if ([param hasPrefix:@"s1"]) {
        img = @"spikes2.png";
    }
    
    Spike* s = [[Spike alloc] initWithImageNamed:img];
    s.name = @"spikes";
    
    s.physicsBody = [SKPhysicsBody bodyWithTexture:[SKTexture textureWithImageNamed:img] size:s.size];
    s.physicsBody.dynamic = NO;
    s.physicsBody.categoryBitMask = spikes_category;
    s.physicsBody.collisionBitMask = hero_category | monster_category | ground_category;
    s.physicsBody.contactTestBitMask = hero_category | monster_category | balloon_category;
    s.physicsBody.fieldBitMask = 0;
    s.xScale = s.yScale = 0.4;
    
    [s runAction:[SKAction repeatActionForever:[SKAction rotateByAngle:-M_PI duration:2]]];
    
    NSArray* ps = [param componentsSeparatedByString:@"/"];
    if ([ps count] >= 4) {
        CGFloat x_move = [[ps objectAtIndex:1] doubleValue];
        CGFloat y_move = [[ps objectAtIndex:2] doubleValue];
        CGFloat move_duration = [[ps objectAtIndex:3] doubleValue];
        
        CGFloat initalWaitDuration = 0;
        if ([ps count] >=5 ) {
            initalWaitDuration = [[ps objectAtIndex:4] doubleValue];
        }
        
        //NSLog(@"x/y/move_duration: %f/%f/%f", x_move, y_move, move_duration);
        //[self apply_random_special_texture_to_moveable_block: customized_wall_texture];
        [s runAction:
         [SKAction sequence:@[
                              [SKAction _waitForDuration:initalWaitDuration],
                              [SKAction repeatActionForever:
                               [SKAction sequence:@[
                                                    [SKAction EaseInOutMoveByX:x_move y:y_move duration:move_duration],
                                                    [SKAction EaseInOutMoveByX:-x_move y:-y_move duration:move_duration]
                                                    ]]]
                              ]]
         ];
    }
    
    return s;
}


- (void)contact_body:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
    if ([body.node conformsToProtocol:@protocol(Hurtable)]) {
        return [((SKNode<Hurtable> *)body.node) hurtby:self with:1];
    }
    
    /*if ([body.node.name isEqualToString:@"hero"]) {
        HMHero* h = [HMHero hero];
        
        if (([contact.bodyA.node.name isEqualToString:@"hero"] && contact.contactNormal.dy < -0.001)
            ||  ([contact.bodyB.node.name isEqualToString:@"hero"] && contact.contactNormal.dy > 0.001) ) {
            
            [self runAction:actionSpringSound];
            [h jump_end_on_ground];
            [h.physicsBody applyImpulse:CGVectorMake(0, 2)];
            return;
        }
        
        [h hurtby:self with:1];
        return;
    }*/
    
    
    NSLog(@"spike hit %@", body.node.name); //TODO: hurt monster.
}

-(void)end_contact:(SKPhysicsBody *)body with:(SKPhysicsContact *)contact {
}

@end
