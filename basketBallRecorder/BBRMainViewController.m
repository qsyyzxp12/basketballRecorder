//
//  BBRMainViewController.m
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/22.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "BBRMainViewController.h"
#import "BBRTableViewCell.h"

#define TITLE_CELL_HEIGHT 30
#define CELL_HEIGHT 40
#define CELL_WIDTH 60

#define BACKGROUND_WIDTH 373
#define BACKGROUND_HEIGHT 245
#define IMAGE_SCALE 0.465
#define RECORD_LABEL_HEIGHT 23
#define SIDE_PADDING_RATE 0.25      //for zone 6, 10
#define TOP_PADDING_RATE1 0.1       //for zone 1, 2, 4, 5, 7, 9, 11
#define TOP_PADDING_RATE2 0.3       //for zone 3
#define TOP_PADDING_RATE3 0.6       //for zone 6, 10
#define TOP_PADDING_RATE4 0         //for zone 8
#define NO_TABLEVIEW_TAG -1
#define PLAYER_GRADE_TABLEVIEW_TAG -2
#define PLAYER_GRADE_TABLECELL_HEIGHT 30
#define BACKGROUND_IMAGEVIEW_TAG -3
#define BAR_HEIGHT 33

#define KEY_FOR_ATTEMPT_COUNT @"attempCount"
#define KEY_FOR_MADE_COUNT @"madeCount"
#define KEY_FOR_FOUL_COUNT @"foulCount"
#define KEY_FOR_TURN_OVER_COUNT @"turnOverCount"
#define KEY_FOR_SCORE_GET @"scoreGet"

#define forQuarter 1
#define forTotal 0

@interface BBRMainViewController ()

@end

@implementation BBRMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tmpPlistPath = [NSString stringWithFormat:@"%@/Documents/tmp.plist", NSHomeDirectory()];
    self.isShowZoneGrade = YES;
    self.playerSelectedIndex = 0;
    self.zoneNo = 0;
    self.quarterNo = 0;
  
    self.attackWaySet = [[NSArray alloc] initWithObjects:@"Isolation", @"Spot Up", @"PS", @"PC", @"PR", @"PPS", @"PPC", @"Catch&Shoot", @"Fast Break", @"Low Post", @"Second", @"Drive", @"Cut", @"Bonus", nil];
    self.attackWayKeySet = [[NSArray alloc] initWithObjects:
                            @"isolation", @"spotUp", @"PS", @"PC", @"PR", @"PPS", @"PPC", @"CS",
                            @"fastBreak", @"lowPost", @"second", @"drive", @"cut", nil];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.rightBarButtonItem.title = @"下一節";
    self.navigationItem.rightBarButtonItem.target = self;
    self.navigationItem.rightBarButtonItem.action = @selector(nextQuarterButtonClicked);
    
    if(self.isTmpPlistExist)
        [self reloadPlayerGradeFromTmpPlist];
    else if(self.showOldRecordNo)
        [self reloadPlayerGradeFromRecordPlist];
    else
    {
        [self newPlayerGradeDataStruct];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] init];
        self.navigationItem.leftBarButtonItem.title = @"＜球員登入";
        self.navigationItem.leftBarButtonItem.target = self;
        self.navigationItem.leftBarButtonItem.action = @selector(backButtonClicked);
    }
        
    
    int tableViewHeight = TITLE_CELL_HEIGHT + CELL_HEIGHT * (self.playerCount+1) + BAR_HEIGHT;
    if (tableViewHeight + 20 > self.view.frame.size.height)
        tableViewHeight = self.view.frame.size.height - 20;
    
    self.playerListTableView = [[UITableView alloc] initWithFrame:CGRectMake(20, 10, CELL_WIDTH, tableViewHeight)];
    self.playerListTableView.delegate = self;
    self.playerListTableView.dataSource = self;
    self.playerListTableView.tag = NO_TABLEVIEW_TAG;
    
    [self.view addSubview:self.playerListTableView];
    
    [self drawPicture];
    [self constructAlertControllers];
    
    if(self.quarterNo == 4)
        [self finishButtonClicked];
}

-(void) reloadPlayerGradeFromRecordPlist
{
    NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
    NSArray* recordPlistArray = [NSArray arrayWithContentsOfFile:recordPlistPath];
    NSDictionary* dataDic = [recordPlistArray objectAtIndex:self.showOldRecordNo-1 ];
    self.playerDataArray = [dataDic objectForKey:KEY_FOR_GRADE];
    self.playerNoSet = [dataDic objectForKey:KEY_FOR_PLAYER_NO_SET];
    self.quarterNo = 4;
    self.playerCount = (int)[self.playerNoSet count];
    
    self.navigationItem.rightBarButtonItem.title = @"進攻分類";
    self.navigationItem.rightBarButtonItem.action = @selector(showOffenseGrade);
    self.navigationItem.title = @"第一節成績";
}

-(void) reloadPlayerGradeFromTmpPlist
{
    NSMutableDictionary* tmpPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.tmpPlistPath];
    self.playerDataArray = [tmpPlistDic objectForKey:KEY_FOR_GRADE];
    self.playerNoSet = [tmpPlistDic objectForKey:KEY_FOR_PLAYER_NO_SET];
    self.quarterNo = [[tmpPlistDic objectForKey:KEY_FOR_LAST_RECORD_QUARTER] intValue];
    self.playerCount = (int)[self.playerNoSet count];
    
    if(self.quarterNo == 0)
        self.navigationItem.title = @"第一節";
    else if (self.quarterNo == 1)
        self.navigationItem.title = @"第二節";
    else if(self.quarterNo == 2)
        self.navigationItem.title = @"第三節";
    else if(self.quarterNo == 3)
    {
        self.navigationItem.title = @"第四節";
        self.navigationItem.rightBarButtonItem.title = @"完成";
        self.navigationItem.rightBarButtonItem.action = @selector(finishButtonClicked);
    }
}

-(void) newPlayerGradeDataStruct
{
    self.playerDataArray = [NSMutableArray arrayWithCapacity:5];
    for(int l=0; l<5; l++)
    {
        NSMutableArray* quarterData = [NSMutableArray arrayWithCapacity:self.playerCount+1];
        for(int i=0; i<self.playerCount+1; i++)
        {
            NSMutableDictionary* playerDataItem = [[NSMutableDictionary alloc] init];
            
            if(i < [self.playerNoSet count])
                [playerDataItem setObject:[self.playerNoSet objectAtIndex:i] forKey:@"no"];
            else
                [playerDataItem setObject:@"Team" forKey:@"no"];
            
            [playerDataItem setObject:[NSString stringWithFormat:@"%d", l+1] forKey:@"QUARTER"];
            for(int k=0; k<12; k++)
            {
                NSMutableDictionary* madeOrAttempt = [[NSMutableDictionary alloc] init];
                [madeOrAttempt setObject:@"0" forKey:KEY_FOR_MADE_COUNT];
                [madeOrAttempt setObject:@"0" forKey:KEY_FOR_ATTEMPT_COUNT];
                
                NSString* zoneKey = [NSString stringWithFormat:@"zone%d", k+1];
                [playerDataItem setObject:madeOrAttempt forKey:zoneKey];
            }
            for (int j=0; j<[self.attackWayKeySet count]; j++)
            {
                NSMutableDictionary* result2 = [[NSMutableDictionary alloc] init];
                [result2 setObject:@"0" forKey:KEY_FOR_MADE_COUNT];
                [result2 setObject:@"0" forKey:KEY_FOR_ATTEMPT_COUNT];
                [result2 setObject:@"0" forKey:KEY_FOR_FOUL_COUNT];
                [result2 setObject:@"0" forKey:KEY_FOR_TURN_OVER_COUNT];
                [result2 setObject:@"0" forKey:KEY_FOR_SCORE_GET];
                [playerDataItem setObject:result2 forKey:[self.attackWayKeySet objectAtIndex:j]];
            }
            
            [playerDataItem setObject:@"0" forKey:@"totalScoreGet"];
            [quarterData addObject:playerDataItem];
        }
        [self.playerDataArray addObject:quarterData];
    }
    
    NSLog(@"%@", self.playerDataArray);
    
    NSString* src = [[NSBundle mainBundle] pathForResource:@"tmp" ofType:@"plist"];
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    if(![fm fileExistsAtPath:self.tmpPlistPath])
        [fm copyItemAtPath:src toPath:self.tmpPlistPath error:nil];
    
    NSMutableDictionary* tmpPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.tmpPlistPath];
    
    [tmpPlistDic setObject:[NSNumber numberWithInt:1] forKey:KEY_FOR_LAST_RECORD_QUARTER];
    [tmpPlistDic setObject:self.playerDataArray forKey:KEY_FOR_GRADE];
    [tmpPlistDic setObject:self.playerNoSet forKey:KEY_FOR_PLAYER_NO_SET];
    [tmpPlistDic setObject:self.recordName forKey:KEY_FOR_NAME];
    
    [tmpPlistDic writeToFile:self.tmpPlistPath atomically:YES];
    
    self.navigationItem.title = @"第一節";
}

