//
//  World.m
//  CS562
//
//  Created by Felipe Robledo on 9/24/15.
//  Copyright © 2015 Felipe Robledo. All rights reserved.
//

#import "World.h"
#import <Transform.h>
#import <PointLight.h>
#import <DirectionalLight.h>
#import <SpotLight.h>
#import <Model3D.h>
#import <CS562Core/EntityCreator.h>
#include <Material.h>
#import <Skydome.h>


@interface World(PrivateMethods)
-(void) serializeData:(NSArray*)entries into:(NSMutableArray*)destination;
-(void) createManySpheres;
@end

@implementation World

START_SPECIAL_SETTORS(World)

    ADD_SPECIAL_SETTER(@"gameObjects", @"gameObjectsSpecialSetter:")
    ADD_SPECIAL_SETTER(@"lights", @"lightsSpecialSetter:")

END_SPECIAL_SETTORS

-(id) init {
    if ((self = [super init])) {
        _gameObjects = [[NSMutableArray alloc] init];
        
        NSMutableArray *pointLights = [[NSMutableArray alloc] init],
                 *directionalLights = [[NSMutableArray alloc] init],
                        *spotLights = [[NSMutableArray alloc] init];
        
        // Create the containers for each of the lights
        _lights = [[NSMutableDictionary alloc] init];
        [[self lights] setObject:pointLights forKey:@"PointLight"];
        [[self lights] setObject:directionalLights forKey:@"DirectionalLight"];
        [[self lights] setObject:spotLights forKey:@"SpotLight"];
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner {
    if ((self = [super initWithOwner:owner])) {
        
    }
    return self;
}

-(id) initWithOwner:(Entity*)owner usingSerializer:(NSDictionary*)ser {
    if ((self = [super initWithOwner:owner usingSerializer:ser])) {
        
    }
    return self;
}

-(id) initWithDictionary:(NSDictionary*)dict {
    if ((self = [super initWithDictionary:dict])) {
        
    }
    return self;
}

-(void) serializeWith:(NSObject*)ser {
    
}

-(void) postInit {
    
}

-(NSArray*) getWorldObjects {
    return _gameObjects;
}

// Get the first object we with name "entityName"
-(NSNumber*) getEntityWithName:(NSString*)entityName {
    for(NSNumber* ID in _gameObjects) {
        uint64 entityID = [ID unsignedLongLongValue];
        Entity* e = [EntityCreator getEntity:entityID];
        if ([[e _name] isEqualToString:entityName]) {
            return ID;
        }
    }
    return nil;
}

// PRIVATES --------------------------------------------------------------------

-(void) serializeData:(NSArray*)entries into:(NSMutableArray*)destination {
    NSBundle* bundle = [NSBundle mainBundle];
    
    for(NSDictionary* archetype in entries) {
        // Create game object from archetype filename
        NSString* archetypeName = [archetype valueForKey:@"Archetype"];
        NSArray* parts = [archetypeName  componentsSeparatedByString:@"."];
        
        NSString* path = [bundle pathForResource:[parts objectAtIndex:0] ofType:[parts objectAtIndex:1]];
        NSData* entityData = [NSData dataWithContentsOfFile:path];
        NSAssert(entityData != nil, @"File coult not be opened or read");
        
        
        uint64 entityID = [EntityCreator newEntity:nil fromJSONFile:entityData];
        Entity* entity = [EntityCreator getEntity:entityID];
        
        // Modify all components with the new data
        for(NSString* componentName in archetype) {
            if ([componentName isEqualToString:@"Archetype"]) {
                continue;
            }
            
            NSDictionary* componentData = [archetype valueForKey:componentName];
            [EntityCreator serializeModel:componentName withData:componentData ofEntity:entity];
        }
        
        // TODO:
        // This should not really be here. The world should postInit all entities
        //     when the world itself postinits
        [entity postInit];
        NSNumber* temp = [[NSNumber alloc] initWithUnsignedLongLong:entityID];
        [destination addObject:temp];
    }
}

-(void) createManySpheres {
    // Get the plane of the world
    NSNumber* planeID = [self getEntityWithName:@"Plane"];
    uint64 entityID = [planeID unsignedLongLongValue];
    Entity* plane = [EntityCreator getEntity:entityID];
    NSAssert(plane != nil, @"ERROR: While populating the world PLANE could not be found");
    
    // Find center and dimensions on x-z plane
    Transform* planeTransform = (Transform*)[plane getModelWithName:@"Transform"];
    CGRect bounds;
    bounds.origin.x = planeTransform.data->position.x;
    bounds.origin.y = planeTransform.data->position.z;
    bounds.size.width  = planeTransform.data->scale.x;
    bounds.size.height = planeTransform.data->scale.z;
    
    // Get the maximum height we can place a sphere at by finding the light
    //     source and capping positions to y - sphereRadius;
    // Hard-coded value for now
    const GLfloat maxHeight = 20;
    const GLuint maxSphereCount = 10;
    const GLfloat startingPosX = bounds.origin.x - bounds.size.width * 0.5f;
    const GLfloat startingPosZ = bounds.origin.y - bounds.size.height * 0.5f;
    
}

//------------------------------------------------------------------------------
-(void) gameObjectsSpecialSetter:(NSObject*)data {
    NSArray* archetypeArray = (NSArray*)data;
    if(archetypeArray == nil) {
        return;
    }
    
    [self serializeData:archetypeArray into:_gameObjects];
    
    // Now we create the Skydome entity
    uint64 entityID = [EntityCreator newEmptyEntity:nil];
    Entity* entity = [EntityCreator getEntity:entityID];
    [entity setName:@"Skydome"];
    
    Transform *transform = [[Transform alloc] init];
    transform.data->scale    = GLKVector3Make(1.0f, 1.0f, 1.0f);
    transform.data->position = GLKVector3Make(0.0f, 0.0f, -10.0f);
    transform.data->rotation = GLKVector3Make(0.0f, 0.0f, 0.0f);
    
    Model3D *model = [[Model3D alloc] init];
    [model setMeshSource:@"skybox"];
    
    Material *material = [[Material alloc] init];
    material.specularity = [[NSNumber alloc] initWithInt:1.0];
    *material.diffuse = GLKVector4Make(1.0,1.0,0.3,0.0);
    *material.emissive = GLKVector4Make(1.0,1.0,1.0,1.0);
    
    //Skydome *dome = [[Skydome alloc] init];
    
    [entity addModel:transform];
    [entity addModel:model];
    //[entity addModel:material];
    //[entity addView:dome];
    
    [entity postInit];
    _skydome = [[NSNumber alloc] initWithUnsignedLongLong:entityID];
    
    // So adding the sphere to the game objects does render it correctly.
    // However, when rendering the skybox it is not displayed, why???
    //[_gameObjects addObject:_skydome];
}

-(void) lightsSpecialSetter:(NSObject*)data {
    NSArray* archetypeArray = (NSArray*)data;
    if(archetypeArray == nil) {
        return;
    }
    
    // We will consider all of the lights as part of the world
    [self serializeData:archetypeArray into:_gameObjects];
    
    // Store the ID of every entity that has one of the types of
    // light models.
    for(NSNumber* ID in _gameObjects) {
        uint64 temp = [ID unsignedLongLongValue];
        Entity* entity = [EntityCreator getEntity:temp];
        
        // Check which type of light model this entity is
        // It cannot have more than 1 type of light model
        PointLight *pLight =
            (PointLight*)[entity getModelWithName:@"PointLight"];
        DirectionalLight *dLight =
            (DirectionalLight*)[entity getModelWithName:@"DirectionalLight"];
        SpotLight *sLight = (SpotLight*)[entity getModelWithName:@"SpotLight"];
        
        NSMutableArray* container = nil;
        if(pLight != nil) {
            container = [[self lights] valueForKey:@"PointLight"];
        } else if(dLight != nil) {
            container = [[self lights] valueForKey:@"DirectionalLight"];
        } else if(sLight != nil) {
            container = [[self lights] valueForKey:@"SpotLight"];
        }

        [container addObject:ID];
    }
}

@end
