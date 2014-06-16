//
//  MasterViewController.m
//  ARSSReader
//
//  Created by Marin Todorov on 29/10/2012.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "TableHeaderView.h"
#import "RSSLoader.h"
#import "RSSItem.h"

@interface MasterViewController ()
{
    NSMutableArray *_objects;
    NSMutableArray *_nytObjects;
    NSURL* feedURL;
    NSURL* twoURL;
    UIRefreshControl* refreshControl;
}
@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //configuration
    self.title = @"Tim's RSS Reader";
    feedURL = [NSURL URLWithString:@"http://images.apple.com/main/rss/hotnews/hotnews.rss"];
    twoURL = [NSURL URLWithString:@"http://rss.nytimes.com/services/xml/rss/nyt/HomePage.xml"];
    
    //add refresh control to the table view
    refreshControl = [[UIRefreshControl alloc] init];
    
    [refreshControl addTarget:self
                       action:@selector(refreshInvoked:forState:)
             forControlEvents:UIControlEventValueChanged];
    
    NSString* fetchMessage = [NSString stringWithFormat:@"Fetching: %@",feedURL];
    NSString* twoFetch = [NSString stringWithFormat:@"Fetching: %@",twoURL];
    
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:fetchMessage
                                                                     attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica" size:11.0]}];
    
    [self.tableView addSubview: refreshControl];
    
    //add the header
    self.tableView.tableHeaderView = [[TableHeaderView alloc] initWithText:@"fetching rss feed"];
    
    [self refreshFeed];
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state
{
    [self refreshFeed];
}

-(void)refreshFeed
{
    RSSLoader* rss = [[RSSLoader alloc] init];
    [rss fetchRssWithURL:feedURL
                complete:^(NSString *title, NSArray *results) {

                    //completed fetching the RSS
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //UI code on the main queue
                     //   [(TableHeaderView*)self.tableView.tableHeaderView setText:title];
                        
                        _objects = results;
                       // NSLog(@"_objects = %@", _objects);
//                        NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndex:1];
//                        [indexes addIndex:0];
//                        [indexes addIndex:1];
//                        [indexes addIndex:2];
//                        [indexes addIndex:3];
//                        
//                        [_objects removeObjectsInRange:(NSRange){6,14}];
//                        [_objects removeObjectsAtIndexes:indexes];
                        [self.tableView reloadData];
                        
                        // Stop refresh control
                        [refreshControl endRefreshing];
                    });
                }];
    
    RSSLoader* rssTwo = [[RSSLoader alloc] init];
    [rssTwo fetchRssWithURL:twoURL
                complete:^(NSString *NYTtitle, NSArray *nytResults) {
                    
                    //completed fetching the RSS
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //UI code on the main queue
                    //    [(TableHeaderView*)self.tableView.tableHeaderView setText:title];
                     //   NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 25)];
                        _nytObjects = nytResults;

                        [_objects addObjectsFromArray:nytResults];
                        NSLog(@"a = %@", _objects);
                        
                        //     NSLog(@"x = %@", _objects);
                      //  [_objects insertObjects:nytResults atIndexes:indexSet];   THIS MIGHT BE USEFUL
                     //   NSLog(@"_objects = %@", _objects);
                     //    NSLog(@"_objects = %@", _nytObjects);
//                        NSMutableIndexSet *indexes = [NSMutableIndexSet indexSetWithIndex:1];
//                        [indexes addIndex:0];
//                        [indexes addIndex:1];
//                        [indexes addIndex:2];
//                        [indexes addIndex:3];
//                        
//                        [_objects removeObjectsInRange:(NSRange){6,14}];
//                        [_objects removeObjectsAtIndexes:indexes];
                        [self.tableView reloadData];
                        
                        // Stop refresh control
                        [refreshControl endRefreshing];
                    });
                }];

    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// So return x when you figure out which array is out of bounds
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    long x;
    x = _objects.count;
    return x;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    RSSItem *object = _objects[indexPath.row];
    cell.textLabel.attributedText = object.cellMessage;
    cell.textLabel.numberOfLines = 0;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RSSItem *item = [_objects objectAtIndex:indexPath.row];
    CGRect cellMessageRect = [item.cellMessage boundingRectWithSize:CGSizeMake(200,10000)
                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                            context:nil];
    return cellMessageRect.size.height;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RSSItem *object = _objects[indexPath.row];
      //  NSLog(@"object = %@", _objects);
        [[segue destinationViewController] setDetailItem:object];
    }
}

@end
