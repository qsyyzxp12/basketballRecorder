//
//  BBRMainViewController.h
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/22.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BBRLogViewController.h"
#import "BBRMenuViewController.h"

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
@property int quarterNo;
@property NSString* keyForSearch;
@property UIAlertController* madeOrNotAlert;
@property UIAlertController* attackWayAlert;
@property UIAlertController* resultAlert;
@property UIAlertController* bonusAlertFor2Chance;
@property UIAlertController* bonusAlertFor3Chance;
@property UIAlertController* andOneAlert;
@property UIImageView* backgroundImageView;
@property BOOL isShowZoneGrade;
@property NSString* tmpPlistPath;
@property BOOL isTmpPlistExist;
@property NSString* recordName;
@property int showOldRecordNo;
/*
@property int zoneNoOfLastRecord;
@property int playerNoOfLastRecord;
@property int offenseWayOfLastRecord;
@property BOOL attemptInLastRecord;
@property BOOL madeInLastRecord;
@property BOOL foulInLastRecord;
@property BOOL turnOverInLastRecord;
@property int scoreGotInLastRecord;
 */
@end
