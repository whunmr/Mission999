//
//  GameScene.m
//  findit
//
//  Created by Hongmin Wang on 1/3/15.
//  Copyright (c) 2015 www.whunmr.com. All rights reserved.
//TODO: maybe add an control to open menu page, contains such as "mute sound" "restart level" "quit level"
//TODO: change or move background, according acceleromter, to produce the lookthrough effects.
        //or add different layer of colors to seems like background is forest.
//TODO: add trnas-portals to move player from one place to another
//TODO: to add some stars in the background
//TODO: add moving parts like fire snow in the background
//TODO: make light in different places, with different light luming.
//TODO: to add more effects by using physics simulation, such as chain of things, rotate things.
//TODO: [effects] show the reward balls like green sprites flying towards our hero, after our hero kill the monster.
//TODO: [gaming]  add blood bar to hero. in the top-left of the screen.
//TODO: [effects] add smoke effects in the background.
//TODO: [effects] change color of wall after shot by gun.
//TODO: [effects] add flying sparks like fly-bugs.
//TODO: [effects] to add effects like gems
//TODO: [event] trigger events by hero position. such as: when hero approaches a point, a new monster should be generated.
//TODO: [gaming] monster become more active when hero is near.
//TODO: [gaming] add special elements that constantly generate monster around.
//TODO: [effects] add random wall textures.
//TODO: [music] toggle and switch background music like GTA.
//TODO: [bug] when playing, then put background, then bring-fore_ground, then crash.
//TODO: [game] add save-point, after game restart, keep game state to last save-point.
//TODO: bullet hit bullet_pack, bullet_pack explosition with sound, and hurt monster and hero around, and with explosion emittions. fire and smokes.
//TODO: springs to push hero to very high place, the springs can be moved by hero.

#import "GameScene.h"
#import "SelectLevelScene.h"
#import "HMHero.h"
#import "common.h"
#import "Monster.h"
@import AVFoundation;
#import "TFHpple.h"
#import "Ground.h"
#import "BulletPack.h"
#import "LevelEntry.h"
#import "Heart.h" //随机掉落系统
#import "Bomb.h"
#import "Woodbox.h"
#import "Key.h"
#import "Spring.h"
#import "Spike.h"
#import "Laser.h"
#import "LaserX.h"
#import "Cannon.h"
#import "Decoration.h"
#import "BallGenerator.h"
#import "Shield.h"
#import "Text.h"
#import "BLWebSocketsServer/BLWebSocketsServer.h"
#import "Balloon.h"
#import "GravityTrigger.h"
#import "DeadHero.h"

@interface GameScene()
@property HMHero* hero;
@end

@implementation GameScene
{
    SKNode* world;
    CFTimeInterval lastUpdateTimeInterval;
    AVAudioPlayer* musicPlayer;
    AVAudioPlayer* game_end_player;
    AVAudioPlayer* game_victory_player;
    
    SKNode* control_layer;
    SKSpriteNode* left;
    SKSpriteNode* right;
    SKSpriteNode* jump_button;
    SKSpriteNode* fire;
    SKSpriteNode* reload;
    
    SKLabelNode* bullet_count_label;
    
    SKSpriteNode* health_icon;
    SKLabelNode* health_value_label;
    
    SKSpriteNode* bullet_icon;
    SKLabelNode* bullet_icon_label;
    
    SKLabelNode* game_over_label;
    
    
    NSArray* walls;
    
    NSString* currentLevel;
    
    CGFloat svg_height;
    
    CGFloat buttonPressedAlpha;
    CGFloat buttonUnpressedAlpha;
    
    NSMutableArray* updatableList;
    NSMutableArray* monsterList;
    
    NSMutableDictionary *dead_heros_dict;
}

static SKAction* actionEnterNextLevelSound;
static SKEmitterNode* backgoundStars;

static SKAction* play_back_to_select_level_sound_action;

+ (void)initialize {
    actionEnterNextLevelSound = [SKAction playSoundFileNamed:@"victory2.mp3" waitForCompletion:NO];
    play_back_to_select_level_sound_action = [SKAction playSoundFileNamed:@"back_to_select_level.mp3" waitForCompletion:NO];
//    backgoundStars = [SKEmitterNode nodeWithFileNamed:@"background_stars.sks"];
//    backgoundStars.name = @"background";
//    backgoundStars.zPosition = -999;
}

static GameScene *sharedInstance = nil;
+ (GameScene *)sharedInstance {
    return sharedInstance;
}

- (id)initWithSize:(CGSize)size {
    self = [super initWithSize:size];
    self.scaleMode = SKSceneScaleModeAspectFill;
    sharedInstance = self;
    return self;
}


/*-------------------------------------------------------------------------------*/
//add game contorl
/*-------------------------------------------------------------------------------*/
-(void)button_pressed:(SKSpriteNode*)button {
    button.alpha = buttonPressedAlpha;
}

-(void)button_unpressed:(SKSpriteNode*)button {
    button.alpha = buttonUnpressedAlpha;
}

static const CGFloat control_scale = 0.5;

