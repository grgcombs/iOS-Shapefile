//=============================================================================
// Copyright (c) 2004-2009 Pascal Brandt - All Rights Reserved
//=============================================================================
// Name:    "ShapePolyline.h"
// ----------------------------------------------------------------------------
// Purpose: ...
//          -------------------------------------------------------------------
// Usage:   ...
//          -------------------------------------------------------------------
// Remarks: ...
// ----------------------------------------------------------------------------
// Created: 20040907@000 BRA
// ----------------------------------------------------------------------------
// Changes: ...
//          -------------------------------------------------------------------
//
//=============================================================================

#import <Foundation/Foundation.h>
#import "Shapefile.h"

@interface ShapePolyline : Shapefile
{

@private
	
	long numParts;
	long numPoints;
	
@public
	
	NSMutableArray* m_Points;
	NSMutableArray* m_Parts;
	double m_nBoundingBox[4];
	double m_nEast;
	double m_nNorth;

}

-(void)initMutableArray;
@property (readwrite) long numParts;
@property (readwrite) long numPoints;

@end
