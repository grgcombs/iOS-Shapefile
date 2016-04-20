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

@implementation TestObjCShapefileViewController
@synthesize mapView = _mapView;

static MKCoordinateSpan kStandardZoomSpan = {2.f, 2.f};

#define STATE_TX 1
#define STATE_NV 2

#define USE_STATE STATE_TX


#if USE_STATE == STATE_TX

    #define SHP_FILENAME @"planS01188_8pct"
    #define MAP_REGION MKCoordinateRegionMake((CLLocationCoordinate2D){31.709476f, -99.997559f}, (MKCoordinateSpan){10.f, 10.f})

    // The Texas state geographer uses a special projection
    #define EPSG3081 @"+proj=lcc +lat_1=27.41666666666667 +lat_2=34.91666666666666 +lat_0=31.16666666666667 +lon_0=-100 +x_0=1000000 +y_0=1000000 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
    #define SRC_PROJECTION EPSG3081

#elif USE_STATE == STATE_NV

    #define SHP_FILENAME @"tl_2010_32_county10"
    #define MAP_REGION MKCoordinateRegionMake((CLLocationCoordinate2D){38.395164f,-116.985512f}, (MKCoordinateSpan){7.f, 7.f})
    #define SRC_PROJECTION nil // Use 'nil' to decline reprojection, if your source is a WSG84 or NAD83 (USGS Tiger) projection

#endif

#pragma mark -
#pragma mark Properties

- (BOOL) region:(MKCoordinateRegion)region1 isEqualTo:(MKCoordinateRegion)region2 {
	MKMapPoint coord1 = MKMapPointForCoordinate(region1.center);
	MKMapPoint coord2 = MKMapPointForCoordinate(region2.center);
	BOOL coordsEqual = MKMapPointEqualToPoint(coord1, coord2);
	
	BOOL spanEqual = region1.span.latitudeDelta == region2.span.latitudeDelta; // let's just only do one, okay?
	return (coordsEqual && spanEqual);
}

- (void)viewDidLoad {
    [super viewDidLoad];

	//self.mapView.delegate = self;
	self.mapView.region = MAP_REGION;

	NSString *shapePath = [[NSBundle mainBundle] pathForResource:SHP_FILENAME ofType:@"shp"];

	[self openShapefile:shapePath];
}

- (void)animateToState
{    
    [self.mapView setRegion:MAP_REGION animated:YES];
}

- (void)animateToAnnotation:(id<MKAnnotation>)annotation
{
	if (!annotation)
		return;
	
    MKCoordinateRegion region = MKCoordinateRegionMake(annotation.coordinate, kStandardZoomSpan);
    [self.mapView setRegion:region animated:YES];	
}

- (void)moveMapToAnnotation:(id<MKAnnotation>)annotation {
	if (![self region:self.mapView.region isEqualTo:MAP_REGION]) { // it's another region, let's zoom out/in
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

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolygon class]])
    {
        UIColor *myColor = [UIColor purpleColor];

        MKPolygonRenderer * renderer = [[MKPolygonRenderer alloc] initWithPolygon:(MKPolygon*)overlay];
        renderer.fillColor = [myColor colorWithAlphaComponent:0.2];
        renderer.strokeColor = [myColor colorWithAlphaComponent:0.7];
        renderer.lineWidth = 2;

        return renderer;
    }

    return nil;
}

-(void)openShapefile:(NSString *)strShapefile
{
	Shapefile *shapefile = [[Shapefile alloc] init];
	
    NSString *source_projection = SRC_PROJECTION;
	BOOL bLoad = [shapefile loadShapefile:strShapefile withProjection:source_projection];
	
	if (bLoad)
	{
		long nShapefileType = shapefile.shapefileType;
		
		if (nShapefileType == kShapeTypePoint)
			[self.mapView addAnnotations:shapefile.objects];

		if ((nShapefileType == kShapeTypePolyline) || (nShapefileType == kShapeTypePolygon))
			[self.mapView addOverlays:shapefile.objects];
		
		[self.mapView setNeedsDisplay];
	}
}


@end