-(void)backButtonClicked
{
    UIAlertController* backAlert = [UIAlertController alertControllerWithTitle:@"注意" message:@"返回後目前紀錄的資料都將消失，確定要返回嗎？" preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){}];
    [backAlert addAction:yesAction];
    [backAlert addAction:noAction];
    
    NSFileManager* fm = [[NSFileManager alloc] init];
    if([fm fileExistsAtPath:self.tmpPlistPath])
        [fm removeItemAtPath:self.tmpPlistPath error:nil];
    
    [self presentViewController:backAlert animated:YES completion:nil];
}

-(void) nextQuarterButtonClicked
{
    self.quarterNo++;
    [self updateZoneGradeView];
    
    NSMutableDictionary* tmpPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.tmpPlistPath];
    [tmpPlistDic setObject:[NSNumber numberWithInt:self.quarterNo+1] forKey:KEY_FOR_LAST_RECORD_QUARTER];
    
    [tmpPlistDic writeToFile:self.tmpPlistPath atomically:YES];
    
    if (self.quarterNo == 1)
        self.navigationItem.title = @"第二節";
    else if(self.quarterNo == 2)
        self.navigationItem.title = @"第三節";
    else
    {
        self.navigationItem.title = @"第四節";
        self.navigationItem.rightBarButtonItem.title = @"完成";
        self.navigationItem.rightBarButtonItem.action = @selector(finishButtonClicked);
    }
}

- (void) finishButtonClicked
{
    self.quarterNo++;
    NSMutableDictionary* tmpPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.tmpPlistPath];
    [tmpPlistDic setObject:[NSNumber numberWithInt:5] forKey:KEY_FOR_LAST_RECORD_QUARTER];
    
    [tmpPlistDic writeToFile:self.tmpPlistPath atomically:YES];
    
    self.isShowZoneGrade = YES;
    self.undoButton.hidden = YES;
    
    self.navigationItem.rightBarButtonItem.title = @"進攻分類";
    self.navigationItem.rightBarButtonItem.action = @selector(showOffenseGrade);
    self.navigationItem.title = @"第一節成績";
    
    for(int i=1; i<13; i++)
    {
        UIImageView* zone = (UIImageView*)[self.view viewWithTag:i];
        [zone setUserInteractionEnabled:NO];
    }
    if (self.zoneNo)
        ((UIImageView*)[self.view viewWithTag:self.zoneNo]).highlighted = NO;
    
    if(self.quarterNo == 4)
    {
        //Caculate the Total Score of the Team
        NSMutableArray* totalGrade = [self.playerDataArray objectAtIndex:4];
        NSMutableDictionary* totalGradeOfTeam = [totalGrade objectAtIndex:self.playerCount];
        
        for(int i=1; i<=12; i++)
        {
            NSString* keyForZone = [NSString stringWithFormat:@"zone%d", i];
            int madeCount = 0, attemptCount = 0;
            for(int j=0; j<self.playerCount; j++)
            {
                NSDictionary* totalGradeOfPlayer = [totalGrade objectAtIndex:j];
                NSDictionary* zoneGrade = [totalGradeOfPlayer objectForKey:keyForZone];
                madeCount += [[zoneGrade objectForKey:KEY_FOR_MADE_COUNT] intValue];
                attemptCount += [[zoneGrade objectForKey:KEY_FOR_ATTEMPT_COUNT] intValue];
            }
            
            NSMutableDictionary* zoneGradeOfTotalGradeOfTeam = [totalGradeOfTeam objectForKey:keyForZone];
            [zoneGradeOfTotalGradeOfTeam setObject:[NSString stringWithFormat:@"%d", madeCount] forKey:KEY_FOR_MADE_COUNT];
            [zoneGradeOfTotalGradeOfTeam setObject:[NSString stringWithFormat:@"%d", attemptCount] forKey:KEY_FOR_ATTEMPT_COUNT];
            
            [totalGradeOfTeam setObject:zoneGradeOfTotalGradeOfTeam forKey:keyForZone];
        }
        
        for (int i=0; i<[self.attackWayKeySet count]; i++)
        {
            NSString* keyForOffense = [self.attackWayKeySet objectAtIndex:i];
            int madeCount = 0, attemptCount = 0, foulCount = 0, turnOverCount = 0, scoreGet = 0;
            for(int j=0; j<self.playerCount; j++)
            {
                NSDictionary* totalGradeOfPlayer = [totalGrade objectAtIndex:j];
                NSDictionary* offenseGrade = [totalGradeOfPlayer objectForKey:keyForOffense];
                madeCount += [[offenseGrade objectForKey:KEY_FOR_MADE_COUNT] intValue];
                attemptCount += [[offenseGrade objectForKey:KEY_FOR_ATTEMPT_COUNT] intValue];
                foulCount += [[offenseGrade objectForKey:KEY_FOR_FOUL_COUNT] intValue];
                turnOverCount += [[offenseGrade objectForKey:KEY_FOR_TURN_OVER_COUNT] intValue];
                scoreGet += [[offenseGrade objectForKey:KEY_FOR_SCORE_GET] intValue];
            }
            
            NSMutableDictionary* offenseGradeOfTotalGradeOfTeam = [totalGradeOfTeam objectForKey:keyForOffense];
            [offenseGradeOfTotalGradeOfTeam setObject:[NSString stringWithFormat:@"%d", madeCount] forKey:KEY_FOR_MADE_COUNT];
            [offenseGradeOfTotalGradeOfTeam setObject:[NSString stringWithFormat:@"%d", attemptCount] forKey:KEY_FOR_ATTEMPT_COUNT];
            [offenseGradeOfTotalGradeOfTeam setObject:[NSString stringWithFormat:@"%d", foulCount] forKey:KEY_FOR_FOUL_COUNT];
            [offenseGradeOfTotalGradeOfTeam setObject:[NSString stringWithFormat:@"%d", turnOverCount] forKey:KEY_FOR_TURN_OVER_COUNT];
            [offenseGradeOfTotalGradeOfTeam setObject:[NSString stringWithFormat:@"%d", scoreGet] forKey:KEY_FOR_SCORE_GET];
            
            [totalGradeOfTeam setObject:offenseGradeOfTotalGradeOfTeam forKey:keyForOffense];
        }
        
        int totalScore = 0;
        for(int i=0; i<self.playerCount; i++)
        {
            NSDictionary* totalGradeOfPlayer = [totalGrade objectAtIndex:i];
            totalScore += [[totalGradeOfPlayer objectForKey:@"totalScoreGet"] intValue];
        }
        
        [totalGradeOfTeam setObject:[NSString stringWithFormat:@"%d", totalScore] forKey:@"totalScoreGet"];
        
    }
    
    self.quarterNo = 0;
    //Update Zone Grade;
    [self updateZoneGradeView];
    
    //Add Two Arrow for Quarter change
    UIButton* lastQuarterButton = [[UIButton alloc] init];
    [lastQuarterButton setImage:[UIImage imageNamed:@"leftArrow.png"] forState:UIControlStateNormal];
    [lastQuarterButton sizeToFit];
    lastQuarterButton.frame = CGRectMake(self.backgroundImageView.frame.origin.x-lastQuarterButton.frame.size.width*0.25-5, self.backgroundImageView.frame.origin.y+20, lastQuarterButton.frame.size.width*0.25, lastQuarterButton.frame.size.height*0.25);
    [lastQuarterButton addTarget:self action:@selector(gradeOfLastQuarterButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lastQuarterButton];
    
    UIButton* nextQuarterButton = [[UIButton alloc] init];
    [nextQuarterButton setImage:[UIImage imageNamed:@"rightArrow.png"] forState:UIControlStateNormal];
    [nextQuarterButton sizeToFit];
    nextQuarterButton.frame = CGRectMake(CGRectGetMaxX(self.backgroundImageView.frame)+5, self.backgroundImageView.frame.origin.y+20, nextQuarterButton.frame.size.width*0.25, nextQuarterButton.frame.size.height*0.25);
    [nextQuarterButton addTarget:self action:@selector(gradeOfNextQuaterButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextQuarterButton];
    
    //Update Record.plist
    if(!self.showOldRecordNo)
    {
        NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
        NSMutableArray* recordPlistArray = [NSMutableArray arrayWithContentsOfFile:recordPlistPath];
        
        NSLog(@"%@, %@, %@", self.playerDataArray, self.playerNoSet, self.recordName);
        
        NSMutableDictionary* newItem = [[NSMutableDictionary alloc] init];
        [newItem setObject:[NSNumber numberWithInt:5] forKey:KEY_FOR_LAST_RECORD_QUARTER];
        [newItem setObject:self.playerDataArray forKey:KEY_FOR_GRADE];
        [newItem setObject:self.playerNoSet forKey:KEY_FOR_PLAYER_NO_SET];
        [newItem setObject:self.recordName forKey:KEY_FOR_NAME];
        
        if([recordPlistArray count] < 5)
            [recordPlistArray addObject:newItem];
        else
        {
            for(int i=0; i<4; i++)
                [recordPlistArray setObject:[recordPlistArray objectAtIndex:i+1] atIndexedSubscript:i];
            [recordPlistArray setObject:newItem atIndexedSubscript:4];
        }
        
        [recordPlistArray writeToFile:recordPlistPath atomically:YES];
        
        //Remove tmp.plist
        NSFileManager* fm = [[NSFileManager alloc] init];
        if([fm fileExistsAtPath:self.tmpPlistPath])
            [fm removeItemAtPath:self.tmpPlistPath error:nil];
    }
}

-(void)gradeOfNextQuaterButtonClicked
{
    if (self.quarterNo < 4)
    {
        self.quarterNo++;
        [self updateGradeView];
    }
}

-(void)gradeOfLastQuarterButtonClicked
{
    if(self.quarterNo > 0)
    {
        self.quarterNo--;
        [self updateGradeView];
    }
}

-(void)updateGradeView
{
    switch(self.quarterNo)
    {
        case 0:
            self.navigationItem.title = @"第一節成績";
            break;
        case 1:
            self.navigationItem.title = @"第二節成績";
            break;
        case 2:
            self.navigationItem.title = @"第三節成績";
            break;
        case 3:
            self.navigationItem.title = @"第四節成績";
            break;
        case 4:
            self.navigationItem.title = @"總成績";
            break;
    }
    
    if(self.isShowZoneGrade)
        [self updateZoneGradeView];
    else
        [(UITableView*)[self.view viewWithTag:PLAYER_GRADE_TABLEVIEW_TAG] reloadData];
}

-(void)showZoneGrade
{
    self.isShowZoneGrade = YES;
    [self updateZoneGradeView];
    self.navigationItem.rightBarButtonItem.title = @"進攻分類";
    self.navigationItem.rightBarButtonItem.action = @selector(showOffenseGrade);
    
    [self hideZone12orNot:NO];
    
    [[self.view viewWithTag:PLAYER_GRADE_TABLEVIEW_TAG] removeFromSuperview];

}

-(void)showOffenseGrade
{
    self.isShowZoneGrade = NO;
    self.navigationItem.rightBarButtonItem.title = @"區域分類";
    self.navigationItem.rightBarButtonItem.action = @selector(showZoneGrade);

    [self hideZone12orNot:YES];
    
    if(!self.playerDataTableView)
    {
        self.playerDataTableView = [[UITableView alloc] initWithFrame:[self.view viewWithTag:BACKGROUND_IMAGEVIEW_TAG].frame];
        self.playerDataTableView.tag = PLAYER_GRADE_TABLEVIEW_TAG;
        self.playerDataTableView.delegate = self;
        self.playerDataTableView.dataSource = self;
    }
    [self.view addSubview:self.playerDataTableView];
    [self.playerDataTableView reloadData];
}

-(void)hideZone12orNot:(BOOL)yesOrNo
{
    [self.view viewWithTag:12].hidden = yesOrNo;
    [self.view viewWithTag:1201].hidden = yesOrNo;
    [self.view viewWithTag:1202].hidden = yesOrNo;
    [self.view viewWithTag:1203].hidden = yesOrNo;
}

-(void)updateTmpPlist
{
    NSMutableDictionary* tmpPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.tmpPlistPath];
    [tmpPlistDic setObject:self.playerDataArray forKey:KEY_FOR_GRADE];
    
    [tmpPlistDic writeToFile:self.tmpPlistPath atomically:YES];
}

