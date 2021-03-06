/*
 * CocosBuilder: http://www.cocosbuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "ProjectSettings.h"
#import "cocos2d.h"

@interface PlugInNode : NSObject <NSPasteboardWriting>
{
    NSBundle* bundle;
    
    NSString* nodeClassName;
    NSString* nodeEditorClassName;
    
    NSString* displayName;
    NSString* descr;
    int ordering;
    BOOL supportsTemplates;
    
    NSImage* icon;
    
    NSString* dropTargetSpriteFrameClass;
    NSString* dropTargetSpriteFrameProperty;
    
    NSMutableArray* nodeProperties;
    NSMutableDictionary* nodePropertiesDict;
    
    BOOL canBeRoot;
    BOOL canHaveChildren;
    BOOL isAbstract;
    BOOL isJoint;//Its a physics Joint.
    
    NSString* positionProperty;
    NSString* requireParentClass;
    NSArray* requireChildClass;
    
    NSArray* cachedAnimatableProperties;
    NSArray* cachedAnimatablePropertiesFlashSkew;
}

@property (nonatomic,readonly) NSString* nodeClassName;
@property (nonatomic,readonly) NSString* nodeEditorClassName;
@property (nonatomic,readonly) NSString* displayName;
@property (nonatomic,readonly) NSString* descr;
@property (nonatomic,readonly) int ordering;
@property (nonatomic,readonly) BOOL supportsTemplates;
@property (nonatomic,readonly) NSMutableArray* nodeProperties;
@property (nonatomic,readonly) NSMutableDictionary* nodePropertiesDict;
@property (nonatomic,readonly) NSString* dropTargetSpriteFrameClass;
@property (nonatomic,readonly) NSString* dropTargetSpriteFrameProperty;
@property (nonatomic,readonly) BOOL acceptsDroppedSpriteFrameChildren;
@property (nonatomic,readonly) BOOL canBeRoot;
@property (nonatomic,readonly) BOOL canHaveChildren;
@property (nonatomic,readonly) BOOL isAbstract;
@property (nonatomic,readonly) BOOL isJoint;
@property (nonatomic,readonly) NSString* requireParentClass;
@property (nonatomic,readonly) NSArray* requireChildClass;
@property (nonatomic,readonly) NSString* positionProperty;
@property (nonatomic,strong) NSImage* icon;
@property (nonatomic, readonly) CCBTargetEngine targetEngine;

- (BOOL) dontSetInEditorProperty: (NSString*) prop;

- (id)initWithBundle:(NSBundle *)aBundle mainBundle:(NSBundle *)mainBundle;

- (NSArray*) readablePropertiesForType:(NSString*)type node:(CCNode*)node;
- (NSArray*) animatablePropertiesForNode:(CCNode*)node;
- (NSString*) propertyTypeForProperty:(NSString*)property;

- (BOOL) isAnimatableProperty:(NSString*)prop node:(CCNode*)node;

@end
