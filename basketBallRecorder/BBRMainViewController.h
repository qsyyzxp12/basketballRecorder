//
//  BBRMainViewController.h
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/22.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBRMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property UITableView *playerListTableView;
@property UITableView *playerDataTableView;
@property NSMutableArray* playerDataArray;
@property NSArray* attackWaySet;
@property NSArray* attackWayKeySet;
@property NSArray* playerNoSet;
@property int playerCount;
@property int playerSelectedIndex;
@property int zoneNo;
@property NSString* keyForScoreCount;
@property NSString* keyForTryCount;
@property UIAlertController* scoreOrNotAlert;
@property UIAlertController* attackWayAlert;
@end
