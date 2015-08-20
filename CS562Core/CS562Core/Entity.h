//
//  Entity.h
//  CS562Core
//
//  Created by Felipe Robledo on 8/19/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

@class IView;
@class IController;
@class IModel;

#import <Foundation/Foundation.h>

@interface Entity : NSObject
{
    @private;
    unsigned long _id;
}
@property NSString*       _name;
@property Entity*         _parent;
@property NSMutableArray* _children;
@property NSMapTable*     _models;
@property NSMapTable*     _views;
@property NSMapTable*     _controllers;

-(id)initWithId:(unsigned long)ID;
-(id)initWithId:(unsigned long)ID withName:(NSString*)name;
-(id)initWithId:(unsigned long)ID withName:(NSString*)name utilizeSerializer:(NSObject*)ser;
-(void)postInit;

-(void)addChild:(Entity*)newChild;
-(NSMutableArray*)getChild:(NSString*)name;

-(void)addModel:(IModel*)model;
-(void)addView:(IView*)view;
-(void)addController:(IController*)controller;

-(void)removeModelUsingInstance:(IModel*)model;
-(void)removeViewUsingInstance:(IView*)view;
-(void)removeControllerUsingInstance:(IController*)controller;

-(void)removeModelUsingName:(NSString*)name;
-(void)removeViewUsingName:(NSString*)name;
-(void)removeControllerUsingName:(NSString*)name;



@end
