//
//  TestObjCShapefileViewController.m
//  TestObjCShapefile
//
//  Created by Gregory Combs on 10/4/10.
//  Copyright 2010 Gregory S. Combs.
//
//	This software is provided 'as-is', without any express or implied
//	warranty. In no event will the authors be held liable for any damages
//	arising from the use of this software.
//
//	Permission is granted to anyone to use this software for any purpose,
//	including commercial applications, and to alter it and redistribute it
//	freely, subject to the following restrictions:
//
//	   1. The origin of this software must not be misrepresented; you must not
//	   claim that you wrote the original software. If you use this software
//	   in a product, an acknowledgment in the product documentation would be
//	   appreciated but is not required.
//
//	   2. Altered source versions must be plainly marked as such, and must not be
//	   misrepresented as being the original software.
//
//	   3. This notice may not be removed or altered from any source
//	   distribution.
//

#import <CoreLocation/CoreLocation.h>
#import "TestObjCShapefileViewController.h"
#import "Shapefile.h"
#import "ShapePolyline.h"
@interface TestObjCShapefileViewController (Private)

- (MKCoordinateRegion) texasRegion;

@end

@implementation TestObjCShapefileViewController
@synthesize mapView;

static MKCoordinateSpan kStandardZoomSpan = {2.f, 2.f};


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	//self.mapView.delegate = self;
	self.mapView.region = [self texasRegion];

	NSString *shapePath = [[NSBundle mainBundle] pathForResource:@"planS01188_8pct" ofType:@"shp"];
		
	[self openShapefile:shapePath];
}

#pragma mark -
#pragma mark Properties


- (MKCoordinateRegion) texasRegion {
	// Set up the map's region to frame the state of Texas.
	// Zoom = 6	
	static CLLocationCoordinate2D texasCenter = {31.709476f, -99.997559f};
	static MKCoordinateSpan texasSpan = {10.f, 10.f};
	const MKCoordinateRegion txreg = MKCoordinateRegionMake(texasCenter, texasSpan);
	return txreg;
}

- (BOOL) region:(MKCoordinateRegion)region1 isEqualTo:(MKCoordinateRegion)region2 {
	MKMapPoint coord1 = MKMapPointForCoordinate(region1.center);
	MKMapPoint coord2 = MKMapPointForCoordinate(region2.center);
	BOOL coordsEqual = MKMapPointEqualToPoint(coord1, coord2);
	
	BOOL spanEqual = region1.span.latitudeDelta == region2.span.latitudeDelta; // let's just only do one, okay?
	return (coordsEqual && spanEqual);
}

- (void)animateToState
{    
    [self.mapView setRegion:self.texasRegion animated:YES];
}

- (void)animateToAnnotation:(id<MKAnnotation>)annotation
{
	if (!annotation)
		return;
	
    MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, kStandardZoomSpan);
    [self.mapView setRegion:region animated:YES];	
}

- (void)moveMapToAnnotation:(id<MKAnnotation>)annotation {
	if (![self region:self.mapView.region isEqualTo:self.texasRegion]) { // it's another region, let's zoom out/in
		[self performSelector:@selector(animateToState) withObject:nil afterDelay:0.3];
		[self performSelector:@selector(animateToAnnotation:) withObject:annotation afterDelay:1.7];        
	}
	else
		[self performSelector:@selector(animateToAnnotation:) withObject:annotation afterDelay:0.7];	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	//self.mapView = nil;	// This is an "assign", not a "retain", so don't do this.  Right?

    [super dealloc];
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id)overlay{
	
	if ([overlay isKindOfClass:[MKPolygon class]])
    {		

		UIColor *myColor = [UIColor greenColor];
		
		MKPolygonView*    aView = [[[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay] autorelease];		
		aView.fillColor = [myColor colorWithAlphaComponent:0.2];
        aView.strokeColor = [myColor colorWithAlphaComponent:0.7];
        aView.lineWidth = 3;
		
        return aView;
    }
		
	return nil;
}

-(void)openShapefile:(NSString *)strShapefile
{
	
	Shapefile *shapefile = [[Shapefile alloc] init];
	
	//[myView setNeedsDisplay:YES];
	BOOL bLoad = [shapefile loadShapefile:strShapefile];
	
	if(bLoad)
	{
		long nShapefileType = [shapefile shapefileType];
		
		if(nShapefileType == kShapeTypePoint)
			[self.mapView addAnnotations:shapefile.objects];

		if((nShapefileType == kShapeTypePolyline) || (nShapefileType == kShapeTypePolygon))
			[self.mapView addOverlays:shapefile.objects];
		
		
/*		
		NSRect rectViewPortM;
		rectViewPortM.origin = NSMakePoint(([shapefile extendRight] + [shapefile extendLeft]) / 2 - ([myView frame].size.height * (METERS_PER_PIXEL / 2)),
										   ([shapefile extendTop] + [shapefile extendBottom]) / 2 - ([myView frame].size.height * (METERS_PER_PIXEL / 2)));
		rectViewPortM.size = NSMakeSize([myView frame].size.width * METERS_PER_PIXEL, [myView frame].size.height * METERS_PER_PIXEL);

		[boundingBoxLeft setIntValue:[shapefile extendLeft]];
		[boundingBoxTop setIntValue:[shapefile extendTop]];
		[boundingBoxRight setIntValue:[shapefile extendRight]];
		[boundingBoxBottom setIntValue:[shapefile extendBottom]];
		*/
		//NSString *strFileLength = [NSString stringWithFormat:@"File length: %d bytes", [shapefile fileLength]];
		//NSString *strRecordsCount = [NSString stringWithFormat:@"%d objects", [shapefile recordCount]];
		
		[self.mapView setNeedsDisplay];
	}
	
	else
		
	{
		
		[shapefile release];
		
	}
	
}


@end
