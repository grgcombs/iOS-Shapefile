//=============================================================================
// Copyright (c) 2004-2009 Pascal Brandt - All Rights Reserved
//=============================================================================
// Name:    "Shapefile.h"
// ----------------------------------------------------------------------------
// Purpose: ...
//          -------------------------------------------------------------------
// Usage:   ...
//          -------------------------------------------------------------------
// Remarks: ...
// ----------------------------------------------------------------------------
// Created: 20040709@000 BRA
// ----------------------------------------------------------------------------
// Changes: ...
//          -------------------------------------------------------------------
//
//=============================================================================

#import <Foundation/Foundation.h>

enum ShapeTypes {
	kShapeTypeUnknown = -1,
	kShapeTypeNull = 0,
	kShapeTypePoint = 1,
	kShapeTypePolyline = 3,
	kShapeTypePolygon = 5,
	kShapeTypeMulti = 8,
	kShapeTypePointZ = 11,
	kShapeTypePolylineZ = 13,
	kShapeTypePolygonZ = 15,
	kShapeTypeMultiZ = 18,
	kShapeTypePointM = 21,
	kShapeTypePolylineM = 23,
	kShapeTypePolygonM = 25,
	kShapeTypeMultiM = 28,
	kShapeTypeMultiPatch = 31,
};

@interface Shapefile : NSObject
{
	
	double extendLeft;
	double extendTop;
	double extendRight;
	double extendBottom;
	
	long fileLength;
	long m_nVersion;
	long recordCount;
	long m_nWidth;
	long shapefileType;
	
	NSString *m_strShapefile;
	NSData *m_data;
	
@public
	
	NSMutableArray *m_objList;
	
}

@property (readwrite) double extendLeft;
@property (readwrite) double extendBottom;
@property (readwrite) double extendRight;
@property (readwrite) double extendTop;
@property (readwrite) long fileLength;
@property (readwrite) long recordCount;
@property (readwrite) long shapefileType;
@property (nonatomic, readonly) NSArray *objects;

-(BOOL)loadShapefile:(NSString *)strShapefile withProjection:(NSString *)projection;
-(NSString *)shapefileTypeAsString;

@end