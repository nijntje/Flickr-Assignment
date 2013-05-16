//
//  FavouritesMapViewController.m
//  Flickr Assignment
//
//  Created by danielle vass on 21/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
// favourites to map

#import "FavouritesMapViewController.h"
#import "FlickrPhotoAnnotation.h"
#import "FlickrFetcher.h"


@interface FavouritesMapViewController ()<MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic)NSDictionary *selectedPhoto;
@property (nonatomic) MKCoordinateRegion region;
@end

@implementation FavouritesMapViewController



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
