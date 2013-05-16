//
//  FlickrPhotoViewController.m
//  Flickr Assignment
//
//  Created by danielle vass on 15/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrPhotoViewController.h"
#import "FlickrFetcher.h"

@interface FlickrPhotoViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *flickrPhotoView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) UIPopoverController *popoverController;
@end

@implementation FlickrPhotoViewController
@synthesize flickrPhotoView;
@synthesize scrollView;
@synthesize photo = _photo;
@synthesize splitViewBarButtonItem = _splitViewBarButtonItem; 
@synthesize toolbar = _toolbar;
@synthesize popoverController;
@synthesize spinner = _spinner;


-(void) setPhoto:(NSDictionary *)photo
{
    if (_photo != photo) {
        _photo = photo;
        [self setPictureOnScreen];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidLoad
{
    self.spinner.hidesWhenStopped = TRUE;
    [self.spinner stopAnimating];
    [super viewDidLoad];
    [self handleSplitViewBarButtonItem:self.splitViewBarButtonItem];
}

- (void)handleSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    if (_splitViewBarButtonItem) [toolbarItems removeObject:_splitViewBarButtonItem];
    if (splitViewBarButtonItem) [toolbarItems insertObject:splitViewBarButtonItem atIndex:0];
    self.toolbar.items = toolbarItems;
    _splitViewBarButtonItem = splitViewBarButtonItem;
}

- (void)setSplitViewBarButtonItem:(UIBarButtonItem *)splitViewBarButtonItem
{
    if (splitViewBarButtonItem != _splitViewBarButtonItem) {
        [self handleSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

- (void) setPictureOnScreen
{
    if (self.photo == nil){
        //do nothing
    }else{
        
        self.scrollView.delegate = self;
        
        self.title = [self.photo objectForKey:FLICKR_PHOTO_TITLE];
        

        [self.spinner startAnimating];
        
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
        dispatch_async(downloadQueue, ^{
            
            NSURL *url = [FlickrFetcher urlForPhoto:self.photo format:FlickrPhotoFormatLarge];
            NSData *data = [NSData dataWithContentsOfURL:url];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.spinner stopAnimating];
                
                if (self.navigationItem.rightBarButtonItem ==nil){
                    //
                }else{
                    self.navigationItem.rightBarButtonItem = nil;
                }
                UIImage *flickrPhoto = [UIImage imageWithData:data];
                
                [self.flickrPhotoView setImage:flickrPhoto];            
                [self.flickrPhotoView setContentMode:UIViewContentModeScaleAspectFit];
                
                self.scrollView.zoomScale =1.0;
                NSLog(@"here");
                [self saveUserDefaults];
                [self saveImageToCache];
                
                

            });
        });
        dispatch_release(downloadQueue);
        
    }

    
}
-(void) saveImageToCache
{
    
    NSError *error = nil;
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];  //this get you to the root of your app's
    NSFileManager *manager = [[NSFileManager alloc] init];
    
    NSString *folderPath = [documentsDirectory stringByAppendingPathComponent:@"FlickrImageCache"];  
    
    if (![manager fileExistsAtPath:folderPath])  //Optionally check if folder already hasn't existed.
    {
        [manager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error];
        NSLog(@"created");
    }
    
    NSMutableData *data = [[NSMutableData alloc] init];
	NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
	[archiver encodeObject:self.photo forKey:@"flickr photo"];
	[archiver finishEncoding];
    
    NSString *filePath = [folderPath stringByAppendingPathComponent:[self.photo objectForKey:FLICKR_PHOTO_ID]];
    
    BOOL success = [manager createFileAtPath:filePath contents:data attributes:nil];
    
    if(success == YES){
        NSLog(@"yeah");
    } else {
        NSLog(@"nope");
    }
}

-(void)saveUserDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *defaultsList = [defaults arrayForKey:@"flickrAssignment.favourites"];
    NSMutableArray *favouritesList = [defaultsList mutableCopy];
    
    //if nothng exists, create an array
    if (!favouritesList) {
        favouritesList = [[NSMutableArray alloc] init];
    }
    
    //check if it already exists
    if ([favouritesList containsObject:self.photo]) {
        //do nothing
    } else {
        //check if there are already 20 items
        
        if ([favouritesList count] == 20) {
            NSRange theRange;
            theRange.location = 1;
            theRange.length = 19;
            
            NSArray *temp;
            temp = [favouritesList subarrayWithRange:theRange];
            NSMutableArray *newFavourites = [temp mutableCopy];
            
            [newFavourites addObject:self.photo];
            [defaults setObject:newFavourites forKey:@"flickrAssignment.favourites"];
            
        } else {
            
            [favouritesList addObject:self.photo];
            [defaults setObject:favouritesList forKey:@"flickrAssignment.favourites"];
            
        }
        
        [defaults synchronize];
        
    }
    
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.flickrPhotoView;
}

- (void)viewDidUnload
{
    [self setFlickrPhotoView:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
