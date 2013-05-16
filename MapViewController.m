//
//  MapViewController.m
//  Flickr Assignment
//
//  Created by danielle vass on 21/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "FlickrFetcher.h"
#import "FlickrPhotoViewController.h"

@interface MapViewController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic)NSDictionary *selectedPhoto;
@property (nonatomic) MKCoordinateRegion region;
@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize annotations = _annotations;
@synthesize delegate = _delegate;
@synthesize photos = _photos;
@synthesize region = _region;
@synthesize selectedPhoto = _selectedPhoto;

- (void)updateMapView
{
    if (self.mapView.annotations) {
        [self.mapView removeAnnotations:self.mapView.annotations];
    }
    
    if (self.annotations){
        [self.mapView addAnnotations:self.annotations];
    }
    [self.mapView setRegion:self.region];
}

- (void)setPhotos:(NSArray *)photos
{
    if (_photos != photos) {
        _photos = photos;
        _region = [self setRegionUp:[photos objectAtIndex:0]];
        _annotations = [self mapAnnotations];
    }
}

-(MKCoordinateRegion)setRegionUp:(NSDictionary *)photo
{
    MKCoordinateRegion newRegion;
    
    newRegion.span.latitudeDelta = 0.3f;
    newRegion.span.longitudeDelta = 0.3f;
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [[photo objectForKey:FLICKR_LATITUDE] doubleValue];
    coordinate.longitude = [[photo objectForKey:FLICKR_LONGITUDE] doubleValue];
    
    newRegion.center = coordinate;
    
    return newRegion;
    
}

- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}

- (UIImage *) imageForAnnotation:(id <MKAnnotation>)annotation
{
    
    
    FlickrPhotoAnnotation *fpa = (FlickrPhotoAnnotation *)annotation;
    NSURL *url = [FlickrFetcher urlForPhoto:fpa.photo format:FlickrPhotoFormatSquare];
    NSData *data = [NSData dataWithContentsOfURL:url];
    return data ? [UIImage imageWithData:data] : nil;
}

- (NSArray *)mapAnnotations
{
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[self.photos count]];
    for (NSDictionary *photo in self.photos) {
        [annotations addObject:[FlickrPhotoAnnotation annotationForPhoto:photo]];
    }
    return annotations;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];
    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;
        aView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        aView.rightCalloutAccessoryView = detailButton;
    }
    
    aView.annotation = annotation;
    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    
    return aView;
}
 

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)aView
{
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
       UIImage *image = [self imageForAnnotation:aView.annotation];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [(UIImageView *)aView.leftCalloutAccessoryView setImage:image];
            
        });
    });
    dispatch_release(downloadQueue);

    
    
    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSInteger index = [self.annotations indexOfObject:view.annotation];
    self.selectedPhoto = [self.photos objectAtIndex:index];
    
    if ([self splitViewFlickrPhotoViewController]) {
        [self splitViewFlickrPhotoViewController].photo =self.selectedPhoto;  
    } else {
        [self performSegueWithIdentifier:@"map to photo" sender:self];
    }
    
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"map to photo"]) {
        [segue.destinationViewController setPhoto:self.selectedPhoto];
    }
    
}

- (FlickrPhotoViewController *)splitViewFlickrPhotoViewController {
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[FlickrPhotoViewController class]]) {
        gvc = nil;
    }
    return gvc;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
}

- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



@end