/*-------------------------------------------------------------------------------*/
//scene edit tools
/*-------------------------------------------------------------------------------*/
-(void)addControlPad {
    left = [SKSpriteNode spriteNodeWithImageNamed:@"left.png"];
    left.blendMode = SKBlendModeAlpha;
    left.name = @"left";
    left.xScale = left.yScale = control_scale * 0.9;
    left.position = CGPointMake(0, 0); /*CGPointMake(-self.view.frame.size.width/2 + left.size.width/2 - 10
                                , -self.view.frame.size.height/2 + left.size.width/2 - 10);*/
    left.zPosition = 2001;
    
    SKSpriteNode* leftWrapper = [[SKSpriteNode alloc] initWithColor:[SKColor clearColor] size:CGSizeMake(105, 320)];
    leftWrapper.name = @"left";
    leftWrapper.zPosition = 2000;
    leftWrapper.position = CGPointMake(-self.view.frame.size.width/2 + left.size.width/2 - 10
                                       , -self.view.frame.size.height/2 + left.size.width/2 - 10);
    [leftWrapper addChild:left];
    [control_layer addChild:leftWrapper];
    
    right = [SKSpriteNode spriteNodeWithImageNamed:@"right.png"];
    right.name = @"right";
    right.blendMode = SKBlendModeAlpha;
    right.xScale = right.yScale = control_scale * 0.9;
    right.position = CGPointMake(0, 0);/*CGPointMake(left.position.x + right.size.width/2 + 40, left.position.y);*/
    right.zPosition = 2001;
    
    SKSpriteNode* rightWrapper = [[SKSpriteNode alloc] initWithColor:[SKColor clearColor] size:CGSizeMake(105, 320)];
    rightWrapper.name = @"right";
    rightWrapper.zPosition = 2000;
    rightWrapper.position = CGPointMake(leftWrapper.position.x + right.size.width/2 + 40, leftWrapper.position.y - 5);
    [rightWrapper addChild:right];
    [control_layer addChild:rightWrapper];
    
    jump_button = [SKSpriteNode spriteNodeWithImageNamed:@"jump.png"];
    jump_button.blendMode = SKBlendModeAlpha;
    jump_button.xScale = jump_button.yScale = control_scale;
    jump_button.position = CGPointMake(0, 0);
    /*CGPointMake(self.view.frame.size.width/2 - jump_button.size.width/2 + 10
                                       , -self.view.frame.size.height/2 + jump_button.size.height/2 - 10);*/
    jump_button.name = @"jump";
    jump_button.zPosition = 2001;

    SKSpriteNode* jumpWrapper = [[SKSpriteNode alloc] initWithColor:[SKColor clearColor] size:CGSizeMake(150, 320)];
    jumpWrapper.position = CGPointMake(self.view.frame.size.width/2 - jump_button.size.width/2 + 10
                                       , -self.view.frame.size.height/2 + jump_button.size.height/2 - 10 - 15);
    jumpWrapper.zPosition = 2000;
    jumpWrapper.name = @"jump";
    [jumpWrapper addChild:jump_button];
    [control_layer addChild:jumpWrapper];
    
    /*fire = [SKSpriteNode spriteNodeWithImageNamed:@"fire.png"];
    fire.blendMode = SKBlendModeAlpha;
    fire.alpha = 0.1f;
    fire.xScale = fire.yScale = control_scale;
    fire.anchorPoint = CGPointMake(0.5, 0.45);
    fire.position = CGPointMake(jump_button.position.x - fire.size.width + 20
                                       , jump_button.position.y);
    fire.name = @"fire";
    fire.zPosition = 2000;
    [control_layer addChild:fire];*/
    

    reload = [SKSpriteNode spriteNodeWithImageNamed:@"reload.png"];
    reload.blendMode = SKBlendModeAlpha;
    reload.alpha = 0.1f;
    reload.xScale = reload.yScale = control_scale;
    reload.anchorPoint = CGPointMake(0.5, 0.5);
    reload.position = CGPointMake(self.view.frame.size.width/2 - reload.size.width/2, self.view.frame.size.height/2 - reload.size.height/2);
    reload.name = @"reload";
    reload.zPosition = 2000;
    [control_layer addChild:reload];

    
    /*bullet_count_label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
    bullet_count_label.name = @"bullet_count";
    bullet_count_label.color = [SKColor orangeColor];
    bullet_count_label.colorBlendFactor = 1.0f;
    bullet_count_label.fontSize = 40;
    bullet_count_label.text = @"5";
    bullet_count_label.alpha = 0.3f;
    bullet_count_label.xScale = bullet_count_label.yScale = control_scale;
    bullet_count_label.position = fire.position;
    bullet_count_label.zPosition = 2000 - 1;
    [control_layer addChild:bullet_count_label];*/
    
    health_icon = [SKSpriteNode spriteNodeWithImageNamed:@"heart_icon.jpg"];
    health_icon.xScale = health_icon.yScale = control_scale * 0.3;
    //health_icon.alpha = 0.7;
    health_icon.anchorPoint = CGPointMake(0.5, 0.5);
    health_icon.position = CGPointMake(-self.view.frame.size.width/2 + health_icon.size.width/2, self.view.frame.size.height/2 - health_icon.size.height/2 - 3);
    health_icon.zPosition = 2000;
    health_icon.color = [SKColor orangeColor];
    health_icon.colorBlendFactor = 0.9;
    [control_layer addChild:health_icon];
    
    health_value_label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE"];
    health_value_label.fontSize = 14;
    health_value_label.text = @"";
//    health_value_label.alpha = 0.7;
    health_value_label.zPosition = 2000;
    health_value_label.fontColor = [SKColor orangeColor];
    health_value_label.position = CGPointMake(health_icon.position.x + health_icon.size.width/2 + 8, health_icon.position.y - 6);
    [control_layer addChild:health_value_label];
    
    bullet_icon = [SKSpriteNode spriteNodeWithImageNamed:@"key.png"];
    bullet_icon.xScale = bullet_icon.yScale = control_scale * 0.26;
//    bullet_icon.alpha = 0.7;
    bullet_icon.anchorPoint = CGPointMake(0.5, 0.5);
    bullet_icon.color = [SKColor orangeColor];
    bullet_icon.colorBlendFactor = 0.9;
    bullet_icon.position = CGPointMake(-self.view.frame.size.width/2 + bullet_icon.size.width/2, health_icon.position.y - health_icon.size.height/2 - 8);
    bullet_icon.zPosition = 2000;
    [control_layer addChild:bullet_icon];
    
    bullet_icon_label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE"];
    bullet_icon_label.fontSize = 14;
    bullet_icon_label.text = @" 0/0";
//    bullet_icon_label.alpha = 0.7;
    bullet_icon_label.zPosition = 2000;
    bullet_icon_label.fontColor = [SKColor orangeColor];
    bullet_icon_label.position = CGPointMake(health_value_label.position.x + 7, bullet_icon.position.y - 6);
    [control_layer addChild:bullet_icon_label];
}