- (void) constructAlertControllers
{
    //Bonus alert
    self.bonusAlertFor2Chance = [UIAlertController alertControllerWithTitle:@"罰球得分" message:nil preferredStyle: UIAlertControllerStyleAlert];
    self.bonusAlertFor3Chance = [UIAlertController alertControllerWithTitle:@"罰球得分" message:nil preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction* zeroPointAction = [UIAlertAction actionWithTitle:@"0分" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            self.zoneNo = 0;
        }];
    
    UIAlertAction* onePointAction = [UIAlertAction actionWithTitle:@"1分" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            //Update the Quarter Grade of the Player
            NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:self.quarterNo];
            NSMutableDictionary* playerData = [quarterGrade objectAtIndex:self.playerSelectedIndex-1];
            [self increaseOffenseScoreGetToPlayerData:playerData by:1];
            
            [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:1];
            
            //Update the Team's Total Grade
            NSMutableDictionary* teamGrade = [quarterGrade objectAtIndex:self.playerCount];
            [self increaseOffenseScoreGetToPlayerData:teamGrade by:1];
            
            [self updateTotalScoreOnePlayerGetToPlayerData:teamGrade withScore:1];
            
            //Update the Player's Grade In Four Quarter
            NSMutableArray* totalGradeOfPlayer = [self.playerDataArray objectAtIndex:4];
            playerData = [totalGradeOfPlayer objectAtIndex:self.playerSelectedIndex-1];
            [self increaseOffenseScoreGetToPlayerData:playerData by:1];
            
            [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:1];
            
            [self updateTmpPlist];
            self.zoneNo = 0;
        }];
    
    UIAlertAction* twoPointAction = [UIAlertAction actionWithTitle:@"2分" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            //Update the Quarter Grade of the Player
            NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:self.quarterNo];
            NSMutableDictionary* playerData = [quarterGrade objectAtIndex:self.playerSelectedIndex-1];
            [self increaseOffenseScoreGetToPlayerData:playerData by:2];
           
            [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:2];
            
            //Update the Team's Total Grade
            NSMutableDictionary* teamGrade = [quarterGrade objectAtIndex:self.playerCount];
            [self increaseOffenseScoreGetToPlayerData:teamGrade by:2];
            
            [self updateTotalScoreOnePlayerGetToPlayerData:teamGrade withScore:2];
            
            //Update the Player's Grade In Four Quarter
            NSMutableArray* totalGradeOfPlayer = [self.playerDataArray objectAtIndex:4];
            playerData = [totalGradeOfPlayer objectAtIndex:self.playerSelectedIndex-1];
            [self increaseOffenseScoreGetToPlayerData:playerData by:2];
            
            [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:2];
            
            [self updateTmpPlist];
            self.zoneNo = 0;
        }];
    
    UIAlertAction* threePointAction = [UIAlertAction actionWithTitle:@"3分" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            //Update the Quarter Grade of the Player
            NSMutableArray* quarterGrade= [self.playerDataArray objectAtIndex:self.quarterNo];
            NSMutableDictionary* playerData = [quarterGrade objectAtIndex:self.playerSelectedIndex-1];
            [self increaseOffenseScoreGetToPlayerData:playerData by:3];
            
            [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:3];
            
            //Update the Team's Total Grade
            NSMutableDictionary* teamGrade = [quarterGrade objectAtIndex:self.playerCount];
            [self increaseOffenseScoreGetToPlayerData:teamGrade by:3];
            
            [self updateTotalScoreOnePlayerGetToPlayerData:teamGrade withScore:3];
            
            //Update the Player's Total Grade
            NSMutableArray* totalGradeOfPlayer = [self.playerDataArray objectAtIndex:4];
            playerData = [totalGradeOfPlayer objectAtIndex:self.playerSelectedIndex-1];
            [self increaseOffenseScoreGetToPlayerData:playerData by:3];
            
            [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:3];
            
            [self updateTmpPlist];
            self.zoneNo = 0;
        }];
    
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action)
        {
            self.zoneNo = 0;
        }];
    
    [self.bonusAlertFor2Chance addAction:zeroPointAction];
    [self.bonusAlertFor2Chance addAction:onePointAction];
    [self.bonusAlertFor2Chance addAction:twoPointAction];
    
    [self.bonusAlertFor3Chance addAction:zeroPointAction];
    [self.bonusAlertFor3Chance addAction:onePointAction];
    [self.bonusAlertFor3Chance addAction:twoPointAction];
    [self.bonusAlertFor3Chance addAction:threePointAction];
    
    //And One Alert
    self.andOneAlert = [UIAlertController alertControllerWithTitle:@"罰球結果" message:nil preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction* attemptAction = [UIAlertAction actionWithTitle:@"Attempt" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            self.zoneNo = 0;
        }];
    
    UIAlertAction* madeAction = [UIAlertAction actionWithTitle:@"Made" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            //Update the Quarter Grade of the Player In the Quarter
            NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:self.quarterNo];
            NSMutableDictionary* playerData = [quarterGrade objectAtIndex:self.playerSelectedIndex-1];
            [self increaseOffenseScoreGetToPlayerData:playerData by:1];
            
            [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:1];
            
            //Update the Team's Total Grade In The Quarter
            NSMutableDictionary* teamGrade = [quarterGrade objectAtIndex:self.playerCount];
            [self increaseOffenseScoreGetToPlayerData:teamGrade by:1];
            
            [self updateTotalScoreOnePlayerGetToPlayerData:teamGrade withScore:1];
            
            //Update the Player's Total Grade Of The Offense In Entire Game
            NSMutableArray* totalGradeOfPlayer = [self.playerDataArray objectAtIndex:4];
            playerData = [totalGradeOfPlayer objectAtIndex:self.playerSelectedIndex-1];
            [self increaseOffenseScoreGetToPlayerData:playerData by:1];
            
            [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:1];
            
            [self updateTmpPlist];
            self.zoneNo = 0;
        }];
    
    [self.andOneAlert addAction:madeAction];
    [self.andOneAlert addAction:attemptAction];

    
    //Result & Made or Not Alert
    self.resultAlert = [UIAlertController alertControllerWithTitle:@"結果" message:nil preferredStyle: UIAlertControllerStyleAlert];
    self.madeOrNotAlert = [UIAlertController alertControllerWithTitle:@"結果" message:nil preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Made" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            self.OldPlayerDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.playerDataArray]];
            
            //Update the Quarter Grade of the Player
            NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:self.quarterNo];
            NSMutableDictionary* playerData = [quarterGrade objectAtIndex:self.playerSelectedIndex-1];
            
                //更新進攻方式分類成績
            if(self.zoneNo != 12)
                [self updateOffenseGradeForOneMadeToPlayerData:playerData];
            
                //更新區域分類的成績
            [self updateZoneGradeForOneMadeToPlayerData:playerData];
  
                //更新得分成績
            int offset = 0;
            switch (self.zoneNo)
            {
                case 2: case 3: case 4: case 7: case 8: case 9:
                    offset = 2;
                    break;
                case 1: case 5: case 6: case 10: case 11:
                    offset = 3;
                    break;
                case 12:
                    offset = 1;
                    break;
            }
            [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:offset];
            
            //Update the Team's Total Grade
            NSMutableDictionary* teamGrade = [quarterGrade objectAtIndex:self.playerCount];
            
                //更新進攻方式分類成績
            if(self.zoneNo != 12)
                [self updateOffenseGradeForOneMadeToPlayerData:teamGrade];
            
                //更新區域分類的成績
            [self updateZoneGradeForOneMadeToPlayerData:teamGrade];
            
                //更新得分成績
            [self updateTotalScoreOnePlayerGetToPlayerData:teamGrade withScore:offset];
            
            //Update the Player's Total Grade
            NSMutableArray* totalGradeOfPlayer = [self.playerDataArray objectAtIndex:4];
            playerData = [totalGradeOfPlayer objectAtIndex:self.playerSelectedIndex-1];
            
                //更新進攻方式分類成績
            if(self.zoneNo != 12)
                [self updateOffenseGradeForOneMadeToPlayerData:playerData];
            
                //更新區域分類的成績
            [self updateZoneGradeForOneMadeToPlayerData:playerData];
            
                //更新得分成績
            [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:offset];
            
            [self updateTmpPlist];
            self.zoneNo = 0;
        }];
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"Attempt" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            self.OldPlayerDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.playerDataArray]];
            
            //Update the Quarter Grade of the Player
            NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:self.quarterNo];
            NSMutableDictionary* playerData = [quarterGrade objectAtIndex:self.playerSelectedIndex-1];
            
                //更新進攻方式分類的成績
            if(self.zoneNo != 12)
                [self updateOffenseGradeForOneAttempToPlayerData:playerData];

                //更新區域分類的成績
            [self updateZoneGradeForOndeAttemptToPlayerData:playerData];
            
            //Update the Team's Total Grade
            NSMutableDictionary* teamData = [quarterGrade objectAtIndex:self.playerCount];
            
                //更新進攻方式分類的成績
            if(self.zoneNo != 12)
                [self updateOffenseGradeForOneAttempToPlayerData:teamData];
            
                //更新區域分類的成績
            [self updateZoneGradeForOndeAttemptToPlayerData:teamData];
            
            //Update the Player's Total Grade
            NSMutableArray* totalGradeOfPlayer = [self.playerDataArray objectAtIndex:4];
            playerData = [totalGradeOfPlayer objectAtIndex:self.playerSelectedIndex-1];
            
                //更新進攻方式分類的成績
            if(self.zoneNo != 12)
                [self updateOffenseGradeForOneAttempToPlayerData:playerData];
            
                //更新區域分類的成績
            [self updateZoneGradeForOndeAttemptToPlayerData:playerData];
            
            [self updateTmpPlist];
            self.zoneNo = 0;
            NSLog(@"%@", self.playerDataArray);
        }];
    
    UIAlertAction* foulAction = [UIAlertAction actionWithTitle:@"Foul" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action)
        {
            self.OldPlayerDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.playerDataArray]];
            
            //Update the Quarter Grade of the Player
            NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:self.quarterNo];
            NSMutableDictionary* playerData = [quarterGrade objectAtIndex:self.playerSelectedIndex-1];
            
                //更新進攻方式分類的成績
            [self updateOffenseGradeForOneFoulToPlayerData:playerData];
            
            //Update the Team's Total Grade
            NSMutableDictionary* teamGrade = [quarterGrade objectAtIndex:self.playerCount];
            
                //更新進攻方式分類的成績
            [self updateOffenseGradeForOneFoulToPlayerData:teamGrade];
            
            //Update the Player's Total Grade
            NSMutableArray* totalGradeOfPlayer = [self.playerDataArray objectAtIndex:4];
            playerData = [totalGradeOfPlayer objectAtIndex:self.playerSelectedIndex-1];
            
                //更新進攻方式分類的成績
            [self updateOffenseGradeForOneFoulToPlayerData:playerData];
            
            switch (self.zoneNo)
            {
                case 2: case 3: case 4: case 7: case 8: case 9:
                    [self presentViewController:self.bonusAlertFor2Chance animated:YES completion:nil];
                    break;
                    
                case 1: case 6: case 10: case 11:
                    [self presentViewController:self.bonusAlertFor3Chance animated:YES completion:nil];
                    break;
            }
            
            [self updateTmpPlist];
            self.zoneNo = 0;
        }];
    
    UIAlertAction* andOneAction = [UIAlertAction actionWithTitle:@"And One" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action)
        {
            self.OldPlayerDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.playerDataArray]];
            
            //Update the Quarter Grade of the Player
            NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:self.quarterNo];
            NSMutableDictionary* playerData = [quarterGrade objectAtIndex:self.playerSelectedIndex-1];
            
                //更新進攻方式分類的成績
            [self updateOffenseGradeForOneMadeToPlayerData:playerData];
            [self updateOffenseGradeForOneFoulToPlayerData:playerData];
            
                //更新區域分類的成績
            [self updateZoneGradeForOneMadeToPlayerData:playerData];
            
                //更新得分成績
            int offset = 0;
            switch (self.zoneNo)
            {
                case 2: case 3: case 4: case 7: case 8: case 9:
                    offset = 2;
                    break;
                case 1: case 5: case 6: case 10: case 11:
                    offset = 3;
                    break;
            }
            [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:offset];
            
            //Update the Team's Total Grade
            NSMutableDictionary* teamGrade = [quarterGrade objectAtIndex:self.playerCount];
            
                //更新進攻方式分類的成績
            [self updateOffenseGradeForOneMadeToPlayerData:teamGrade];
            [self updateOffenseGradeForOneFoulToPlayerData:teamGrade];
            
                //更新區域分類的成績
            [self updateZoneGradeForOneMadeToPlayerData:teamGrade];
            
                //更新得分成績
            [self updateTotalScoreOnePlayerGetToPlayerData:teamGrade withScore:offset];
            
            //Update the Player's Total Grade
            NSMutableArray* totalGradeOfPlayer = [self.playerDataArray objectAtIndex:4];
            playerData = [totalGradeOfPlayer objectAtIndex:self.playerSelectedIndex-1];
            
                //更新進攻方式分類的成績
            [self updateOffenseGradeForOneMadeToPlayerData:playerData];
            [self updateOffenseGradeForOneFoulToPlayerData:playerData];
            
                //更新區域分類的成績
            [self updateZoneGradeForOneMadeToPlayerData:playerData];
            
                //更新得分成績
            [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:offset];
            
            [self presentViewController:self.andOneAlert animated:YES completion:nil];
        }];
    
    UIAlertAction* turnOverAction = [UIAlertAction actionWithTitle:@"Turn Over" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action)
        {
            self.OldPlayerDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.playerDataArray]];
            
            //Update the Quarter Grade of the Player
            NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:self.quarterNo];
            NSMutableDictionary* playerData = [quarterGrade objectAtIndex:self.playerSelectedIndex-1];
            
            //更新進攻方式分類的成績
            [self updateOffenseGradeForOneTurnOverToPlayerData:playerData];
            
            //Update the Team's Total Grade
            NSMutableDictionary* teamGrade = [quarterGrade objectAtIndex:self.playerCount];
            
            //更新進攻方式分類的成績
            [self updateOffenseGradeForOneTurnOverToPlayerData:teamGrade];
            
            //Update the Player's Total Grade
            NSMutableArray* totalGradeOfPlayer = [self.playerDataArray objectAtIndex:4];
            playerData = [totalGradeOfPlayer objectAtIndex:self.playerSelectedIndex-1];
            
            //更新進攻方式分類的成績
            [self updateOffenseGradeForOneTurnOverToPlayerData:playerData];
            
            [self updateTmpPlist];
            self.zoneNo = 0;
        }];
    
    [self.resultAlert addAction:yesAction];
    [self.resultAlert addAction:noAction];
    [self.resultAlert addAction:andOneAction];
    [self.resultAlert addAction:foulAction];
    [self.resultAlert addAction:turnOverAction];
    [self.resultAlert addAction:cancelAction];
    
    [self.madeOrNotAlert addAction:yesAction];
    [self.madeOrNotAlert addAction:noAction];
    [self.madeOrNotAlert addAction:cancelAction];
    
    self.attackWayAlert = [UIAlertController alertControllerWithTitle:@"進攻方式"
                                        message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* isolationAction = [UIAlertAction actionWithTitle:@"Isolation" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                      {
                                          self.keyForSearch = @"isolation";
                                          [self presentViewController:self.resultAlert animated:YES completion:nil];
                                      }];
    UIAlertAction* spotUpAction = [UIAlertAction actionWithTitle:@"Spot Up" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                   {
                                       self.keyForSearch = @"spotUp";
                                       [self presentViewController:self.resultAlert animated:YES completion:nil];
                                   }];
    UIAlertAction* psAction = [UIAlertAction actionWithTitle:@"PS" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                               {
                                   self.keyForSearch = @"PS";
                                   [self presentViewController:self.resultAlert animated:YES completion:nil];
                               }];
    UIAlertAction* pcAction = [UIAlertAction actionWithTitle:@"PC" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                               {
                                   self.keyForSearch = @"PC";
                                   [self presentViewController:self.resultAlert animated:YES completion:nil];
                               }];
    UIAlertAction* prAction = [UIAlertAction actionWithTitle:@"PR" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                               {
                                   self.keyForSearch = @"PR";
                                   [self presentViewController:self.resultAlert animated:YES completion:nil];
                               }];
    UIAlertAction* ppsAction = [UIAlertAction actionWithTitle:@"PPS" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    self.keyForSearch = @"PPS";
                                    [self presentViewController:self.resultAlert animated:YES completion:nil];
                                }];
    UIAlertAction* ppcAction = [UIAlertAction actionWithTitle:@"PPC" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    self.keyForSearch = @"PPC";
                                    [self presentViewController:self.resultAlert animated:YES completion:nil];
                                }];
    UIAlertAction* catchShootAction = [UIAlertAction actionWithTitle:@"Catch&Shoot" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    self.keyForSearch = @"CS";
                                    [self presentViewController:self.resultAlert animated:YES completion:nil];
                                }];
    UIAlertAction* fastBreakAction = [UIAlertAction actionWithTitle:@"Fast Break" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    self.keyForSearch = @"fastBreak";
                                    [self presentViewController:self.resultAlert animated:YES completion:nil];
                                }];
    UIAlertAction* lowPostAction = [UIAlertAction actionWithTitle:@"Low Post" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    self.keyForSearch = @"lowPost";
                                    [self presentViewController:self.resultAlert animated:YES completion:nil];
                                }];
    UIAlertAction* secondAction = [UIAlertAction actionWithTitle:@"Second" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                   {
                                       self.keyForSearch = @"second";
                                       [self presentViewController:self.resultAlert animated:YES completion:nil];
                                   }];
    UIAlertAction* driveAction = [UIAlertAction actionWithTitle:@"Drive" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                  {
                                      self.keyForSearch = @"drive";
                                      [self presentViewController:self.resultAlert animated:YES completion:nil];
                                  }];
    UIAlertAction* cutAction = [UIAlertAction actionWithTitle:@"Cut" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                {
                                    self.keyForSearch = @"cut";
                                    [self presentViewController:self.resultAlert animated:YES completion:nil];
                                }];
    
    [self.attackWayAlert addAction:isolationAction];
    [self.attackWayAlert addAction:spotUpAction];
    [self.attackWayAlert addAction:psAction];
    [self.attackWayAlert addAction:pcAction];
    [self.attackWayAlert addAction:prAction];
    [self.attackWayAlert addAction:ppsAction];
    [self.attackWayAlert addAction:ppcAction];
    [self.attackWayAlert addAction:catchShootAction];
    [self.attackWayAlert addAction:fastBreakAction];
    [self.attackWayAlert addAction:lowPostAction];
    [self.attackWayAlert addAction:secondAction];
    [self.attackWayAlert addAction:driveAction];
    [self.attackWayAlert addAction:cutAction];
    [self.attackWayAlert addAction:cancelAction];
}

