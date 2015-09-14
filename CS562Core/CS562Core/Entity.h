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
    uint64 _id;
}

@property (retain) NSString*       _name;
@property (retain) Entity*         _parent;
@property (retain) NSMutableArray* _children;
@property (retain) NSMutableDictionary*     _models;
@property (retain) NSMutableDictionary*     _views;
@property (retain) NSMutableDictionary*     _controllers;

-(id)initWithId:(uint64)ID andParent:(Entity*)parent;
-(id)initWithId:(uint64)ID withName:(NSString*)name andParent:(Entity*)parent;
-(id)initWithId:(uint64)ID withName:(NSString*)name utilizeSerializer:(NSObject*)ser andParent:(Entity*)p;
-(void)postInit;

-(uint64)getID;

// Can only be called by EntityCreator
-(void)setID:(uint64)newID;
-(void)setName:(NSString*)name;

-(void)addChild:(Entity*)newChild;
-(NSMutableArray*)getChild:(NSString*)name;

-(Entity*) getParent;
-(void) setParent:(Entity*)newParent;

-(void)addModel:(IModel*)model;
-(void)addView:(IView*)view;
-(void)addController:(IController*)controller;

-(IModel*)getModelWithName:(NSString*)modelName;
-(IView*)getViewWithName:(NSString*)viewName;
-(IController*)getControllerName:(NSString*)controllerName;


-(void)removeModelUsingInstance:(IModel*)model;
-(void)removeViewUsingInstance:(IView*)view;
-(void)removeControllerUsingInstance:(IController*)controller;

-(void)removeModelUsingName:(NSString*)name;
-(void)removeViewUsingName:(NSString*)name;
-(void)removeControllerUsingName:(NSString*)name;


@end