- (void)add_ground_on_x:(CGFloat)x y:(CGFloat)y w:(CGFloat)w h:(CGFloat)h r:(CGFloat)r fill_flag:(NSString*)fill_flag{
    SKColor* c = [SKColor randomColor];
    [world addChild:[Ground newGroundBlock:x y:y w:w h:h r:r c:c fill_flag:fill_flag]];
}

-(void)reset_hero_position___and___add_monster_from_level_file:(NSString*)level_file_name {
    self.physicsWorld.gravity = CGVectorMake(self.physicsWorld.gravity.dx, self.physicsWorld.gravity.dy *  (self.physicsWorld.gravity.dy < 0 ? 1 : -1));
    
    NSData  * data      = [NSData dataWithContentsOfFile:level_file_name];    
    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
    NSArray * textes  = [doc searchWithXPathQuery:@"//text"];
    
    int key_count = 0;
    
    updatableList = [[NSMutableArray alloc] init];
    monsterList   = [[NSMutableArray alloc] init];
    
        vector_float3 vec;
        vec[0] = 0;
        vec[1] = 7;
        SKFieldNode*  upGravityFieldNode = [SKFieldNode linearGravityFieldWithVector:vec];
        upGravityFieldNode.categoryBitMask = balloon_category;
        //upGravityFieldNode.falloff = 0.99;
        //upGravityFieldNode.region = [[SKRegion alloc ]initWithRadius:500];
        upGravityFieldNode.position = CGPointMake(0, 0);
        [self.world addChild:upGravityFieldNode];
    
    for (TFHppleElement* text in textes) {
        NSDictionary* attrs = [text attributes];
        
        CGFloat x = [attrs[@"x"] floatValue];
        CGFloat y = [attrs[@"y"] floatValue];
        
        x = x;
        y = svg_height - y;
        
        if ([[text content] length] == 0)
            continue;
        
        CGPoint pos = CGPointMake(x, y);
        
        if ([[text content] isEqualToString:@"h"]) {
            _hero.position = pos;
            
        } else if ([[text content] isEqualToString:@"H"]) {
            Heart* heart = [Heart new_heart:pos];
            [world addChild:heart];
            
        } else if ([[text content] isEqualToString:@"m"]) {
            Monster* m = [Monster monster];
            m.position = pos;
            [world addChild:m];
            [monsterList addObject:m];
        } else if ([[text content] hasPrefix:@"T:"]) {
            Text* t = [Text text:[text content]];
            t.position = pos;
            [world addChild:t];
        } else if ([[[text content] substringToIndex:1] isEqualToString:@"F"]) {
            LevelEntry* levelEntry = [LevelEntry levelEntry: [[text content] substringFromIndex:1] ];
            levelEntry.position = CGPointMake(x + 13, y);
            [world addChild:levelEntry];
        } else if ([[text content] hasPrefix:@"sh"]) {
            Shield* s = [Shield shield: [text content]];
            s.position = pos;
            [world addChild:s];
        } else if ([[text content] hasPrefix:@"s"]) {
            //BulletPack* star = [BulletPack bulletPack];
            //star.position = pos;
            //[world addChild:star];
            Spike* s = [Spike spike:[text content]];
            s.position = pos;
            [world addChild:s];
        } else if ([[text content] hasPrefix:@"S"]) {
            Spring* s = [Spring spring: [text content]];
            s.position = pos;
            [world addChild:s];
        }else if ([[text content] isEqualToString:@"t"]) {
            [world enumerateChildNodesWithName:@"ground" usingBlock:^(SKNode *node, BOOL *stop) {
                if ([node containsPoint:pos]) {
                    ((Ground*)node).physicsBody = nil;
                    *stop = YES;
                }
            }];
            
        } else if ([[text content] isEqualToString:@"b"]) {
            Bomb* bomb = [Bomb bomb];
            bomb.position = pos;
            [world addChild:bomb];
            
            [world enumerateChildNodesWithName:@"ground" usingBlock:^(SKNode *node, BOOL *stop) {
                if ([bomb intersectsNode:node]) {
                    ((Ground*)node).isBombable = YES;
                    *stop = YES;
                }
            }];
            
        }else if ([[text content] isEqualToString:@"ba"]) {
            Balloon* ba = [Balloon balloon];
            ba.position = pos;
            [world addChild:ba];
            
        } else if ([[text content] hasPrefix:@"bg"]) { //ball generator
            [world addChild:[BallGenerator ballGenerator:[text content] atPos:pos parent:world]];
        } else if ([[text content] isEqualToString:@"wb"]) {
            Woodbox* box = [Woodbox woodbox];
            box.position = pos;
            [world addChild:box];
        } else if ([[text content] isEqualToString:@"k"]) {
            NSString* fill_flag = attrs[@"fill"];
            Key* k = [Key key_with_flag: fill_flag];
            
            k.position = pos;
            [world addChild:k];
            key_count++;
            
            [Key set_keys_to_be_collect:key_count];
        } else if ([[text content] hasPrefix:@"L"]) {
            Laser* la = [Laser laser: [text content]];
            la.position = pos;
            [world addChild:la];
            [updatableList addObject:la];
        } else if ([[text content] hasPrefix:@"X"]) {
            LaserX* la = [LaserX laserX: [text content]];
            la.position = pos;
            [world addChild:la];
            [updatableList addObject:la];
        } else if ([[text content] hasPrefix:@"C"]) {
            Cannon* c = [Cannon cannon: [text content]];
            c.position = pos;
            [world addChild:c];
            [updatableList addObject:c];
        } else if ([[text content] hasPrefix:@"d"] || [[text content] hasPrefix:@"D"]) {
            //Decoration* d = [Decoration decoration: [text content]];
            //d.position = pos;
            //[world addChild:d];
            
        } else if ([[text content] hasPrefix:@"p:"]) {
            SKNode* node = [world nodeAtPoint:pos];
            if (node != nil && [node conformsToProtocol:@protocol(Customizeable)]) {
                [(SKNode<Customizeable>*)node setParameter:[[text content] substringFromIndex:2]];
            }
        } else if ([[text content] isEqualToString:@"G"]) {
            //NSLog(@"%f %f", self.physicsWorld.gravity.dx, self.physicsWorld.gravity.dy);
            GravityTrigger* gt = [GravityTrigger gravityTrigger];
            gt.position = pos;
            [world addChild:gt];
        }
        else {
            NSLog(@"unknown content: %@", [text content]);
        }
    }
    
    
    NSString *saved_level_name = [[NSUserDefaults standardUserDefaults] stringForKey:@"saved_level_name"];
    NSMutableSet * dead_heros = (NSMutableSet*)[dead_heros_dict objectForKey:saved_level_name];
    if (dead_heros != nil) {
        for(NSValue* value in dead_heros) {
            CGPoint location = value.CGPointValue;
            DeadHero* dh = [DeadHero dead_hero:location];
            [world addChild:dh];
        }
    }
    
}