- (void) updateZoneGradeForOneMadeToPlayerData:(NSMutableDictionary*) playerData
{
    NSString* keyForZone = [NSString stringWithFormat:@"zone%d", self.zoneNo];
    NSMutableDictionary* zoneData = [playerData objectForKey:keyForZone];
    
    int madeCount = [[zoneData objectForKey:KEY_FOR_MADE_COUNT] intValue];
    [zoneData setObject:[NSString stringWithFormat:@"%d", madeCount+1] forKey:KEY_FOR_MADE_COUNT];
    
    int attemptCount = [[zoneData objectForKey:KEY_FOR_ATTEMPT_COUNT] intValue];
    [zoneData setObject:[NSString stringWithFormat:@"%d", attemptCount+1] forKey:KEY_FOR_ATTEMPT_COUNT];
    
    [playerData setObject:zoneData forKey:keyForZone];
    
    //Update UI
    [self updateZoneGradeView];
}

-(void) updateZoneGradeForOndeAttemptToPlayerData:(NSMutableDictionary*) playerData
{
    NSString* keyForZone = [NSString stringWithFormat:@"zone%d", self.zoneNo];
    NSMutableDictionary* zoneData = [playerData objectForKey:keyForZone];
    int attemptCount = [[zoneData objectForKey:KEY_FOR_ATTEMPT_COUNT] intValue];
    [zoneData setObject:[NSString stringWithFormat:@"%d", attemptCount + 1] forKey:KEY_FOR_ATTEMPT_COUNT];
    
    [playerData setObject:zoneData forKey:keyForZone];
    
    //Update UI
    [self updateZoneGradeView];
}

