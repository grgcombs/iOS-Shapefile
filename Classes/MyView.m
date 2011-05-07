//=============================================================================
// Copyright (c) 2004-2009 Pascal Brandt - All Rights Reserved
//=============================================================================
// Name:    "MyView.m"
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

#import "MyView.h"
#import "Shapefile.h"
#import "PointLong.h"
#import "AppController.h"

@implementation MyView


@synthesize startPoint;
@synthesize viewPort;
@synthesize zoom;
@synthesize load;


-(BOOL)isOpaque
{
	
	return YES;
	
}


-(void)setShapefile:(Shapefile *)shapefile
{
	
	m_shapefile = shapefile;
	
}


static void drawStringInRect(NSRect rect, NSString *str, int fontSize)
{
	
	NSDictionary *dict = [NSDictionary
                          dictionaryWithObject:[NSFont boldSystemFontOfSize:fontSize]
                                        forKey:NSFontAttributeName];
	NSAttributedString *astr = [[NSAttributedString alloc]
                                initWithString:str
                                    attributes:dict];
	NSSize strSize = [astr size];
	NSPoint pt = NSMakePoint((rect.size.width - strSize.width) / 2,
                                 (rect.size.height - strSize.height) / 2);
	
	// Clear the rect
	rect.origin.x = 0;
	rect.origin.y = 0;
	[[NSColor whiteColor] set];
	NSRectFill(rect);
	
	// Draw the string
	[astr drawAtPoint:pt];
	[astr release];
	
}


-(NSPoint)P2M:(NSPoint)ptMouseLocationP
{
	
	NSPoint ptMouseLocationM;
	float nZoom = zoom;
	NSRect rectViewPortM = viewPort;
	ptMouseLocationM.x = rectViewPortM.origin.x + ((ptMouseLocationP.x * METERS_PER_PIXEL) / nZoom);
	ptMouseLocationM.y = rectViewPortM.origin.y + ((ptMouseLocationP.y * METERS_PER_PIXEL) / nZoom);
	
	return ptMouseLocationM;
	
}


-(void)mouseMoved:(NSEvent *)theEvent
{
	
	if(load)
	{
		
		NSPoint ptWindowLocationP = [theEvent locationInWindow];
		NSPoint ptMouseLocationP = [self convertPoint:ptWindowLocationP fromView:nil];
		
		BOOL bInside = [self mouse:ptMouseLocationP inRect:[self bounds]];
		
		if(bInside)
		{
			
			NSPoint ptMouseLocationM;
			ptMouseLocationM = [self P2M:ptMouseLocationP];
			NSString* aString = [NSString stringWithFormat:@"East: %d North: %d",
				(long)ptMouseLocationM.x, (long)ptMouseLocationM.y];
			[locCoord setStringValue:aString];
			
		}
		
	}

}


-(void)displayZoomFactor
{
	
	NSString* strZoom = [NSString stringWithFormat:@"%d %%", (long)(roundtol(zoom * 100))];
	[zoomFactor setStringValue:strZoom];
	
}


-(void)zoomIn:(BOOL)bIn atLocation:(NSEvent*)theEvent
{
	
	long nZoomedWidthM, nZoomedHeightM;
	
	NSPoint ptWindowLocationP = [theEvent locationInWindow];
	NSPoint ptMouseLocationP = [self convertPoint:ptWindowLocationP fromView:nil];
	NSPoint ptMouseLocationM = [self P2M:ptMouseLocationP];
	
	NSRect rectViewPortM;
	
	float nZoom = zoom;
	
	if(bIn)
		nZoom = (nZoom * sqrt(2));
	else
		nZoom = (nZoom / sqrt(2));
	
	zoom = nZoom;
	[self displayZoomFactor];
	
	long nWidthM = viewPort.size.width;
	long nHeightM = viewPort.size.height;
	
	if(bIn)
	{
		
		nZoomedWidthM = nWidthM / sqrt(2);
		nZoomedHeightM = nHeightM / sqrt(2);
		
	}
	else
	{
		
		nZoomedWidthM = nWidthM * sqrt(2);
		nZoomedHeightM = nHeightM * sqrt(2);
	
	}
	
	rectViewPortM.origin = NSMakePoint(ptMouseLocationM.x - (nZoomedWidthM / 2),
	 				   ptMouseLocationM.y - (nZoomedHeightM / 2));
	rectViewPortM.size = NSMakeSize(nZoomedWidthM, nZoomedHeightM);
	
	viewPort = rectViewPortM;
	[self setNeedsDisplay:YES];
	
}