-(SKSpriteNode*) makeAnchorWithX:(CGFloat)x Y:(CGFloat)y {
    SKSpriteNode* anchor = [SKSpriteNode spriteNodeWithColor:[SKColor yellowColor] size:CGSizeMake(4, 4)];
    anchor.position = CGPointMake(x, y);
    SKLabelNode* label = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"%d,%d", (int)x, (int)y]];
    label.fontSize = label.fontSize/2;
    label.zPosition = 10000;
    [anchor addChild:label];
    return anchor;
}

-(void)addPositionAnchors {
    [world.scene addChild:[self makeAnchorWithX:-100 Y:-100]];
    [world.scene addChild:[self makeAnchorWithX:0 Y:0]];
    [world.scene addChild:[self makeAnchorWithX:100 Y:100]];
    [world.scene addChild:[self makeAnchorWithX:200 Y:200]];
    [world.scene addChild:[self makeAnchorWithX:300 Y:300]];
    [world.scene addChild:[self makeAnchorWithX:100 Y:200]];
    [world.scene addChild:[self makeAnchorWithX:100 Y:300]];
    [world.scene addChild:[self makeAnchorWithX:200 Y:100]];
    [world.scene addChild:[self makeAnchorWithX:300 Y:100]];
    [world.scene addChild:[self makeAnchorWithX:175 Y:45]];
    [world.scene addChild:[self makeAnchorWithX:200 Y:25]];
}