-(void)updateOffenseGradeForOneMadeToPlayerData:(NSMutableDictionary*) playerData
{
    //Update the Quarter Grade
    NSMutableDictionary* attackData = [playerData objectForKey:self.keyForSearch];
    
    int attemptCount = [[attackData objectForKey:KEY_FOR_ATTEMPT_COUNT] intValue];
    [attackData setObject:[NSString stringWithFormat:@"%d", attemptCount+1] forKey:KEY_FOR_ATTEMPT_COUNT];
    
    int madeCount = [[attackData objectForKey:KEY_FOR_MADE_COUNT] intValue];
    [attackData setObject:[NSString stringWithFormat:@"%d", madeCount+1] forKey:KEY_FOR_MADE_COUNT];
    
    [playerData setObject:attackData forKey:self.keyForSearch];
    
    switch (self.zoneNo)
    {
        case 2: case 3: case 4: case 7: case 8: case 9:
            [self increaseOffenseScoreGetToPlayerData:playerData by:2];
            break;
        case 1: case 5: case 6: case 10: case 11:
            [self increaseOffenseScoreGetToPlayerData:playerData by:3];
            break;
    }
}

-(void)updateOffenseGradeForOneAttempToPlayerData:(NSMutableDictionary*) playerData
{
    NSMutableDictionary* attackData = [playerData objectForKey:self.keyForSearch];
    int attemptCount = [[attackData objectForKey:KEY_FOR_ATTEMPT_COUNT] intValue];
    [attackData setObject:[NSString stringWithFormat:@"%d", attemptCount+1] forKey:KEY_FOR_ATTEMPT_COUNT];
    [playerData setObject:attackData forKey:self.keyForSearch];
}

