//
//  ViewController.h
//  CS562
//
//  Created by Felipe Robledo on 7/3/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CS562Core/CS562Core.h>


@interface ViewController : NSViewController

@property EntityCreator* _entityCreator;
@property Entity* _engine;

-(void)loadView;
-(void)viewWillAppear;
-(void)viewDidAppear;
-(void)viewDidLoad;
-(void)setRepresentedObject:(id)representedObject;

-(void)gameLoopUpdate;

@end

