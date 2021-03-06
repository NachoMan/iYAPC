//
//  SessionDayViewController.m
//  iYAPC
//
//  Created by Michael Nachbaur on 11-01-18.
//  Copyright 2011 Decaf Ninja Software. All rights reserved.
//

#import "SessionDayViewController.h"
#import "SessionModel.h"
#import "SessionDetailViewController.h"

@interface SessionDayViewController (Private)

- (void)updateTabInfo;

@end

@implementation SessionDayViewController
@synthesize dayObject = _dayObject;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	if (self) {
		[self addObserver:self forKeyPath:@"dayObject" options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)dealloc {
	[self removeObserver:self forKeyPath:@"dayObject"];
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ([keyPath isEqualToString:@"dayObject"]) {
		self.entityName = @"Session";
		self.sectionKeyPath = @"startTimeSection";
		self.sortDescriptors = [NSArray arrayWithObjects:@"startTime", @"title", nil];
		self.fetchPredicate = [NSPredicate predicateWithFormat:@"eventDay = %@", self.dayObject];
		self.cacheName = [NSString stringWithFormat:@"SessionListing%@", [self.dayObject objectID]];
		[self updateTabInfo];
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark -
#pragma mark Private methods

- (void)updateTabInfo {
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateFormat:@"LLL d"];
	NSString *fullDay = [dateFormatter stringFromDate:self.dayObject.eventDate];
	
	[dateFormatter setDateFormat:@"ccc"];
	NSString *shortDay = [[dateFormatter stringFromDate:self.dayObject.eventDate] uppercaseString];
	
	self.navigationItem.title = fullDay;
	self.tabBarItem.title = fullDay;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SessionModel *session = (SessionModel*)[self.fetchedResultsController objectAtIndexPath:indexPath];
	if (![session isMemberOfClass:[SessionModel class]])
		return;
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterNoStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	
	NSString *startTimeStr = [dateFormatter stringFromDate:session.startTime];
	
    cell.textLabel.text = session.title;
	cell.detailTextLabel.text = startTimeStr;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark -
#pragma mark Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cacheName];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:self.cacheName] autorelease];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	SessionModel *selectedObject = (SessionModel*)[self.fetchedResultsController objectAtIndexPath:indexPath];

	SessionDetailViewController *controller = [[[SessionDetailViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
	controller.managedObjectContext = self.managedObjectContext;
	controller.sessionObject = selectedObject;
	
    [self.navigationController pushViewController:controller animated:YES];
}

@end

