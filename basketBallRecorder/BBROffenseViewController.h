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
#import <DropboxSDK/DropboxSDK.h>

@interface BBROffenseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DBRestClientDelegate>
@property UITableView *playerListTableView;
@property UITableView *playerOnFloorListTableView;
@property UITableView *playerDataTableView;
@property UITableView *detailTableView;
@property NSMutableArray *playerOnFloorDataArray;
@property NSMutableArray* playerDataArray;
@property NSMutableArray* OldPlayerDataArray;
@property NSMutableArray* timeLineReordeArray;
@property NSMutableArray* fileNamesInDropbox;
@property NSArray* attackWaySet;
@property NSArray* attackWayKeySet;
@property NSArray* playerNoSet;
@property NSArray* normalDetailItemKeyArray;
@property NSArray* normalDetailTitleArray;
@property NSArray* secondDetailItemKeyArray;
@property NSArray* secondDetailTitleArray;
@property NSArray* PNRDetailItemKeyArray;
@property NSArray* PNRDetailTitleArray;
@property NSArray* PUDetailItemKeyArray;
@property NSArray* PUDetailTitleArray;
@property NSArray* TotalDetailItemArray;
@property NSArray* TotalDetailTitleArray;
@property NSArray* turnOverArray;
@property BOOL isShowZoneGrade;
@property BOOL isTmpPlistExist;
@property BOOL isRecordMode;
@property BOOL isTimerRunning;
@property BOOL isDetailShowing;
@property BOOL isPPPXlsxFileExistInDropbox;
@property BOOL isShotChartXlsxFileExistInDropbox;
@property BOOL isLoadMetaFinished;
@property BOOL isDownloadPPPXlsxFileFinished;
@property BOOL isDownloadShotChartXlsxFileFinished;
@property BOOL isLoadingRootMeta;
@property BOOL isFolderExistAlready;
@property int uploadFilesCount;
@property int playerCount;
@property int playerSelectedIndex;
@property int zoneNo;
@property int quarterNo;
@property int showOldRecordNo;
@property int timeCounter;
@property int attackWayNo;
@property int ptr;
@property UIAlertController* attackWayAlert;
@property UIAlertController* nextQuarterAlert;
@property UIAlertController* playoffOrNotAlert;
@property UIAlertController* finishOrNotAlert;
@property UIAlertController* bonusAlert;
@property UIImageView* backgroundImageView;
@property NSString* tmpPlistPath;
@property NSString* opponentName;
@property NSString* recordName;
@property NSString* keyOfAttackWay;
@property NSString* keyOfDetail;
@property UIButton* undoButton;
@property UIButton* switchModeButton;
@property UIButton* nextQuarterButton;
@property UIButton* lastQuarterButton;
@property UIButton* timeButton;
@property NSTimer* timer;
@property UIView* spinView;
@property UILabel* loadingLabel;
@property UIActivityIndicatorView* spinner;
@property int bar_height;
@property (nonatomic, strong) DBRestClient *restClient;
@end
