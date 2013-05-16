//
//  FlickrPlacesTableViewController.m
//  Flickr Assignment
//
//  Created by danielle vass on 15/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FlickrPlacesTableViewController.h"
#import "FlickrFetcher.h"
#import "FlickrPhotoTableViewController.h"
#import "SplitViewBarButtonItemPresenter.h"
#import "FlickrPhotoViewController.h"

@interface FlickrPlacesTableViewController ()
@property NSDictionary *selectedPlace;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation FlickrPlacesTableViewController

@synthesize places = _places;
@synthesize selectedPlace = _selectedPlace;
@synthesize spinner = _spinner;

#pragma mark - Split View methods
- (id <SplitViewBarButtonItemPresenter>)splitViewBarButtonItemPresenter {
    id detailVC = [self.splitViewController.viewControllers lastObject];
    if (![detailVC conformsToProtocol:@protocol(SplitViewBarButtonItemPresenter)]) {
        detailVC = nil;
    }
    return detailVC;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.splitViewController.delegate = (id<UISplitViewControllerDelegate>)self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
    return [self splitViewBarButtonItemPresenter] ? UIInterfaceOrientationIsPortrait(orientation) : NO;
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    barButtonItem.title = @"List";
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = barButtonItem;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    [self splitViewBarButtonItemPresenter].splitViewBarButtonItem = nil;
}

- (void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem = [[self splitViewBarButtonItemPresenter] splitViewBarButtonItem];
    [[self splitViewBarButtonItemPresenter] setSplitViewBarButtonItem:nil];
    if (splitViewBarButtonItem) {
        [destinationViewController setSplitViewBarButtonItem:splitViewBarButtonItem];
    }
}

- (FlickrPhotoViewController *)splitViewFlickrPhotoViewController {
    id gvc = [self.splitViewController.viewControllers lastObject];
    if (![gvc isKindOfClass:[FlickrPhotoViewController class]]) {
        gvc = nil;
    }
    return gvc;
}

#pragma mark - load the page
- (IBAction)refresh:(id)sender
{
    [self refreshData];
}

- (void) refreshData{
    [self.spinner startAnimating];
    self.spinner.hidesWhenStopped = TRUE;
    
    dispatch_queue_t downloadQueue = dispatch_queue_create("flickr downloader", NULL);
    dispatch_async(downloadQueue, ^{
        NSArray *places = [FlickrFetcher topPlaces];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            self.places = [self orderDataModel:places];
            
        });
    });
    dispatch_release(downloadQueue);
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


#pragma mark - places setter
- (void)setPlaces:(NSArray *)places
{
    if (_places != places) {
        _places = places;
                // Model changed, so update our View (the table)
        if (self.tableView.window) [self.tableView reloadData];
    }
}

-(NSArray *)orderDataModel:(NSArray *)places
{
    NSMutableArray *newPlaces = [places mutableCopy];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:FLICKR_PLACES_TITLE
                                                 ascending:YES];
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [newPlaces sortUsingDescriptors:sortDescriptors];
    return newPlaces;
}



#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.places count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Flickr Place";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *place = [self.places objectAtIndex:indexPath.row];
    NSString *longName = [place objectForKey:FLICKR_PLACES_TITLE];
    NSArray *nameBits = [longName componentsSeparatedByString:@", "];
    
    cell.textLabel.text = [nameBits objectAtIndex:0];
    cell.detailTextLabel.text = [longName substringFromIndex:[cell.textLabel.text length] +2];
    return cell;

}

#pragma mark - Seques

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show Photo Table View"]) {
        [segue.destinationViewController setPlace:self.selectedPlace];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedPlace = [self.places objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"Show Photo Table View" sender:self];
}

@end
