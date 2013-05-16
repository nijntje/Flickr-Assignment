//
//  FlickrPhotoViewController.h
//  Flickr Assignment
//
//  Created by danielle vass on 15/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"

@interface FlickrPhotoViewController : UIViewController <SplitViewBarButtonItemPresenter>
@property (nonatomic, strong) NSDictionary *photo;

@end