-(void)loadLevel:(NSString*)level_file_name {
    NSData  * data      = [NSData dataWithContentsOfFile:level_file_name];
    TFHpple * doc       = [[TFHpple alloc] initWithHTMLData:data];
    
    NSArray * svg  = [doc searchWithXPathQuery:@"//svg"];
    if ([svg count] != 1) {
        return;
    }
    NSDictionary* svg_attrs = (NSDictionary*)[[svg objectAtIndex:0] attributes];
    svg_height = [svg_attrs[@"height"] floatValue];
    
    
    NSArray * rects  = [doc searchWithXPathQuery:@"//rect"];
    for (TFHppleElement* rect in rects) {
        NSDictionary* attrs = [rect attributes];
        if ([attrs[@"id"] isEqualToString:@"canvas_background"] || [@"url(#gridpattern)" isEqualToString:attrs[@"fill"]]) {
            continue;
        }

        CGFloat x = [attrs[@"x"] floatValue];
        CGFloat y = [attrs[@"y"] floatValue];
        CGFloat w = [attrs[@"width"] floatValue];
        CGFloat h = [attrs[@"height"] floatValue];
        NSString* fill_flag = attrs[@"fill"];
        
        CGFloat r = 0;
        if (attrs[@"transform"]) {
            r = [[attrs[@"transform"] substringFromIndex:[@"rotate(" length]] floatValue];
        }
        
        [self add_ground_on_x:x + w/2 y:svg_height - y - h/2 w:w h:h r:r fill_flag:fill_flag];
    }
}

- (SKNode*)world {
    return world;
}

- (void)new_world {
    [world removeAllChildren];
    [world removeFromParent];
    world = [SKNode node];
    world.name = @"world";
    world.position = CGPointZero;
    
    //[world addChild:backgoundStars];
    
    [self addChild:world];
}

-(NSString*)get_level_file_path_by_name: (NSString*)levelName {
    return [[NSBundle mainBundle] pathForResource:levelName ofType:@"svg"];
}

- (void)restart_level:(NSString*)levelName {
    [[NSUserDefaults standardUserDefaults] setObject:levelName forKey:@"saved_level_name"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reload_level_from_file: [self get_level_file_path_by_name:levelName]];
}


- (void)reload_level_from_file:(NSString*)level_file_name {
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:level_file_name];
    if (!fileExists) {
        return [self restart_level:@"level10000"];
    }
    
//    NSArray* ps = [level_file_name componentsSeparatedByString:@"/"];
//    CGFloat levelNum = [[[ps lastObject] substringFromIndex:[@"level" length]] floatValue];
//    if (levelNum < 4 || levelNum > 9999) {
//        [left runAction:[SKAction colorizeWithColor:[SKColor orangeColor] colorBlendFactor:1 duration:0]];
//        [right runAction:[SKAction colorizeWithColor:[SKColor orangeColor] colorBlendFactor:1 duration:0]];
//        [jump_button runAction:[SKAction colorizeWithColor:[SKColor orangeColor] colorBlendFactor:1 duration:0]];
//        left.alpha =  right.alpha = jump_button.alpha = 0.6;
//        buttonPressedAlpha = 1;
//        buttonUnpressedAlpha = 0.6;
//    } else {
//        [left runAction:[SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:1 duration:0]];
//        [right runAction:[SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:1 duration:0]];
//        [jump_button runAction:[SKAction colorizeWithColor:[SKColor whiteColor] colorBlendFactor:1 duration:0]];
//        left.alpha =  right.alpha = jump_button.alpha = 0.1;
//
//        buttonPressedAlpha = 0.25;
//        buttonUnpressedAlpha = 0.1;
//    }
    
    [Key reset_keys_count_collected_by_hero];
    
    currentLevel = @"level10000"; //levelName;
    
    
    
    self.scene.view.paused = YES;
    
    [self new_world];
    
    //[self addPositionAnchors];
    
    //if (_hero == nil) {
        _hero = [HMHero new_hero];
    //}
    [_hero reset_status];
    [world addChild:_hero];
    //[self addPositionAnchors];
    
    
    [self loadLevel:level_file_name];
    [self reset_hero_position___and___add_monster_from_level_file:level_file_name];
    
    
    [world enumerateChildNodesWithName:@"ground" usingBlock:^(SKNode *node, BOOL *stop) {
        [((Ground*)node) final_colorize];
    }];
    
    
    self.scene.view.paused = NO;
    game_over_label.hidden = YES;
    [musicPlayer play];
}

-(void)send_dummy_msg_to_keep_websocket_alive {
    if ([[BLWebSocketsServer sharedInstance] isRunning]) {
        [[BLWebSocketsServer sharedInstance] pushToAll:[@"keep_alive_msg_from_ios" dataUsingEncoding:NSUTF8StringEncoding]];
    }
}

