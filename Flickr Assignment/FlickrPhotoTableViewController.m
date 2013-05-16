//
//  FlickrPhotoTableViewController.m
//  Flickr Assignment
//
//  Created by danielle vass on 14/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrPhotoTableViewController.h"
#import "FlickrFetcher.h"
#import "FlickrPhotoViewController.h"
#import "MapViewController.h"

@interface FlickrPhotoTableViewController ()
@property NSDictionary *selectedPhoto;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation FlickrPhotoTableViewController
@synthesize selectedPhoto = _selectedPhoto;
@synthesize place = _place;
@synthesize photos = _photos;
@synthesize spinner = _spinner;

#pragma mark - Page setup

- (void)setPlace:(NSDictionary *)place
{
    _place = place;
}

- (void)setPhotos:(NSArray *)photos
{
    if (_photos != photos) {
        _photos = photos;
        // Model changed, so update our View (the table)
        if (self.tableView.window) [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.spinner startAnimating];
    self.spinner.hidesWhenStopped = TRUE;
    
    [super viewDidAppear:YES];
    
    NSString *longName = [self.place objectForKey:FLICKR_PLACES_TITLE];
    NSArray *nameBits = [longName componentsSeparatedByString:@", "];
    
    self.title = [nameBits objectAtIndex:0];
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *photos = [FlickrFetcher photosInPlace:self.place maxResults:50];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = photos;
            [self.spinner stopAnimating];
        });
    });
    dispatch_release(downloadQueue);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Table View Data
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *place = [self.photos objectAtIndex:indexPath.row];
    NSString *title = [place objectForKey:FLICKR_PHOTO_TITLE];
    NSString *description = [place objectForKey:@"tags"];
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = description;
    
    
    if ([title isEqualToString:@""]) {
        cell.textLabel.text = description;
        cell.detailTextLabel.text = @"";
        
        if ([description isEqualToString:@""]) {
            cell.textLabel.text = @"unknown";
            cell.detailTextLabel.text =@"";
            
        }
    }
     
    
    return cell;

}


#pragma mark - Seques

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Photo View"]) {
        [segue.destinationViewController setPhoto:self.selectedPhoto];
    } else if ([segue.identifier isEqualToString:@"list to map"]) {
        [segue.destinationViewController setPhotos:self.photos];
    }
  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    _selectedPhoto = [self.photos objectAtIndex:indexPath.row];
    
    if ([self splitViewFlickrPhotoViewController]) {
        [self splitViewFlickrPhotoViewController].photo =self.selectedPhoto;  
    } else {
        [self performSegueWithIdentifier:@"Show Photo View" sender:self];
    }
    
}
- (FlickrPhotoViewController *)splitViewFlickrPhotoViewController {
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[FlickrPhotoViewController class]]) {
        gvc = nil;
    }
    return gvc;
}

@end
