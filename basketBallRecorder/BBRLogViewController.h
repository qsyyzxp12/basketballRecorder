//
//  ViewController.h
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/22.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBRLogViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property UITableView *BBRtableView;
@property UITextField *editingTextField;
@property NSMutableArray* textFieldArray;
@property int playerCount;
@property NSMutableArray* playerNoSet;
@property NSString* myTeamName;
@property NSString* opponentName;
@property NSString* gameType;
@property BOOL isSBLGame;
@property int sessionNo;
@property int gameNo;
@property UIView* teamNameView;
@property UIView* fogView;
@end

