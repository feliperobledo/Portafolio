//
//  Entity.m
//  CS562Core
//
//  Created by Felipe Robledo on 8/19/15.
//  Copyright (c) 2015 Felipe Robledo. All rights reserved.
//

#import "Entity.h"
#import "IView.h"
#import "IModel.h"
#import "IController.h"
#import <EntityCreator.h>

@implementation Entity

@synthesize _name        = Name;
@synthesize _parent      = Parent;
@synthesize _children    = Children;
@synthesize _models      = Models;
@synthesize _views       = Views;
@synthesize _controllers = Controllers;

-(id)initWithId:(uint64)ID andParent:(Entity *)parent{
    if (self == [super init]) {
        _id = ID;
        [self setParent:parent];
        [self initAllMem];
    }
    return self;
}

-(id)initWithId:(uint64)ID withName:(NSString*)name andParent:(Entity *)parent{
    if (self == [super init]) {
        _id = ID;
        [self setParent:parent];
        [self initAllMem];
        Name = name;
    }
    return self;
}

-(id)initWithId:(uint64)ID withName:(NSString*)name utilizeSerializer:(NSObject*)ser andParent:(Entity *)p{
    if (self == [super init]) {
        _id = ID;
        [self setParent:p];
        [self initAllMem];
        Name = name;
        [self serializeSelfWith:ser];
    }
    return self;
}

-(void)postInit {
    //Do any other initilization work, such as creating the bindings of all
    //controllers.
    /**/
    for (NSString* key in Models) {
        IModel* model = [Models valueForKey:key];
        [model postInit];
    }
    
    // init this controllers first, then child controllers
    for (NSString* key in Controllers) {
        IController* controller = [Controllers valueForKey:key];
        [controller initControllerBindings];
    }
    
    for (Entity* entity in Children) {
        [entity postInit];
    }
}

-(uint64)getID {
    return self->_id;
}

// Can only be called by EntityCreator
-(void)setID:(uint64)newID {
    self->_id = newID;
}

-(void)setName:(NSString*)name {
    Name = name;
}

// -----------------------------------------------------------------------------
-(void)addChild:(Entity*)newChild {
    [Children addObject:newChild];
    [newChild setParent:self];
}

-(NSMutableArray*)getChild:(NSString*)name {
    return nil;
}

-(Entity*) getParent {
    return Parent;
}

-(void) setParent:(Entity*)newParent {
    Parent = newParent;
}

//-----------------------------------------------------------------------------
-(void)addModel:(IModel*)model {
    NSString* className = NSStringFromClass([model class]);
    if([Models valueForKey:className] != nil) {
        return;
    }
    [Models setObject:model forKey:[className lowercaseString]];
    [model setOwner:self];
}

-(void)addView:(IView*)view {
    NSString* className = NSStringFromClass([view class]);
    if([Views valueForKey:className] != nil) {
        return;
    }
    [Views setObject:view forKey:[className lowercaseString]];
    [view setOwner:self];
}

-(void)addController:(IController*)controller {
    NSString* className = NSStringFromClass([controller class]);
    if([Controllers valueForKey:className] != nil) {
        return;
    }
    [Controllers setObject:controller forKey:[className lowercaseString]];
    [controller setOwner:self];
}

-(IModel*)getModelWithName:(NSString*)modelName {
    NSString *temp = [modelName lowercaseString];
    return [Models valueForKey:temp];
}

-(IView*)getViewWithName:(NSString*)viewName {
    NSString *temp = [viewName lowercaseString];
    return [Views valueForKey:temp];
}

-(IController*)getControllerName:(NSString*)controllerName {
    NSString *temp = [controllerName lowercaseString];
    return [Controllers valueForKey:temp];
}

-(void)removeModelUsingInstance:(IModel*)model {
    NSString* className = NSStringFromClass([model class]);
    [self removeModelUsingName:className];
    [model setOwner:nil];
}

-(void)removeViewUsingInstance:(IView*)view {
    NSString* className = NSStringFromClass([view class]);
    [self removeViewUsingName:className];
    [view setOwner:nil];
}

-(void)removeControllerUsingInstance:(IController*)controller {
    NSString* className = NSStringFromClass([controller class]);
    [self removeControllerUsingName:className];
    [controller setOwner:nil];
}

-(void)removeModelUsingName:(NSString*)name {
    if([Controllers valueForKey:name] == nil) {
        return;
    }
    [Models removeObjectForKey:[name lowercaseString]];
}

-(void)removeViewUsingName:(NSString*)name {
    if([Controllers valueForKey:name] == nil) {
        return;
    }
    [Views removeObjectForKey:[name lowercaseString]];
}

-(void)removeControllerUsingName:(NSString*)name {
    if([Controllers valueForKey:name] == nil) {
        return;
    }
    [Controllers removeObjectForKey:[name lowercaseString]];
}

// -----------------------------------------------------------------------------

-(void)serializeSelfWith:(NSObject*)ser {
    // do logic here to create every model, view and controller from the
    // serializer.
    
    // ser - an object with an interface that allows for query of models, views and controllers
    // should have:
    // - name
    // - list of models
    // - list of controllers
    // - list of views
    // - list of children entities
}

-(void) initAllMem {
    Name        = [[NSString       alloc] init];
    Children    = [[NSMutableArray alloc] init];
    Models      = [[NSMutableDictionary  alloc] init];
    Views       = [[NSMutableDictionary  alloc] init];
    Controllers = [[NSMutableDictionary  alloc] init];
}

@end