static NSTimer* keep_alive_timer;
-(void)didMoveToView:(SKView *)view {
    
    dead_heros_dict = [[NSMutableDictionary alloc] init];
    
    NSString *saved_level_name = [[NSUserDefaults standardUserDefaults] stringForKey:@"saved_level_name"];
    if (saved_level_name == nil) {
        NSLog(@"no saved level name.");
        saved_level_name = @"level10000";
        [[NSUserDefaults standardUserDefaults] setObject:saved_level_name forKey:@"saved_level_name"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        NSLog(@"saved level name is: %@", saved_level_name);
    }
    
    
#ifdef DEBUG_VERSION
    __block NSString* total_svg;
    
    //every request made by a client will trigger the execution of this block.
    [[BLWebSocketsServer sharedInstance] setHandleRequestBlock:^NSData *(NSData *data) {
        NSString* tmp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", tmp);
        //NSLog(@"+++---------------------: %@", tmp);
        
        [world  runAction:[SKAction playSoundFileNamed:@"grab_key.mp3" waitForCompletion:NO]];
        
        total_svg = [[NSString alloc] initWithFormat:@"%@%@", total_svg, tmp];
        
        if ([total_svg hasSuffix:@"</svg>"]) {
            
            [world  runAction:[SKAction playSoundFileNamed:@"healing.mp3" waitForCompletion:NO]];
            
            //NSLog(@"xxxxxxxx: %@", total_svg);
            NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *filePath = [documentDir stringByAppendingPathComponent:@"level.svg"];
            
            if (data) {
                //[[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                if ([[total_svg dataUsingEncoding:NSUTF8StringEncoding] writeToFile:filePath atomically:YES]) {
                    //NSLog(@"File is saved to %@",filePath);
                    [[NSUserDefaults standardUserDefaults] setObject:@"level_test" forKey:@"saved_level_name"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[GameScene sharedInstance] reload_level_from_file:filePath];
                }
            }
            
            total_svg = @"";
        }
        
        return [@"success" dataUsingEncoding:NSUTF8StringEncoding];
    }];
    //Start the server
    [[BLWebSocketsServer sharedInstance] startListeningOnPort:9000 withProtocolName:@"echo-protocol" andCompletionBlock:^(NSError *error) {
        if (!error) {
            NSLog(@"Server started");
            
            
            keep_alive_timer = [[NSTimer alloc] initWithFireDate:[NSDate date]
                                                      interval:5
                                                        target:self
                                                      selector:@selector(send_dummy_msg_to_keep_websocket_alive)
                                                      userInfo:nil
                                                       repeats:YES];
            
            [keep_alive_timer fire];
            [[NSRunLoop currentRunLoop] addTimer:keep_alive_timer forMode:NSDefaultRunLoopMode];
        }
        else {
            NSLog(@"%@", error);
            exit(-2);
        }
    }];
    
#endif
    
    self.anchorPoint = CGPointMake(0.5, 0.5);
    
    buttonPressedAlpha = 1.0;
    buttonUnpressedAlpha = 0.8;
    
    game_over_label = [SKLabelNode labelNodeWithFontNamed:@"ChalkboardSE-Bold"];
    game_over_label.fontSize = 50;
    game_over_label.text = @"Game Over";
    game_over_label.fontColor = [SKColor orangeColor];
    game_over_label.hidden = YES;
    game_over_label.zPosition = 2001;
    [self addChild:game_over_label];
    
    [self new_world];
    
    SKSpriteNode* background_img = [SKSpriteNode spriteNodeWithImageNamed:@"background2.png"];
    background_img.anchorPoint = CGPointMake(0.5, 0.3);
    background_img.zPosition = -1000;
//    background_img.alpha = 0.1;
//    background_img.colorBlendFactor = 0.5;
//    background_img.color = [SKColor blackColor]; //TODO: apply different color to forest, according the time of the play machine.
    [self addChild:background_img];

    
    if (control_layer != nil) {
        [control_layer removeFromParent];
    }
    control_layer = [SKNode node];
    control_layer.zPosition = 2000;
    [self addChild:control_layer];
    
    [self addControlPad];
    
    self.physicsWorld.gravity = CGVectorMake(0, -5);
    self.physicsWorld.contactDelegate = self;
    
    //self.backgaroundColor = [SKColor grayColor];
    //self.backgroundColor = [SKColor colorWithHexString:@"#99CC33" alpha:1.0];
    
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"background_music0" ofType:@"mp3"];
    musicPlayer = [[AVAudioPlayer alloc]
                        initWithContentsOfURL:[NSURL fileURLWithPath:musicPath] error:NULL];
    musicPlayer.numberOfLoops = -1;
    musicPlayer.volume = 0.3;
    [musicPlayer play];
    
    NSString *game_end_music = [[NSBundle mainBundle] pathForResource:@"game_end" ofType:@"mp3"];
    game_end_player = [[AVAudioPlayer alloc]
                   initWithContentsOfURL:[NSURL fileURLWithPath:game_end_music] error:NULL];
    game_end_player.volume = 0.02;
    
    game_victory_player = [[AVAudioPlayer alloc]
                          initWithContentsOfURL:[NSURL fileURLWithPath:
                                                 [[NSBundle mainBundle] pathForResource:@"victory" ofType:@"mp3"]] error:NULL];
    
    [self restart_level:saved_level_name];
    //[self restart_level:@"level7"];
}