-(void)mouseDown:(NSEvent *)theEvent
{
	
	// NSLog(@"mouseDown");
	
	NSString* strCurrentAction = [controller currentAction];
	
	if([strCurrentAction isEqualToString:@"Zoom"])
	   [self zoomIn:YES atLocation:theEvent];
	
	if([strCurrentAction isEqualToString:@"Pan"])
	{
		
		NSPoint ptWindowLocationP = [theEvent locationInWindow];
		NSPoint ptMouseLocationP = [self convertPoint:ptWindowLocationP fromView:nil];
		
		startPoint = ptMouseLocationP;
		
	}

}


-(void)mouseUp:(NSEvent *)theEvent
{
	
	// NSLog(@"mouseUp");

}


-(void)rightMouseDown:(NSEvent *)theEvent
{

	NSLog(@"rightMouseDown");
	
	NSString* strCurrentAction = [controller currentAction];
	
	if([strCurrentAction isEqualToString:@"Zoom"])
		[self zoomIn:NO atLocation:theEvent];
	
}


-(void)rightMouseUp:(NSEvent *)theEvent
{
	
	NSLog(@"rightMouseUp");
	
}


-(void)mouseDragged:(NSEvent *)theEvent
{
	
	// NSLog(@"mouseDragged");
	
	NSString* strCurrentAction = [controller currentAction];
	
	if([strCurrentAction isEqualToString:@"Pan"])
	{
		
		NSPoint ptStartPointP = startPoint;
		NSPoint ptStartPointM = [self P2M:ptStartPointP];
		NSPoint ptWindowLocationP = [theEvent locationInWindow];
		NSPoint ptMouseLocationP = [self convertPoint:ptWindowLocationP fromView:nil];
		NSPoint ptMouseLocationM = [self P2M:ptMouseLocationP];
		startPoint = ptMouseLocationP;
		
		NSPoint ptDeltaP = NSMakePoint(ptMouseLocationP.x - ptStartPointP.x, ptMouseLocationP.y - ptStartPointP.y);
		NSPoint ptDeltaM = NSMakePoint(ptMouseLocationM.x - ptStartPointM.x, ptMouseLocationM.y - ptStartPointM.y);
		
		// [self setEndPoint:ptDeltaP];
		// [self translateOriginToPoint:[self endPoint]];
		
		NSRect rectViewPortM = viewPort;
		rectViewPortM.origin.x = rectViewPortM.origin.x - ptDeltaM.x;
		rectViewPortM.origin.y = rectViewPortM.origin.y - ptDeltaM.y;
		viewPort = rectViewPortM;

		[self setNeedsDisplay:YES];
		
	}
	
}


- (id)initWithFrame:(NSRect)frameRect
{
	
	// if ((self = [super initWithFrame:frameRect]) != nil)
	// {
	//		Add initialization code here
	// }
	
	NSArray *dragShapefile = [NSArray arrayWithObject:NSFilenamesPboardType];
	[self registerForDraggedTypes:dragShapefile];
	
	self = [super initWithFrame:frameRect];
	color = [[NSColor redColor] retain];
	
	return self;
	
}


-(void)awakeFromNib
{
	
	[[self window] makeFirstResponder:self];
	[[self window] setAcceptsMouseMovedEvents:YES];
	[colorWell setColor:color];
	[self setNeedsDisplay:YES];
	
}