-(void) updateOffenseGradeForOneFoulToPlayerData:(NSMutableDictionary*) playerData
{
    NSMutableDictionary* attackData = [playerData objectForKey:self.keyForSearch];
    int foulCount = [[attackData objectForKey:KEY_FOR_FOUL_COUNT] intValue];
    [attackData setObject:[NSString stringWithFormat:@"%d", foulCount+1] forKey:KEY_FOR_FOUL_COUNT];
    
    [playerData setObject:attackData forKey:self.keyForSearch];
}

-(void) updateOffenseGradeForOneTurnOverToPlayerData:(NSMutableDictionary*) playerData
{
    NSMutableDictionary* attackData = [playerData objectForKey:self.keyForSearch];
    
    int turnOverCount = [[attackData objectForKey:KEY_FOR_TURN_OVER_COUNT] intValue];
    [attackData setObject:[NSString stringWithFormat:@"%d", turnOverCount+1] forKey:KEY_FOR_TURN_OVER_COUNT];
    
    [playerData setObject:attackData forKey:self.keyForSearch];
}

-(void) increaseOffenseScoreGetToPlayerData:(NSMutableDictionary*)playerData by:(int)offset
{
    NSMutableDictionary* attackData = [playerData objectForKey:self.keyForSearch];
    int scoreGet = [[attackData objectForKey:KEY_FOR_SCORE_GET] intValue];
    [attackData setObject:[NSString stringWithFormat:@"%d", scoreGet+offset] forKey:KEY_FOR_SCORE_GET];
    
    [playerData setObject:attackData forKey:self.keyForSearch];
}

-(void) updateTotalScoreOnePlayerGetToPlayerData:(NSMutableDictionary*) playerData withScore:(int)score
{
    int totalScoreGet = [[playerData objectForKey:@"totalScoreGet"] intValue];
    NSString* totalScoreGetStr = [NSString stringWithFormat:@"%d", totalScoreGet+score];
    
    [playerData setObject:totalScoreGetStr forKey:@"totalScoreGet"];
}

- (void) drawPicture
{
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];
    
    CGFloat x = (self.view.frame.size.width- CGRectGetMaxX(self.playerListTableView.frame) - BACKGROUND_WIDTH)/3 + CGRectGetMaxX(self.playerListTableView.frame);
    CGFloat y = (self.view.frame.size.height - BAR_HEIGHT - BACKGROUND_HEIGHT)/2 + BAR_HEIGHT;
    
    self.backgroundImageView.frame = CGRectMake(x, y, BACKGROUND_WIDTH, BACKGROUND_HEIGHT);
    self.backgroundImageView.tag = BACKGROUND_IMAGEVIEW_TAG;
    
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.backgroundImageView];
    
    NSMutableArray* zoneImageViewArray = [NSMutableArray arrayWithCapacity:11];
    
    //ZONE 1
    UIImageView* zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone1.png"] highlightedImage:[UIImage imageNamed:@"zone1-2.png"]];
    
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(self.backgroundImageView.frame.origin.x+2, self.backgroundImageView.frame.origin.y+2, zoneImageView.frame.size.width*IMAGE_SCALE, zoneImageView.frame.size.height*IMAGE_SCALE);

    zoneImageView.tag = 1;
    
    [zoneImageView setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 2
    CGPoint zonePosition = CGPointMake(zoneImageView.frame.origin.x+zoneImageView.frame.size.width+2, zoneImageView.frame.origin.y);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone2.png"] highlightedImage:[UIImage imageNamed:@"zone2-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE, zoneImageView.frame.size.height*IMAGE_SCALE);
    
    zoneImageView.tag = 2;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 3
    zonePosition = CGPointMake(zoneImageView.frame.origin.x+zoneImageView.frame.size.width+2, zoneImageView.frame.origin.y);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone3.png"] highlightedImage:[UIImage imageNamed:@"zone3-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE, zoneImageView.frame.size.height*IMAGE_SCALE);
    
    zoneImageView.tag = 3;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                     initWithTarget:self
                                                     action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 4
    zonePosition = CGPointMake(zoneImageView.frame.origin.x+zoneImageView.frame.size.width+2, zoneImageView.frame.origin.y);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone4.png"] highlightedImage:[UIImage imageNamed:@"zone4-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE-2, zoneImageView.frame.size.height*IMAGE_SCALE);
    
    zoneImageView.tag = 4;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 5
    zonePosition = CGPointMake(zoneImageView.frame.origin.x+zoneImageView.frame.size.width+2, zoneImageView.frame.origin.y);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone5.png"] highlightedImage:[UIImage imageNamed:@"zone5-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE, zoneImageView.frame.size.height*IMAGE_SCALE);
    
    zoneImageView.tag = 5;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 6
    UIImageView* zone1 = [self.view viewWithTag:1];
    zonePosition = CGPointMake(zone1.frame.origin.x, zone1.frame.origin.y+zone1.frame.size.height+2);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone6.png"] highlightedImage:[UIImage imageNamed:@"zone6-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE, zoneImageView.frame.size.height*IMAGE_SCALE-1);
    
    zoneImageView.tag = 6;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 7
    UIImageView* zone2 = [self.view viewWithTag:2];
    zonePosition = CGPointMake(zone2.frame.origin.x, zone2.frame.origin.y+zone2.frame.size.height+2);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone7.png"] highlightedImage:[UIImage imageNamed:@"zone7-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE, zoneImageView.frame.size.height*IMAGE_SCALE);
    
    zoneImageView.tag = 7;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
  
    //ZONE 10
    UIImageView* zone4 = [self.view viewWithTag:4];
    zonePosition = CGPointMake(zone4.frame.origin.x, zone4.frame.origin.y+zone4.frame.size.height+2);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone10.png"] highlightedImage:[UIImage imageNamed:@"zone10-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE-2, zoneImageView.frame.size.height*IMAGE_SCALE-2);
    
    zoneImageView.tag = 10;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 9
    zonePosition = CGPointMake(zone4.frame.origin.x, zone4.frame.origin.y+zone4.frame.size.height+2);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone9.png"] highlightedImage:[UIImage imageNamed:@"zone9-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE-1, zoneImageView.frame.size.height*IMAGE_SCALE-1);
    
    zoneImageView.tag = 9;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //ZONE 11
    UIImageView* zone3 = [self.view viewWithTag:3];
    UIImageView* zone6 = [self.view viewWithTag:6];
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone11.png"] highlightedImage:[UIImage imageNamed:@"zone11-2.png"]];
    [zoneImageView sizeToFit];
    CGPoint zoneSize = CGPointMake(zoneImageView.frame.size.width*IMAGE_SCALE-2, zoneImageView.frame.size.height*IMAGE_SCALE-1);
    zonePosition = CGPointMake(zone3.frame.origin.x+1, CGRectGetMaxY(zone6.frame)-zoneSize.y);
    
    zoneImageView.frame = CGRectMake(zonePosition.x, zonePosition.y, zoneSize.x, zoneSize.y);
    
    zoneImageView.tag = 11;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    
    //ZONE 8
    zonePosition = CGPointMake(zone3.frame.origin.x, zone3.frame.origin.y+zone3.frame.size.height+2);
    zoneImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone8.png"] highlightedImage:[UIImage imageNamed:@"zone8-2.png"]];
    [zoneImageView sizeToFit];
    zoneImageView.frame = CGRectMake(zonePosition.x+1, zonePosition.y, zoneImageView.frame.size.width*IMAGE_SCALE-2, zoneImageView.frame.size.height*IMAGE_SCALE);
    
    zoneImageView.tag = 8;
    
    [zoneImageView setUserInteractionEnabled:YES];
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [zoneImageView addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:zoneImageView];
    [zoneImageViewArray addObject:zoneImageView];
    
    //Draw Label for zone1
    UILabel* hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone1.frame.origin.x, zone1.frame.origin.y + zone1.frame.size.height*TOP_PADDING_RATE1, zone1.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 101;
    UILabel* gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), CGRectGetWidth(hitRateLabel.frame), RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 102;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone2
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone2.frame.origin.x, zone2.frame.origin.y + zone2.frame.size.height*TOP_PADDING_RATE1, zone2.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 201;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), CGRectGetWidth(hitRateLabel.frame), RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 202;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone3
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone3.frame.origin.x, zone3.frame.origin.y + zone3.frame.size.height*TOP_PADDING_RATE2, zone3.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 301;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), CGRectGetWidth(hitRateLabel.frame), RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 302;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone4
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone4.frame.origin.x, zone4.frame.origin.y + zone4.frame.size.height*TOP_PADDING_RATE1, zone4.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 401;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), CGRectGetWidth(hitRateLabel.frame), RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 402;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone5
    UIImageView* zone5 = [self.view viewWithTag:5];
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone5.frame.origin.x, zone5.frame.origin.y + zone5.frame.size.height*TOP_PADDING_RATE1, zone5.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 501;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), zone5.frame.size.width, RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 502;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone6
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone6.frame.origin.x, zone6.frame.origin.y+zone6.frame.size.height*TOP_PADDING_RATE3, zone6.frame.size.width*(1-SIDE_PADDING_RATE), RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 601;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), zone6.frame.size.width*(1-SIDE_PADDING_RATE), RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 602;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone7
    UIImageView* zone7 = [self.view viewWithTag:7];
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone7.frame.origin.x, zone7.frame.origin.y+zone7.frame.size.height*TOP_PADDING_RATE1, zone7.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 701;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), zone7.frame.size.width, RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 702;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone8
    UIImageView* zone8 = [self.view viewWithTag:8];
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone8.frame.origin.x, zone8.frame.origin.y+zone8.frame.size.height*TOP_PADDING_RATE4, zone8.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 801;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), zone8.frame.size.width, RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 802;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone9
    UIImageView* zone9 = [self.view viewWithTag:9];
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone9.frame.origin.x, zone9.frame.origin.y+zone9.frame.size.height*TOP_PADDING_RATE1, zone9.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 901;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), zone9.frame.size.width, RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 902;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone10
    UIImageView* zone10 = [self.view viewWithTag:10];
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone10.frame.origin.x+zone10.frame.size.width*SIDE_PADDING_RATE, zone10.frame.origin.y+zone10.frame.size.height*TOP_PADDING_RATE3, zone10.frame.size.width*(1-SIDE_PADDING_RATE), RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 1001;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), zone10.frame.size.width*(1-SIDE_PADDING_RATE), RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 1002;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Draw Label for zone10
    UIImageView* zone11 = [self.view viewWithTag:11];
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(zone11.frame.origin.x, zone11.frame.origin.y+zone11.frame.size.height*TOP_PADDING_RATE1, zone11.frame.size.width, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 1101;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), zone11.frame.size.width, RECORD_LABEL_HEIGHT)];
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.tag = 1102;
    gradeLabel.text = @"0/0";
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Bonus Zone
    UILabel* bonusZone = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.backgroundImageView.frame)+5, CGRectGetMaxY(self.backgroundImageView.frame)-80, 60, RECORD_LABEL_HEIGHT)];
    bonusZone.textAlignment = NSTextAlignmentCenter;
    bonusZone.layer.borderWidth = 1;
    bonusZone.tag = 1203;
    bonusZone.text = @"加罰";
    
    UIImageView* tapView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"zone1.png"] highlightedImage:[UIImage imageNamed:@"zone1-2.png"]];
    tapView.frame = bonusZone.frame;
    [tapView setUserInteractionEnabled:YES];
    tapView.tag = 12;
    tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                            initWithTarget:self
                            action:@selector(zonePaned:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapView addGestureRecognizer:tapGestureRecognizer];
    
    hitRateLabel = [[UILabel alloc] initWithFrame:CGRectMake(bonusZone.frame.origin.x, CGRectGetMaxY(bonusZone.frame), 60, RECORD_LABEL_HEIGHT)];
    hitRateLabel.textAlignment = NSTextAlignmentCenter;
    hitRateLabel.text = @"0%";
    hitRateLabel.tag = 1201;
    gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(hitRateLabel.frame.origin.x, CGRectGetMaxY(hitRateLabel.frame), 60, RECORD_LABEL_HEIGHT)];
    gradeLabel.tag = 1202;
    gradeLabel.textAlignment = NSTextAlignmentCenter;
    gradeLabel.text = @"0/0";
    
    [self.view addSubview:tapView];
    [self.view addSubview:bonusZone];
    [self.view addSubview:hitRateLabel];
    [self.view addSubview:gradeLabel];
    
    //Undo Button
    self.undoButton = [[UIButton alloc] init];
    [self.undoButton setFrame:CGRectMake(CGRectGetMinX(bonusZone.frame), CGRectGetMinY(self.backgroundImageView.frame), bonusZone.frame.size.width, bonusZone.frame.size.height)];
    self.undoButton.layer.borderWidth = 1;
    self.undoButton.layer.cornerRadius = 5;
    [self.undoButton setTitle:@"Undo" forState:UIControlStateNormal];
    [self.undoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.undoButton addTarget:self action:@selector(undoButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.undoButton];
}