-(e_btn)get_button_type:(SKNode*) node {
    if (node) {
        if ([node.name isEqualToString:@"jump"]) {
            return e_jump;
        } else if ([node.name isEqualToString:@"left"]) {
            return e_left;
        } else if ([node.name isEqualToString:@"right"]) {
            return e_right;
        } else if ([node.name isEqualToString:@"fire"]) {
            return e_fire;
        } else if ([node.name isEqualToString:@"reload"]) {
            return e_reload;
        }
    }
    
    return e_undown;
}

-(e_btn)buttonUnderTouch:(UITouch*) touch {
    return [self get_button_type:[control_layer nodeAtPoint:[touch locationInNode:self]]];
}

-(void)reload_remote_level_file {
    [self runAction:[SKAction playSoundFileNamed:@"victory.mp3" waitForCompletion:NO]];

    NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentDir stringByAppendingPathComponent:@"level.svg"];
    [[NSUserDefaults standardUserDefaults] setObject:@"level_test" forKey:@"saved_level_name"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self reload_level_from_file:filePath];
    
    
    /*
     NSString *documentDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
     NSString *filePath = [documentDir stringByAppendingPathComponent:@"level.svg"];
     
     NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.2.100:8000/Download.svg"]];
     request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
     [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue]
                            completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
         if (error) {
             NSLog(@"Download Error:%@",error.description);
         }
         if (data) {
             //[[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
             if ([data writeToFile:filePath atomically:YES]) {
             //NSLog(@"File is saved to %@",filePath);
               [self reload_level_from_file:filePath];
             }
         }
     }];
    */
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.scene.view.paused) {
        NSString *saved_level_name = [[NSUserDefaults standardUserDefaults] stringForKey:@"saved_level_name"];
        if ([saved_level_name isEqualToString:@"level_test"])
            [self reload_remote_level_file];
        else
            [self restart_level:saved_level_name];
    }
    
    for (UITouch *touch in touches) {
        e_btn btn = [self buttonUnderTouch:touch];
        switch (btn) {
            case e_right:
                [_hero begin_move_right];
                [self button_pressed:right];
                break;
            case e_left:
                [_hero begin_move_left];
                [self button_pressed:left];
                break;
            case e_jump:
                [_hero jump];
                [self button_pressed:jump_button];
                break;
            case e_fire:
                [_hero fire];
                [self button_pressed:fire];
                break;
            case e_reload:
                //[self reload_remote_level_file];
                [dead_heros_dict removeAllObjects];
                //[self restart_level:@"level10000"];
                [musicPlayer pause];
                [self runAction:play_back_to_select_level_sound_action];
                SKTransition *reveal = [SKTransition doorsCloseVerticalWithDuration:0.5];
                [self.view presentScene:[SelectLevelScene sharedInstance] transition:reveal];
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        e_btn btn = [self buttonUnderTouch:touch];
        
        CGPoint prev_location = [touch previousLocationInView:self.view];
        CGPoint from_point = [self convertPointFromView:prev_location];
        CGPoint from_point_ex = [self convertPoint:from_point toNode:control_layer];

        SKNode* prev_node = [self nodeAtPoint: from_point_ex];
        e_btn prev_btn = [self get_button_type:prev_node];
        if (prev_btn == btn) {
            continue;
        }
        
        switch (prev_btn) {
            case e_left:
                [self button_unpressed:left];
                [_hero end_move_left];
                break;
            case e_right:
                [self button_unpressed:right];
                [_hero end_move_right];
                break;
            case e_jump:
                [self button_unpressed:jump_button];
                break;
            case e_fire:
                [self button_unpressed:fire];
                break;
            default:
                break;
        }
        
        switch (btn) {
            case e_left:
                [self button_pressed:left];
                [_hero begin_move_left];
                break;
            case e_right:
                [self button_pressed:right];
                [_hero begin_move_right];
                break;
            case e_jump:
                [self button_pressed:jump_button];
                [_hero jump];
                break;
            case e_fire:
                [self button_pressed:fire];
                [_hero fire];
            default:
                break;
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint prev_location = [touch previousLocationInView:self.view];
        CGPoint from_point = [self convertPointFromView:prev_location];
        CGPoint from_point_ex = [self convertPoint:from_point toNode:control_layer];
        SKNode* prev_node = [control_layer nodeAtPoint: from_point_ex];
        e_btn prev_btn = [self get_button_type:prev_node];
        e_btn btn = [self buttonUnderTouch:touch];
        
        switch (btn) {
            case e_right:
                [self button_unpressed:right];
                [_hero end_move_right];
                break;
            case e_left:
                [self button_unpressed:left];
                [_hero end_move_left];
                break;
            case e_jump:
                [self button_unpressed:jump_button];
                break;
            case e_fire:
                [self button_unpressed:fire];
                break;
            case e_undown:
            {
                switch (prev_btn) {
                    case e_left:
                        [self button_unpressed:left];
                        [_hero end_move_left];
                        break;
                    case e_right:
                        [self button_unpressed:right];
                        [_hero end_move_right];
                        break;
                    case e_jump:
                        [self button_unpressed:jump_button];
                        break;
                    case e_fire:
                        [self button_unpressed:fire];
                        break;
                    default:
                        break;
                }
            }
            default:
                break;
        }
    }
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}


-(void)game_over {
    NSString *saved_level_name = [[NSUserDefaults standardUserDefaults] stringForKey:@"saved_level_name"];
    
    NSMutableSet * dead_heros = (NSMutableSet*)[dead_heros_dict objectForKey:saved_level_name];
    if (dead_heros == nil) {
        dead_heros = [[NSMutableSet alloc] init];
        [dead_heros_dict setObject:dead_heros forKey:saved_level_name];
    }
    
    [dead_heros addObject: [NSValue valueWithCGPoint:self.hero.position]];
    
    //[_hero reset_status];
    self.scene.view.paused = YES;
    self.hero.bullet_count = 5;
    game_over_label.hidden = NO;
    [musicPlayer pause];
    [game_end_player play];
}

-(void)game_victory {
    //self.scene.view.paused = YES;
    //game_over_label.hidden = NO;
    //[musicPlayer pause];
    //[game_victory_player play];
}

static NSString* nextLevel;
- (void)restart_to_level:(NSString*)levelName {
    [self runAction:actionEnterNextLevelSound];
    nextLevel = levelName;
}

- (SKPhysicsWorld*)current_physics_world {
    return self.physicsWorld;
}

-(void)update:(CFTimeInterval)currentTime {

    
    if ([nextLevel length] > 0) {
        [self restart_level:nextLevel];
        nextLevel = @"";
    }
    
    CFTimeInterval timeSinceLast = currentTime - lastUpdateTimeInterval;
    lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
    }
    
    [_hero update:timeSinceLast current:currentTime];
    
    if (_hero.position.y < - self.view.scene.size.height/2) {
        [self game_over];
    }

    for (id obj in monsterList) {
        Monster* m = (Monster*)obj;
        if (m.position.y < -self.frame.size.height/2) {
            [m removeFromParent];
        } else {
            [m update:currentTime];
        }
    }
    
    for (id obj in updatableList) {
        [ (SKSpriteNode<Updatable>*)obj update:currentTime];
    }
    
    
    bullet_count_label.text = [NSString stringWithFormat:@"%d", self.hero.bullet_count];
}

