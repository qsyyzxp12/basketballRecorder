//
//  ViewController.h
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/22.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KEY_FOR_LAST_RECORD_QUARTER @"LastRecordQuarter"
#define KEY_FOR_PLAYER_NO_SET @"PlayerNoSet"
typedef enum {ZERO, FIRST, SECOND, THIRD, FORTH, END} LastRecordQuarter;

@interface BBRLogViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property UITableView *BBRtableView;
@property UITextField *editingTextField;
@property NSMutableArray* textFieldArray;
@property int playerCount;
@property NSMutableArray* playerNoSet;
@property LastRecordQuarter lastRecordQuarter;
@property UIAlertController* dirtyStatusAlert;
@property UIAlertController* cleanStatusAlert;
@property BOOL loadOldGrade;
@end