-(void) undoButtonClicked
{
    if(self.OldPlayerDataArray)
    {
        self.playerDataArray = self.OldPlayerDataArray;

        [self updateZoneGradeView];
        [self updateTmpPlist];
    }
}

- (void) zonePaned:(UIPanGestureRecognizer*) recognizer
{
    if([recognizer.view isKindOfClass:[UIImageView class]])
    {
        if(!((UIImageView*)recognizer.view).highlighted)
        {
            if((int)recognizer.view.tag != self.zoneNo && self.zoneNo)
                [(UIImageView*)[self.view viewWithTag:self.zoneNo] setHighlighted:NO];
            self.zoneNo = (int)recognizer.view.tag;
            [(UIImageView*)recognizer.view setHighlighted:YES];
            if(self.playerSelectedIndex && self.playerSelectedIndex != self.playerCount+1)
                [self showAttackList];
        }
        else
        {
            self.zoneNo = 0;
            [(UIImageView*)recognizer.view setHighlighted:NO];
        }
    }
    
//    NSLog(@"select zone %d", self.zoneNo);
}

- (void) showAttackList
{
    if(self.zoneNo != 12)
    {
        [self presentViewController:self.attackWayAlert animated:YES completion:^
        {
            [(UIImageView*)[self.view viewWithTag:self.zoneNo] setHighlighted:NO];
        }];
    }
    else
    {
        [self presentViewController:self.madeOrNotAlert animated:YES completion:^
        {
            [(UIImageView*)[self.view viewWithTag:self.zoneNo] setHighlighted:NO];
        }];
    }
}