-(void)didSimulatePhysics {
}

-(void)didFinishUpdate {
    if ( ! self.scene.view.paused) {
        CGPoint positionInScene = [self convertPoint:_hero.position fromNode:world];
        
        if (fabs(world.position.y - positionInScene.y) > 0.3) {
            world.position = CGPointMake(world.position.x - positionInScene.x, world.position.y - positionInScene.y);
        }
    }
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    if ([contact.bodyA.node conformsToProtocol:@protocol(SKContactable)]) {
        [((SKNode<SKContactable> *)contact.bodyA.node) contact_body:contact.bodyB with:contact];
    }
}

-(void)didEndContact:(SKPhysicsContact *)contact {
    if ([contact.bodyA.node conformsToProtocol:@protocol(SKContactable)]) {
        [((SKNode<SKContactable> *)contact.bodyA.node) end_contact:contact.bodyB with:contact];
    }
}

- (void)update_hero_health_to:(int)health_value {
    health_value_label.text = [NSString stringWithFormat:@" %d", MAX(health_value, 0)];
}
    
- (void)update_hero_bullet_count_to:(NSString*)count {
    if ([count containsString:@"/"]) {
        bullet_icon_label.text = count; /*[NSString stringWithFormat:@" %d", count];*/
    } else {
        NSArray* ps = [bullet_icon_label.text componentsSeparatedByString:@"/"];
        bullet_icon_label.text = [NSString stringWithFormat:@"%@/%@", count, ps[1]];
    }
}

- (void)physicsBodyAlongRay:(CGPoint)start_point_in_world len:(CGFloat)len  rotation:(CGFloat)rotation
                usingBlock:(void (^)(SKPhysicsBody *body, CGPoint point, CGVector normal, BOOL *stop))block {
    CGPoint pp = [self convertPoint:start_point_in_world fromNode:world];
    CGPoint p =  CGPointMake(pp.x, pp.y  /*self.size.height/2*/);
    CGPoint end = CGPointMake(p.x + len*cosf(rotation), p.y + len*sinf(rotation));
    //NSLog(@"-- %f %f | %f %f", p.x, p.y, end.x, end.y);

    [self.physicsWorld enumerateBodiesAlongRayStart:p end:end usingBlock:block];
}


- (void)before_enter_new_level: (CGPoint)level_position {
    [self.world enumerateChildNodesWithName:@"DH" usingBlock:^(SKNode * _Nonnull node, BOOL * _Nonnull stop) {
        CGFloat dx = level_position.x - node.position.x;
        CGFloat dy = level_position.y - node.position.y;
        [node runAction:
            [SKAction sequence:@[
                                 [SKAction moveByX:dx y:dy duration:0.3],
                                 [SKAction removeFromParent]
                                ]
            ]
         ];
    }];
    
}

@end
