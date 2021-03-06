//
//  GameScene.m
//  FebruarySeven
//
//  Created by Luis Reisewitz on 07.02.15.
//  Copyright (c) 2015 ZweiGraf. All rights reserved.
//

#import "GameScene.h"
#import <AVFoundation/AVFoundation.h>

#define kZGSpaceshipName @"spaceship"
#define kZGObstacleName @"obstacle"
#define kZGBorderName @"kZGBorderName"
#define kZGPointLabelName @"kZGPointLabelName"
#define kZGMusicKey @"kZGMusicKey"


typedef NS_OPTIONS(uint32_t, kZGCategoryBitmask) {
    kZGCategoryBitmaskSpaceship = 1 << 1,
    kZGCategoryBitmaskObstacle = 1 << 2,
    kZGCategoryBitmaskEdge = 1 << 3
};

typedef NS_ENUM(NSUInteger, ZGTouchLocation) {
    kZGTouchLocationNone,
    kZGTouchLocationLeft,
    kZGTouchLocationRight
};

const CGFloat kZGMaxSpeed = 20;
const CGFloat kZGObstacleRadius = 40.0;
const CGFloat kZGShipBottomDistance = 100.0;
const CGFloat kZGStartSpeed = 1.0;
const CGFloat kZGDifficultyFactor = 1.0;
const int kZGPointsPerObstacle = 1;
const CGFloat kZGShipXSpeed = 7.5;
const CGFloat kZGPointLabelMarginTop = 10.0;
const CGFloat kZGPointLabelMarginLeft = 20.0;

@interface GameScene () <SKPhysicsContactDelegate>

@property (assign) CFTimeInterval lastObstacleTime;
@property (assign) int points;
@property (assign) BOOL ended;
@property (nonatomic, assign) CGFloat obstacleSpeed;
@property (strong) NSSet *touches;

-(void)createSpaceship;
-(void)addObstacle;
-(void)createBorder;
-(void)createPointLabel;
-(void)endGame;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    
    self.lastObstacleTime = -1;
    self.obstacleSpeed = kZGStartSpeed;
    [self createSpaceship];
    [self createBorder];
    [self createPointLabel];
    
    // load sound files once to cache for the game
    [SKAction playSoundFileNamed:@"crash.m4a" waitForCompletion:NO];
    [SKAction playSoundFileNamed:@"move_short.m4a" waitForCompletion:NO];

    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/music.m4a", [[NSBundle mainBundle] resourcePath]]];
    
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    self.audioPlayer.numberOfLoops = -1;
    
    if (!self.audioPlayer) {
       NSLog(@"Music failed to initialize with error %@", [error localizedDescription]);
    } else {
        [self.audioPlayer play];
    }
    
    self.physicsWorld.contactDelegate = self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    [super touchesBegan:touches withEvent:event];
    
    self.touches = [touches setByAddingObjectsFromSet:self.touches];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    NSMutableSet *newTouches = [NSMutableSet setWithSet:self.touches];
    [newTouches minusSet:touches];
    self.touches = [newTouches copy];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    SKNode *ship = [self childNodeWithName:kZGSpaceshipName];
    CGPoint position = ship.position;
    
    ZGTouchLocation touchLocation = kZGTouchLocationNone;
    for (UITouch *touch in self.touches) {
        CGPoint location = [touch locationInNode:self];
        
        if (location.x < CGRectGetMidX(self.frame)) {
            touchLocation = kZGTouchLocationLeft;
            break;
        } else if (location.x >= CGRectGetMidX(self.frame)) {
            touchLocation = kZGTouchLocationRight;
            break;
        }
    }
    switch (touchLocation) {
        case kZGTouchLocationLeft:
        {
            ship.position = CGPointMake(position.x - kZGShipXSpeed, position.y);
            break;
        }
        case kZGTouchLocationRight:
        {
            ship.position = CGPointMake(position.x + kZGShipXSpeed, position.y);
            break;
        }
        default:
            break;
    }
    
    if (touchLocation != kZGTouchLocationNone) {
        
        SKAction *move = [SKAction playSoundFileNamed:@"move_short.m4a" waitForCompletion:NO];
        [self runAction:move];
    }
    
    if (_lastObstacleTime < 0) {
        _lastObstacleTime = currentTime;
        [self addObstacle];
    } else if ((currentTime - _lastObstacleTime) >= (kZGDifficultyFactor - _obstacleSpeed/kZGMaxSpeed)) {
        _lastObstacleTime = currentTime;
        [self addObstacle];
        self.obstacleSpeed += 0.1;
    }
}

#pragma mark - Game Kram

-(void)createSpaceship
{
    SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"GoodGuy"];
    
    sprite.xScale = 0.8;
    sprite.yScale = 0.8;
    
    CGFloat x = CGRectGetMidX(self.frame);
    CGFloat y = CGRectGetMinY(self.frame) + sprite.size.height + kZGShipBottomDistance;
    CGPoint position = CGPointMake(x, y);
    sprite.position = position;
    
    sprite.name = kZGSpaceshipName;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 25)];
    [path addLineToPoint:CGPointMake(-28, -25)];
    [path addLineToPoint:CGPointMake(28, -25)];
    [path closePath];
    
    
    sprite.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:path.CGPath];