- (void) updateZoneGradeView
{
    NSArray* quarterData = [self.playerDataArray objectAtIndex:self.quarterNo];
    if(self.playerSelectedIndex)
    {
        NSDictionary* playerData = [quarterData objectAtIndex:self.playerSelectedIndex-1];
        for(int i=1; i<13; i++)
        {
            NSString* keyForZone = [NSString stringWithFormat:@"zone%d", i];
            NSDictionary* zoneData = [playerData objectForKey:keyForZone];
            
            float zoneAttemptCount = [(NSString*)[zoneData objectForKey:KEY_FOR_ATTEMPT_COUNT] floatValue];
            float zoneMadeCount = [(NSString*)[zoneData objectForKey:KEY_FOR_MADE_COUNT] floatValue];
            
            ((UILabel*)[self.view viewWithTag:(i*100+2)]).text = [NSString stringWithFormat:@"%d/%d", (int)zoneMadeCount, (int)zoneAttemptCount];
            
            if(zoneAttemptCount)
            {
                ((UILabel*)[self.view viewWithTag:(i*100+1)]).text = [NSString stringWithFormat:@"%d%c", (int)((zoneMadeCount/zoneAttemptCount)*100), '%'];
            }
            else
                ((UILabel*)[self.view viewWithTag:(i*100+1)]).text = @"0%";
        }
    }
    else
    {
        for(int i=1; i<12; i++)
        {
            ((UILabel*)[self.view viewWithTag:(i*100+2)]).text = @"0/0";
            ((UILabel*)[self.view viewWithTag:(i*100+1)]).text = @"0%";
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == NO_TABLEVIEW_TAG)
    {
       return (self.playerCount + 2); //One for title, the other one for team grade
    }
    //if(tableview.tag == PLAYER_GRADE_TABLEVIEW_TAG)
    return 16;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == NO_TABLEVIEW_TAG)
    {
        if(indexPath.row == 0)
        {
            BBRTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"title"];
            if(!cell)
            {
                cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"title"];
                cell.layer.borderWidth = 1;
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, TITLE_CELL_HEIGHT)];
                label.textAlignment = NSTextAlignmentCenter;
                label.backgroundColor = [UIColor lightGrayColor];
                label.text = @"背號";
                [cell addSubview:label];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
        else if(indexPath.row == self.playerCount+1)
        {
            BBRTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Team"];
            if(!cell)
            {
                cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Team"];
                cell.layer.borderWidth = 1;
                UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, CELL_HEIGHT)];
                label.textAlignment = NSTextAlignmentCenter;
                label.text = @"全隊";
                [cell addSubview:label];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
            return cell;
        }
        
        BBRTableViewCell* cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.layer.borderWidth = 1;
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, CELL_HEIGHT)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%@", [self.playerNoSet objectAtIndex:indexPath.row-1]];
        [cell addSubview:label];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        return cell;
    }
    //if(tableview.tag == PLAYER_GRADE_TABLEVIEW_TAG)
    if(indexPath.row == 0)
    {
        BBRTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"title"];
        if(!cell)
        {
            cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"title"];
            cell.layer.borderWidth = 1;
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width*0.3, PLAYER_GRADE_TABLECELL_HEIGHT)];
            [cell addSubview:label];
            
            UILabel* madeAndAttemptLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), label.frame.origin.y, tableView.frame.size.width*0.28, PLAYER_GRADE_TABLECELL_HEIGHT)];
            madeAndAttemptLabel.textAlignment = NSTextAlignmentCenter;
            madeAndAttemptLabel.layer.borderWidth = 1;
            madeAndAttemptLabel.text = @"進球/出手";
            
            UILabel* foulLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(madeAndAttemptLabel.frame), label.frame.origin.y, tableView.frame.size.width*0.14, PLAYER_GRADE_TABLECELL_HEIGHT)];
            foulLabel.textAlignment = NSTextAlignmentCenter;
            foulLabel.layer.borderWidth = 1;
            foulLabel.text = @"犯規";
            
            UILabel* turnOverLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(foulLabel.frame), label.frame.origin.y, tableView.frame.size.width*0.14, PLAYER_GRADE_TABLECELL_HEIGHT)];
            turnOverLabel.textAlignment = NSTextAlignmentCenter;
            turnOverLabel.layer.borderWidth = 1;
            turnOverLabel.text = @"失誤";
            
            UILabel* totalScoreGetLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(turnOverLabel.frame), label.frame.origin.y, tableView.frame.size.width*0.14, PLAYER_GRADE_TABLECELL_HEIGHT)];
            totalScoreGetLabel.textAlignment = NSTextAlignmentCenter;
            totalScoreGetLabel.layer.borderWidth = 1;
            totalScoreGetLabel.text = @"得分";
            
            [cell addSubview:madeAndAttemptLabel];
            [cell addSubview:foulLabel];
            [cell addSubview:turnOverLabel];
            [cell addSubview:totalScoreGetLabel];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    
    NSDictionary* playerData;
    if(self.playerSelectedIndex)
    {
        NSMutableArray* quarterData = [self.playerDataArray objectAtIndex:self.quarterNo];
        playerData = [quarterData objectAtIndex:self.playerSelectedIndex-1];
    }
    
    BBRTableViewCell* cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.layer.borderWidth = 1;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width*0.3, PLAYER_GRADE_TABLECELL_HEIGHT)];
    label.textAlignment = NSTextAlignmentCenter;
    
    if(indexPath.row < 14)
    {
        UILabel* madeAndAttemptLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), label.frame.origin.y, tableView.frame.size.width*0.28, PLAYER_GRADE_TABLECELL_HEIGHT)];
        madeAndAttemptLabel.textAlignment = NSTextAlignmentCenter;
        madeAndAttemptLabel.layer.borderWidth = 1;
        
        UILabel* foulLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(madeAndAttemptLabel.frame), label.frame.origin.y, tableView.frame.size.width*0.14, PLAYER_GRADE_TABLECELL_HEIGHT)];
        foulLabel.textAlignment = NSTextAlignmentCenter;
        foulLabel.layer.borderWidth = 1;
        
        UILabel* turnOverLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(foulLabel.frame), label.frame.origin.y, tableView.frame.size.width*0.14, PLAYER_GRADE_TABLECELL_HEIGHT)];
        turnOverLabel.textAlignment = NSTextAlignmentCenter;
        turnOverLabel.layer.borderWidth = 1;
        
        UILabel* totalScoreGetLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(turnOverLabel.frame), label.frame.origin.y, tableView.frame.size.width*0.14, PLAYER_GRADE_TABLECELL_HEIGHT)];
        totalScoreGetLabel.textAlignment = NSTextAlignmentCenter;
        totalScoreGetLabel.layer.borderWidth = 1;
        
        label.text = [self.attackWaySet objectAtIndex:indexPath.row-1];
        if(!self.playerSelectedIndex)
        {
            madeAndAttemptLabel.text = @"0/0";
            foulLabel.text = @"0";
            turnOverLabel.text = @"0";
            totalScoreGetLabel.text = @"0";
        }
        else
        {
            NSDictionary* attackData = [playerData objectForKey:[self.attackWayKeySet objectAtIndex:indexPath.row-1]];
            madeAndAttemptLabel.text = [NSString stringWithFormat:@"%@/%@", [attackData objectForKey:KEY_FOR_MADE_COUNT], [attackData objectForKey:KEY_FOR_ATTEMPT_COUNT]];
            foulLabel.text = [NSString stringWithFormat:@"%@", [attackData objectForKey:KEY_FOR_FOUL_COUNT]];
            turnOverLabel.text = [NSString stringWithFormat:@"%@", [attackData objectForKey:KEY_FOR_TURN_OVER_COUNT]];
            totalScoreGetLabel.text = [NSString stringWithFormat:@"%@", [attackData objectForKey:KEY_FOR_SCORE_GET]];
        }
        
        [cell addSubview:madeAndAttemptLabel];
        [cell addSubview:foulLabel];
        [cell addSubview:turnOverLabel];
        [cell addSubview:totalScoreGetLabel];
    }
    else if(indexPath.row == 14)
    {
        NSDictionary* bonusData = [playerData objectForKey:@"zone12"];
        UILabel* madeAndAttemptLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), label.frame.origin.y, tableView.frame.size.width*0.7, PLAYER_GRADE_TABLECELL_HEIGHT)];
        madeAndAttemptLabel.textAlignment = NSTextAlignmentCenter;
        madeAndAttemptLabel.layer.borderWidth = 1;
        
        label.text = [self.attackWaySet objectAtIndex:indexPath.row-1];
        if(!self.playerSelectedIndex)
            madeAndAttemptLabel.text = @"0/0";
        else
            madeAndAttemptLabel.text = [NSString stringWithFormat:@"%@/%@", [bonusData objectForKey:KEY_FOR_MADE_COUNT], [bonusData objectForKey:KEY_FOR_ATTEMPT_COUNT]];
        [cell addSubview:madeAndAttemptLabel];
    }
    else
    {
        label.text = @"總得分";
        UILabel* totalScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), label.frame.origin.y, tableView.frame.size.width*0.7, PLAYER_GRADE_TABLECELL_HEIGHT)];
        totalScoreLabel.textAlignment = NSTextAlignmentCenter;
        totalScoreLabel.layer.borderWidth = 1;
        
        if(!self.playerSelectedIndex)
            totalScoreLabel.text = @"0";
        else
            totalScoreLabel.text = [NSString stringWithFormat:@"%@", [playerData objectForKey:@"totalScoreGet"]];
        
        [cell addSubview:totalScoreLabel];
    }
    [cell addSubview:label];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == NO_TABLEVIEW_TAG)
    {
        if(indexPath.row)
        {
            self.playerSelectedIndex = (int)indexPath.row;
        
//            NSLog(@"select player index = %d", self.playerSelectedIndex);
            if(self.zoneNo && indexPath.row != self.playerCount+1)
                [self showAttackList];
        }
        else
            self.playerSelectedIndex = 0;
    
        if(!self.isShowZoneGrade)
            [(UITableView*)[self.view viewWithTag:PLAYER_GRADE_TABLEVIEW_TAG] reloadData];
        else
            [self updateZoneGradeView];

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == NO_TABLEVIEW_TAG)
    {
        if(!indexPath.row)
            return TITLE_CELL_HEIGHT;
        return CELL_HEIGHT;
    }
    //if(tableview.tag == PLAYER_GRADE_TABLEVIEW_TAG)
    return PLAYER_GRADE_TABLECELL_HEIGHT;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
