//
//  ViewController.m
//  FOBookCollection
//
//  Created by Fábio Daniel Pinto Martins de Oliveira on 14/09/14.
//  Copyright (c) 2014 Fábio Oliveira. All rights reserved.
//

#import "FOBooksListViewController.h"

#import "FOBooksService.h"
#import "FOBook+Custom.h"
#import "FOBookCell.h"

#import "FOContinuousLoadingView.h"

#import "CoreData+MagicalRecord.h"
#import "AFNetworking.h"
#import "UIRefreshControl+AFNetworking.h"
#import "UIImageView+AFNetworking.h"

#define REQUEST_PAGE_SIZE 27
#define CATEGORY_ID @"Wma8RpqpC6UcWye2U8qUg-6a21w"
#define LOAD_PERCENTAGE .95f

@interface FOBooksListViewController () <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *allBooks;
@property (nonatomic, strong) NSMutableArray *pendingUpdates;

@property (nonatomic, weak) IBOutlet UIRefreshControl *refreshControl;
@property (nonatomic, weak) FOContinuousLoadingView *continuousLoadingView;

@property (nonatomic) NSInteger currentPage;
@property (nonatomic) FOContinuousLoadingState pageState;
@end

@implementation FOBooksListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.collectionView addSubview:self.refreshControl];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl beginRefreshing];
    [self.refreshControl endRefreshing];

    [self refreshData];
    
    [self startObservingBookServiceNotifications];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)dealloc {
    self.continuousLoadingView = nil;
    [self stopObservingBookServiceNotifications];
    [self.refreshControl setRefreshingWithStateOfOperation:nil];
}

#pragma mark Actions
- (IBAction)didPullRefresh:(id)sender {
    [self refreshData];
}

- (IBAction)needsMoreResults:(id)sender {
    if (self.pageState == FOContinuousLoadingActive || self.pageState == FOContinuousLoadingError || self.pageState == FOContinuousLoadingReady) {
        [self requestData];
    }
}

#pragma mark Service notifications
- (void)startObservingBookServiceNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleBookServiceNotification:)
                                                 name:FOBooksServiceNotification
                                               object:nil];
}

- (void)stopObservingBookServiceNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:FOBooksServiceNotification
                                                  object:nil];
}

- (void)handleBookServiceNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:FOBooksServiceNotification]) {
        if ([notification.userInfo[FOServiceNotificationTypeKey] isEqualToString:FOServiceNotificationTypeStart]) {
            AFHTTPRequestOperation *operation = notification.userInfo[FOServiceNotificationOperationKey];
            
            if (self.currentPage == 1) {
                [self.refreshControl setRefreshingWithStateOfOperation:operation];
            }
            self.pageState = FOContinuousLoadingActive;
        }
        else if ([notification.userInfo[FOServiceNotificationTypeKey] isEqualToString:FOServiceNotificationTypeSuccess]) {
            NSArray *books = notification.userInfo[FOServiceNotificationObjectsKey];
            [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                
            }];
            if (books.count < REQUEST_PAGE_SIZE) {
                if (self.currentPage == 1) {
                    self.pageState = FOContinuousLoadingNoResults;
                }
                else {
                    self.pageState = FOContinuousLoadingNoMoreResults;
                }
            }
            else {
                self.pageState = FOContinuousLoadingReady;
            }
        }
        else if ([notification.userInfo[FOServiceNotificationTypeKey] isEqualToString:FOServiceNotificationTypeFail]) {
            self.pageState = FOContinuousLoadingError;
        }
        self.continuousLoadingView.loadingState = self.pageState;
    }
}

#pragma mark Data source
- (NSFetchedResultsController *)allBooks {
    if (!_allBooks) {
        NSFetchRequest *request = [FOBook MR_requestAllSortedBy:@"position"
                                                      ascending:YES
                                                  withPredicate:[NSPredicate predicateWithValue:YES]
                                                      inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
        request.fetchBatchSize = 30;
        
        _allBooks = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                        managedObjectContext:[NSManagedObjectContext MR_contextForCurrentThread]
                                                          sectionNameKeyPath:nil
                                                                   cacheName:nil];
        _allBooks.delegate = self;
        
        if (![_allBooks performFetch:NULL]) {
            NSLog(@"Oh my...");
        }
    }
    
    return _allBooks;
}

- (void)refreshData {
    self.currentPage = 0;
    self.pageState = FOContinuousLoadingReady;
    [self requestData];
}

- (void)requestData {
    self.currentPage++;
    [FOBooksService requestBooksInCategory:CATEGORY_ID
                                withPageId:self.currentPage
                               andPageSize:REQUEST_PAGE_SIZE
                                 inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

#pragma mark - Protocols
#pragma mark UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if ([[self.allBooks sections] count] > 0) {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.allBooks sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
    else
    {
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FOBookCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FOBookCell" forIndexPath:indexPath];
    FOBook *book = [self.allBooks objectAtIndexPath:indexPath];
    
    if (book.coverImageUrl.length) {
        [cell.coverImageView setImageWithURL:[FOBook imageURLWithString:book.coverImageUrl forSize:cell.bounds.size]];
    }
    cell.titleLabel.text = book.title;
    cell.authorLabel.text = book.author;
    [cell setNeedsLayout];
    
    float itemPercentage = (float)indexPath.row/(float)[self collectionView:collectionView numberOfItemsInSection:indexPath.section];
    if (itemPercentage > LOAD_PERCENTAGE) {
        [self needsMoreResults:self];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    self.continuousLoadingView = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                withReuseIdentifier:@"FOContinuousLoadingView"
                                                                                       forIndexPath:indexPath];
    self.continuousLoadingView.loadingState = self.pageState;
    
    [self needsMoreResults:self];
    
    return self.continuousLoadingView;
}

#pragma mark UICollectionViewDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    FOBook *book = [self.allBooks objectAtIndexPath:indexPath];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat availableSpace = self.collectionView.bounds.size.width - (layout.sectionInset.left + layout.sectionInset.right) - layout.minimumInteritemSpacing*2.f;
    CGFloat itemWidth = floorf(availableSpace/3.f);
    return CGSizeMake(itemWidth, itemWidth / book.coverImageAspectRatio.floatValue);
}

#pragma mark NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    self.pendingUpdates = [NSMutableArray array];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UICollectionView *collectionView = self.collectionView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
        {
            [self.pendingUpdates addObject:^{
                [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeDelete:
        {
            [self.pendingUpdates addObject:^{
                [collectionView deleteItemsAtIndexPaths:@[indexPath]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeUpdate:
        {
            [self.pendingUpdates addObject:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeMove:
        {
            [self.pendingUpdates addObject:^{
                [collectionView moveItemAtIndexPath:indexPath
                                        toIndexPath:newIndexPath];
            }];
            break;
        }
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.collectionView performBatchUpdates:^{
        for (void(^block)(void) in self.pendingUpdates) {
            block();
        }
    }
                                  completion:^(BOOL finished) {
                                      self.pendingUpdates = nil;
                                  }];
}

@end