//
//  FavouritesMapViewController.h
//  Flickr Assignment
//
//  Created by danielle vass on 21/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MapKit/MapKit.h>

@class FavouritesMapViewController;

@protocol MapViewControllerDelegate <NSObject>
- (UIImage *)FavouritesMapViewController:(FavouritesMapViewController *)sender imageForAnnotation:(id <MKAnnotation>)annotation;
@end


@interface FavouritesMapViewController : UIViewController
@property (nonatomic, strong) NSArray *annotations; // of id <MKAnnotation>
@property (nonatomic, weak) id <MapViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *photos;
@end