-(IBAction)changeColor:(id)sender
{
	
	NSColor *newColor = [sender color];
	[newColor retain];
	[color release];
	color = newColor;
	[self setNeedsDisplay:YES];
	
}


-(IBAction)changeWidth:(id)sender
{
	
	[self setNeedsDisplay:YES];
	
}


-(IBAction)changeAntialias:(id)sender
{
	
	[self setNeedsDisplay:YES];
	
}


-(void)dealloc
{
	
	[color release];
	[super dealloc];
	
}


- (void)drawRect:(NSRect)rect
{
	
	// we ignore the 'aRect' argument - possible future optimization would use it
	NSRect frame = [self frame];
	
	NSRect rectBounds = [self bounds];
	[[NSColor whiteColor] set];
	NSRectFill(rectBounds);
	
	if ([self inLiveResize])
	{
		
		NSString *str = [NSString stringWithFormat:@"Resizing to %g x %g",
				 frame.size.width, frame.size.height];
		drawStringInRect(frame, str, 20);
		
		return;
		
	}
	
	long nShapefileType;
	
	[[color colorWithAlphaComponent:transparency] set];
	NSGraphicsContext *currentContext = [NSGraphicsContext currentContext];
	
	BOOL bAntialias = [antiAlias state];
	[currentContext setShouldAntialias:bAntialias];
	BOOL bAntialiasChecked = [currentContext shouldAntialias];
	
	if(load)
	{
		
		float nZoom = zoom;
		NSRect rectViewPortM = viewPort;
		
		nShapefileType = [m_shapefile shapefileType];
		
		if(nShapefileType == kShapeTypePoint)
		   [self drawShapePoint];
		if((nShapefileType == kShapeTypePolyline) || (nShapefileType == kShapeTypePolygon))
		   [self drawShapePolyline];
		
		[[NSGraphicsContext currentContext] saveGraphicsState];
		
		NSAffineTransform* transform = [NSAffineTransform transform];
		
		float nOffsetX = (rectViewPortM.size.width / 2.0) * (1 - nZoom) / METERS_PER_PIXEL;
		float nOffsetY = (rectViewPortM.size.height / 2.0) * (1 - nZoom) / METERS_PER_PIXEL;
		
		[transform translateXBy:nOffsetX yBy:nOffsetY];
		[transform scaleBy:nZoom];
		[transform concat];
		[[NSGraphicsContext currentContext] restoreGraphicsState];
		
	}
	
}


-(void)drawShapePoint
{
	
	NSRect  rectPoint;
	long    i;
	long    nShapeCount;
	NSPoint ptToDraw;
	long    nEast, nNorth;
	
	NSRect rectViewPortM = viewPort;
	float nZoom = zoom;
	int nLineWidth = [lineWidth indexOfSelectedItem];
	nShapeCount = [m_shapefile->m_objList count];
	
	for(i = 0; i < nShapeCount; i++)
	{
		
		ShapePoint* shapePoint;
		shapePoint = [[ShapePoint alloc] init];
		shapePoint = [m_shapefile->m_objList objectAtIndex:i];
		
		nEast = shapePoint->m_nEast;
		nNorth = shapePoint->m_nNorth;
		
		ptToDraw.x = (nEast - rectViewPortM.origin.x) * (nZoom / METERS_PER_PIXEL);
		ptToDraw.y = (nNorth - rectViewPortM.origin.y) * (nZoom / METERS_PER_PIXEL);
		
		rectPoint.origin = NSMakePoint(ptToDraw.x - nLineWidth, ptToDraw.y - nLineWidth);
		rectPoint.size = NSMakeSize(2 * nLineWidth, 2 * nLineWidth);
		
		NSBezierPath *point = [NSBezierPath bezierPath];
		[point appendBezierPathWithOvalInRect:rectPoint];
		[point fill];
		
	}
	
}


