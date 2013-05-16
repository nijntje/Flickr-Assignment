//
//  FavouritesTableViewController.m
//  Flickr Assignment
//
//  Created by danielle vass on 16/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FavouritesTableViewController.h"
#import "FlickrFetcher.h"
#import "FlickrPhotoViewController.h"
#import "MapViewController.h"

@interface FavouritesTableViewController ()
@property (nonatomic, strong) NSDictionary *selectedPhoto;
@end

@implementation FavouritesTableViewController
@synthesize favourites = _favourites;
@synthesize selectedPhoto = _selectedPhoto;

#pragma mark - favourite setter
- (void)setFavourites:(NSArray *)favourites
{
    if (_favourites != favourites) {
        _favourites = favourites;
        // Model changed, so update our View (the table)
        if (self.tableView.window) [self.tableView reloadData];
    }
}

#pragma mark - initialising the screen

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *defaultsList = [defaults arrayForKey:@"flickrAssignment.favourites"];
    NSMutableArray *favouritesList = [defaultsList mutableCopy];
    
    //if nothng exists, create an array
    if (!favouritesList) {
        favouritesList = [[NSMutableArray alloc] init];
    }
    
    NSMutableArray *newArray;
    newArray = [[NSMutableArray alloc]initWithCapacity:[favouritesList count]];
    
    for (id obj in [favouritesList reverseObjectEnumerator]) {
        [newArray addObject:obj];
    }
    
    [self setFavourites: newArray];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.favourites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Favourite Cells";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
     NSDictionary *photo = [self.favourites objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [photo valueForKey:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [photo valueForKey:@"ownername"];
    return cell;
}


#pragma mark - Seques
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Favourite Photo View"]) {
        [segue.destinationViewController setPhoto:self.selectedPhoto];
    }else if ([segue.identifier isEqualToString:@"favourites to map"]) {
         [segue.destinationViewController setPhotos:self.favourites];
    }
    
}

- (FlickrPhotoViewController *)splitViewFlickrPhotoViewController {
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[FlickrPhotoViewController class]]) {
        gvc = nil;
    }
    return gvc;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedPhoto = [self.favourites objectAtIndex:indexPath.row];
    
    if ([self splitViewFlickrPhotoViewController]) {
        [self splitViewFlickrPhotoViewController].photo =self.selectedPhoto;  
    } else {
        [self performSegueWithIdentifier:@"Show Favourite Photo View" sender:self];
    }
    
    
}

@end
