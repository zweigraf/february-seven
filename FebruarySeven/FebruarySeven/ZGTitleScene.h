//
//  ZGTitleScene.h
//  FebruarySeven
//
//  Created by Luis Reisewitz on 08.02.15.
//  Copyright (c) 2015 ZweiGraf. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol ZGTitleSceneDelegate <NSObject>

-(void)didStartGameFromScene:(SKScene *)scene;

@end

@interface ZGTitleScene : SKScene

@property (weak) NSObject<ZGTitleSceneDelegate> *titleDelegate;

@end
