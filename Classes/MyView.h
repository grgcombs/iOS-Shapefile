//=============================================================================
// Copyright (c) 2004-2009 Pascal Brandt - All Rights Reserved
//=============================================================================
// Name:    "MyView.h"
// ----------------------------------------------------------------------------
// Purpose: ...
//          -------------------------------------------------------------------
// Usage:   ...
//          -------------------------------------------------------------------
// Remarks: ...
// ----------------------------------------------------------------------------
// Created: 20040101@000 BRA
// ----------------------------------------------------------------------------
// Changes: ...
//          -------------------------------------------------------------------
//
//=============================================================================

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import "Shapefile.h"
#import "ShapePoint.h"
#import "ShapePolyline.h"

@interface MyView : NSView
{
	
	id controller;
	Shapefile* m_shapefile;
	BOOL load;
	IBOutlet NSTextField *zoomFactor;
	IBOutlet NSColorWell *colorWell;
	IBOutlet NSPopUpButton *lineWidth;
	IBOutlet NSButton *antiAlias;
	NSColor *color;
	float transparency;
	NSTextField *locCoord;
	
	long m_nExtendWidth;
	long m_nExtendHeight;
	long m_nWidth;
	long m_nHeight;
	
	float zoom;
	NSRect viewPort;
	NSPoint startPoint;
	
}

@property (readwrite) NSPoint startPoint;
@property (readwrite) NSRect viewPort;
@property (readwrite) float zoom;
@property (readwrite) BOOL load;
-(void)displayZoomFactor;
-(void)zoomIn:(BOOL)bIn atLocation:(NSEvent*)theEvent;
-(void)drawShapePoint;
-(void)drawShapePolyline;
-(BOOL)isOpaque;
-(void)setShapefile:(Shapefile *)shapefile;
-(IBAction)changeColor:(id)sender;
-(IBAction)changeWidth:(id)sender;
-(IBAction)changeAntialias:(id)sender;
-(NSPoint)P2M:(NSPoint)ptMouseLocationP;
-(void)setTransparencyValue:(float)value;
-(unsigned int)draggingEntered:(id <NSDraggingInfo>)sender;
-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender;
-(unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender;

@end