-(void)drawShapePolyline
{
	
	NSRect  frame = [self frame];
	long    i, j, k;
	int     nLineWidth;
	long    nShapeCount;
	NSPoint ptToDraw;
	long    nEast, nNorth;
	long    nPartsCount;
	long    nPointsCount;
	long    nStartPart;
	long    nEndPart;
	
	NSRect rectViewPortM = viewPort;
	float nZoom = zoom;
	nLineWidth = [lineWidth indexOfSelectedItem];
	nShapeCount = [m_shapefile->m_objList count];
	
	for(i = 0; i < nShapeCount; i++)
	{
		
		ShapePolyline* shapePolyline;
		shapePolyline = [[ShapePolyline alloc] init];
		[shapePolyline initMutableArray];
		
		shapePolyline = [m_shapefile->m_objList objectAtIndex:i];
		nPartsCount = [shapePolyline->m_Parts count];
		
		for(j = 0; j < nPartsCount; j++)
		{
			
			NSBezierPath *line = [NSBezierPath bezierPath];
			
			nPointsCount = [shapePolyline->m_Points count];
			
			NSNumber* startPart;
			startPart = [shapePolyline->m_Parts objectAtIndex:j];
			nStartPart = [startPart intValue];
			
			if(j + 1 == nPartsCount)
				nEndPart = nPointsCount;
			else
			{
				
				NSNumber* endPart;
				endPart = [shapePolyline->m_Parts objectAtIndex:j + 1];
				nEndPart = [endPart intValue];
				
			}
			
			for(k = nStartPart; k < nEndPart; k++)
			{
				
				PointLong* pointLong = [[PointLong alloc] init];
				pointLong = [shapePolyline->m_Points objectAtIndex:k];
				nEast = pointLong->m_nEast;
				nNorth = pointLong->m_nNorth;
				
				ptToDraw.x = (nEast - rectViewPortM.origin.x) * (nZoom / METERS_PER_PIXEL);
				ptToDraw.y = (nNorth - rectViewPortM.origin.y) * (nZoom / METERS_PER_PIXEL);
				
				if(k == nStartPart)
					[line moveToPoint:ptToDraw];
				else
					[line lineToPoint:ptToDraw];
				
			}
			
			[line setLineWidth:nLineWidth];
			[line setLineJoinStyle:NSRoundLineJoinStyle];
			[line stroke];
			
		}
		
	}
	
}


-(void)viewWillStartLiveResize
{
	
	[super viewWillStartLiveResize];
	[self setNeedsDisplay:NO];
	// Could do something here if needed
	
}


-(void)viewDidEndLiveResize
{
	
	[super viewDidEndLiveResize];
	
	NSRect rectViewPortM;
	rectViewPortM = viewPort;
	
	long nWidth, nHeight;
	float nZoom = zoom;
	
	nWidth = [self frame].size.width * METERS_PER_PIXEL / nZoom;
	nHeight = [self frame].size.height * METERS_PER_PIXEL / nZoom;
	rectViewPortM.size = NSMakeSize(nWidth, nHeight);
	
	viewPort = rectViewPortM;
	[self setNeedsDisplay:YES];
	// Could do something here if needed
	
}


-(void)setTransparencyValue:(float)value
{
	
	transparency = value;
	[self setNeedsDisplay:YES];
	
}


-(unsigned int)draggingEntered:(id <NSDraggingInfo>)sender
{
	
	return NSDragOperationMove;
	
}


-(unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender
{
	
	NSPasteboard *pboard = [sender draggingPasteboard];
	
	return NSDragOperationMove;
	
}


-(BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
	
	long i;
	
	NSPasteboard *pboard = [sender draggingPasteboard];
	
	if ([[pboard types] containsObject:NSFilenamesPboardType])
	{
		
		NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		int numberOfFiles = [files count];
		
		for(i = 0; i < numberOfFiles; i++)
		{
			
			NSString *strShapefile = [files objectAtIndex:i];
			[controller openShapefile:strShapefile];
			
		}
		
		// Perform operation using the list of files
		
	}
	
	return YES;
	
}

@end