//    sprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:sprite.size];
    sprite.physicsBody.dynamic = YES;
    sprite.physicsBody.affectedByGravity = NO;
    sprite.physicsBody.collisionBitMask = kZGCategoryBitmaskEdge;
    sprite.physicsBody.contactTestBitMask = kZGCategoryBitmaskObstacle;
    sprite.physicsBody.categoryBitMask = kZGCategoryBitmaskSpaceship;
    sprite.physicsBody.allowsRotation = NO;
    
    [self addChild:sprite];
    
}

-(void)addObstacle
{
    SKSpriteNode *obstacle = [SKSpriteNode spriteNodeWithImageNamed:@"Obstacle"];

//    SKShapeNode *obstacle = [SKShapeNode shapeNodeWithCircleOfRadius:kZGObstacleRadius];
    
    
    obstacle.color = [UIColor redColor];
    obstacle.colorBlendFactor = 0.7;
    
    obstacle.xScale = 1;
    obstacle.yScale = 1;
    obstacle.speed = self.obstacleSpeed;
    obstacle.zRotation = M_PI;
    
    obstacle.name = kZGObstacleName;
    
    CGFloat x = arc4random_uniform(self.frame.size.width - obstacle.size.width) + obstacle.size.width / 2;
    CGPoint position = CGPointMake(x, CGRectGetMaxY(self.frame) + obstacle.size.height);
    obstacle.position = position;
    
    obstacle.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(obstacle.size.width / 2) - 3];
    obstacle.physicsBody.categoryBitMask = kZGCategoryBitmaskObstacle;
    obstacle.physicsBody.collisionBitMask = 0x0;
    obstacle.physicsBody.affectedByGravity = NO;
    
    CGPoint destination = CGPointMake(x, -1 * obstacle.size.height);
    SKAction *fly = [SKAction moveTo:destination duration:5];

    SKAction *seq = [SKAction sequence:@[fly, [SKAction runBlock:^{
        self.points += kZGPointsPerObstacle;
        [self updatePointLabelWithPoints:self.points];
    }], [SKAction removeFromParent]]];

    [obstacle runAction:seq];

    
    [self addChild:obstacle];
}

-(void)createPointLabel {
    SKLabelNode *label = [SKLabelNode labelNodeWithText:@"0"];
    label.name = kZGPointLabelName;

    [self addChild:label];
    
    [self updatePointLabelWithPoints:0];
}

-(void)updatePointLabelWithPoints:(int)points {
    SKLabelNode *node = (SKLabelNode *)[self childNodeWithName:kZGPointLabelName];
    node.text = [NSString stringWithFormat:@"%d", points];
    
    CGSize nodeSize = node.frame.size;
    // label origin is bottom left, whole height needs to be subtracted for top margin
    CGFloat topMargin = kZGPointLabelMarginTop + nodeSize.height;
    // label origin is bottom left, left margin therefore only needs half
    CGFloat leftMargin = kZGPointLabelMarginLeft + nodeSize.width / 2.0;
    CGPoint topLeft = CGPointMake(CGRectGetMinX(self.frame) + leftMargin, CGRectGetMaxY(self.frame) - topMargin);
    
    node.position = topLeft;
}

-(void)createBorder {
    SKNode *border = [SKNode node];
    border.name = kZGBorderName;
    border.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    border.physicsBody.categoryBitMask = kZGCategoryBitmaskEdge;
    border.physicsBody.collisionBitMask = kZGCategoryBitmaskSpaceship;
    
    [self addChild:border];
}


-(void)endGame
{
    self.ended = YES;
    self.speed = 0;
    
    SKAction *crash = [SKAction playSoundFileNamed:@"crash.m4a" waitForCompletion:YES];
    [self runAction:crash];

    [self.audioPlayer stop];
    if (self.gameDelegate && [self.gameDelegate respondsToSelector:@selector(didEndGameFromScene:withPoints:)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.gameDelegate didEndGameFromScene:self withPoints:self.points];
        });
        
    }
}

-(void)setObstacleSpeed:(CGFloat)speed
{
    if (speed > kZGMaxSpeed) {
        speed = kZGMaxSpeed;
    }
    if (speed == _obstacleSpeed) {
        return;
    }
    [self enumerateChildNodesWithName:kZGObstacleName usingBlock:^(SKNode *node, BOOL *stop) {
        node.speed = speed;
    }];
    _obstacleSpeed = speed;
}

#pragma mark - SKPhysicsContactDelegate


- (void)didBeginContact:(SKPhysicsContact *)contact {
    if (self.ended) {
        return;
    }
    if (contact.bodyA.categoryBitMask & kZGCategoryBitmaskSpaceship) {
        [contact.bodyB.node removeFromParent];
        [[self childNodeWithName:kZGSpaceshipName] removeFromParent];
    } else if (contact.bodyB.categoryBitMask & kZGCategoryBitmaskSpaceship) {
        [contact.bodyA.node removeFromParent];
        [[self childNodeWithName:kZGSpaceshipName] removeFromParent];
    }
    [self endGame];
    
}

- (void)didEndContact:(SKPhysicsContact *)contact {
    
}

@end
