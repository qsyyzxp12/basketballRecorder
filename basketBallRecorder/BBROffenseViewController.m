//
//  BBRMainViewController.m
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/22.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "BBROffenseViewController.h"
#import "BBRTableViewCell.h"
#import "BRAOfficeDocumentPackage.h"
#import "BBRMacro.h"
@interface BBROffenseViewController ()

@end

@implementation BBROffenseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.playerOnFloorDataArray = [NSMutableArray arrayWithCapacity:5];
    for(int i=0; i<5; i++)
    {
        NSMutableDictionary* dic = [[NSMutableDictionary  alloc] init];
        [dic setObject:[NSNumber numberWithInt:0] forKey:KEY_FOR_TIME_WHEN_GO_ON_FLOOR];
        [dic setObject:[NSNumber numberWithInt:i+1] forKey:KEY_FOR_INDEX_IN_PPP_TABLEVIEW];
        [self.playerOnFloorDataArray setObject:dic atIndexedSubscript:i];
    }
    
    self.tmpPlistPath = [NSString stringWithFormat:@"%@/Documents/tmp.plist", NSHomeDirectory()];
    self.isShowZoneGrade = YES;
    self.isRecordMode = YES;
    self.isTimerRunning = NO;
    self.playerSelectedIndex = 0;
    self.zoneNo = 0;
    self.quarterNo = 1;
    self.timeCounter = 0;
    
    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    self.restClient.delegate = self;
    
    self.attackWaySet = [[NSArray alloc] initWithObjects:@"Isolation", @"Spot Up", @"PS", @"PD", @"PR", @"PPS", @"PPD", @"Catch&Shoot", @"Fast Break", @"Low Post", @"Second", @"Drive", @"High-Low", @"Cut", @"Bonus", @"Time", nil];
    self.attackWayKeySet = [[NSArray alloc] initWithObjects:
                            @"isolation", @"spotUp", @"PS", @"PD", @"PR", @"PPS", @"PPD", @"CS",
                            @"fastBreak", @"lowPost", @"second", @"drive", @"highLow", @"cut", nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] init];
    self.navigationItem.rightBarButtonItem.title = @"本節結束";
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
 
    self.playerListTableView = [[UITableView alloc] initWithFrame:CGRectMake(55, 10, CELL_WIDTH, tableViewHeight)];
//    self.playerListTableView.backgroundColor = [UIColor redColor];
    self.playerListTableView.delegate = self;
    self.playerListTableView.dataSource = self;
    self.playerListTableView.tag = NO_TABLEVIEW_TAG;
    [self.view addSubview:self.playerListTableView];

    self.playerOnFloorListTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 10+BAR_HEIGHT, CELL_WIDTH, TITLE_CELL_HEIGHT + CELL_HEIGHT * MIN(self.playerCount, 5))];
    self.playerOnFloorListTableView.delegate = self;
    self.playerOnFloorListTableView.dataSource = self;
    self.playerOnFloorListTableView.tag = PLAYER_ON_FLOOR_TABLEVIEW_TAG;
    [self.view addSubview:self.playerOnFloorListTableView];
   
    [self drawPicture];
    [self constructAlertControllers];
    
    self.playerDataTableView = [[UITableView alloc] initWithFrame:[self.view viewWithTag:BACKGROUND_IMAGEVIEW_TAG].frame];
    self.playerDataTableView.tag = PLAYER_GRADE_TABLEVIEW_TAG;
    self.playerDataTableView.delegate = self;
    self.playerDataTableView.dataSource = self;
    self.playerDataTableView.hidden = YES;
    [self.view addSubview:self.playerDataTableView];
    
    if(self.quarterNo == END)
        [self showConclusionAndGernateXlsxFile:NO];
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
            int quarterNo[2] = {self.quarterNo, QUARTER_NO_FOR_ENTIRE_GAME};
            int playerNo[2] = {self.playerSelectedIndex-1, self.playerCount};
            for(int i=0; i<2; i++)
            {
                NSMutableArray* quarterGrade= [self.playerDataArray objectAtIndex:quarterNo[i]];
                for(int j=0; j<2; j++)
                {
                    NSMutableDictionary* playerData = [quarterGrade objectAtIndex:playerNo[j]];
                    [self increaseOffenseScoreGetToPlayerData:playerData by:1];
                    [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:1];
                }
            }
            [self updateTmpPlist];
            self.zoneNo = 0;
        }];
    
    UIAlertAction* twoPointAction = [UIAlertAction actionWithTitle:@"2分" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            int quarterNo[2] = {self.quarterNo, QUARTER_NO_FOR_ENTIRE_GAME};
            int playerNo[2] = {self.playerSelectedIndex-1, self.playerCount};
            for(int i=0; i<2; i++)
            {
                NSMutableArray* quarterGrade= [self.playerDataArray objectAtIndex:quarterNo[i]];
                for(int j=0; j<2; j++)
                {
                    NSMutableDictionary* playerData = [quarterGrade objectAtIndex:playerNo[j]];
                    [self increaseOffenseScoreGetToPlayerData:playerData by:2];
                    [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:2];
                }
            }
            [self updateTmpPlist];
            self.zoneNo = 0;
        }];
    
    UIAlertAction* threePointAction = [UIAlertAction actionWithTitle:@"3分" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            int quarterNo[2] = {self.quarterNo, QUARTER_NO_FOR_ENTIRE_GAME};
            int playerNo[2] = {self.playerSelectedIndex-1, self.playerCount};
            for(int i=0; i<2; i++)
            {
                NSMutableArray* quarterGrade= [self.playerDataArray objectAtIndex:quarterNo[i]];
                for(int j=0; j<2; j++)
                {
                    NSMutableDictionary* playerData = [quarterGrade objectAtIndex:playerNo[j]];
                    [self increaseOffenseScoreGetToPlayerData:playerData by:3];
                    [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:3];
                }
            }
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
            int quarterNo[2] = {self.quarterNo, QUARTER_NO_FOR_ENTIRE_GAME};
            int playerNo[2] = {self.playerSelectedIndex-1, self.playerCount};
            for(int i=0; i<2; i++)
            {
                NSMutableArray* quarterGrade= [self.playerDataArray objectAtIndex:quarterNo[i]];
                for(int j=0; j<2; j++)
                {
                    NSMutableDictionary* playerData = [quarterGrade objectAtIndex:playerNo[j]];
                    [self increaseOffenseScoreGetToPlayerData:playerData by:1];
                    [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:1];
                }
            }
            
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
            int quarterNo[2] = {self.quarterNo, QUARTER_NO_FOR_ENTIRE_GAME};
            int playerNo[2] = {self.playerSelectedIndex-1, self.playerCount};
            
            for(int i=0; i<2; i++)
            {
                NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:quarterNo[i]];
                for(int j=0; j<2; j++)
                {
                    NSMutableDictionary* playerData = [quarterGrade objectAtIndex:playerNo[j]];
                    if(self.zoneNo != 12)
                        [self updateOffenseGradeForOneMadeToPlayerData:playerData];
                    [self updateZoneGradeForOneMadeToPlayerData:playerData];
                    [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:offset];
                }
            }
            [self updateTmpPlist];
            self.zoneNo = 0;
        }];
    UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"Attempt" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            self.OldPlayerDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.playerDataArray]];
            
            int quarterNo[2] = {self.quarterNo, QUARTER_NO_FOR_ENTIRE_GAME};
            int playerNo[2] = {self.playerSelectedIndex-1, self.playerCount};
            
            for(int i=0; i<2; i++)
            {
                NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:quarterNo[i]];
                for(int j=0; j<2; j++)
                {
                    NSMutableDictionary* playerData = [quarterGrade objectAtIndex:playerNo[j]];
                    if(self.zoneNo != 12)
                        [self updateOffenseGradeForOneAttempToPlayerData:playerData];
                    [self updateZoneGradeForOndeAttemptToPlayerData:playerData];
                }
            }
            
            [self updateTmpPlist];
            self.zoneNo = 0;
            NSLog(@"%@", self.playerDataArray);
        }];
    
    UIAlertAction* foulAction = [UIAlertAction actionWithTitle:@"Foul" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action)
        {
            self.OldPlayerDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.playerDataArray]];
            
            int quarterNo[2] = {self.quarterNo, QUARTER_NO_FOR_ENTIRE_GAME};
            int playerNo[2] = {self.playerSelectedIndex-1, self.playerCount};
            
            for(int i=0; i<2; i++)
            {
                NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:quarterNo[i]];
                for(int j=0; j<2; j++)
                {
                    NSMutableDictionary* playerData = [quarterGrade objectAtIndex:playerNo[j]];
                    [self updateOffenseGradeForOneFoulToPlayerData:playerData];
                }
            }
            
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
            
            int quarterNo[2] = {self.quarterNo, QUARTER_NO_FOR_ENTIRE_GAME};
            int playerNo[2] = {self.playerSelectedIndex-1, self.playerCount};
            
            for(int i=0; i<2; i++)
            {
                NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:quarterNo[i]];
                for(int j=0; j<2; j++)
                {
                    NSMutableDictionary* playerData = [quarterGrade objectAtIndex:playerNo[j]];
                    [self updateOffenseGradeForOneMadeToPlayerData:playerData];
                    [self updateOffenseGradeForOneFoulToPlayerData:playerData];
                    [self updateZoneGradeForOneMadeToPlayerData:playerData];
                    [self updateTotalScoreOnePlayerGetToPlayerData:playerData withScore:offset];
                }
            }
            [self presentViewController:self.andOneAlert animated:YES completion:nil];
        }];
    
    UIAlertAction* turnOverAction = [UIAlertAction actionWithTitle:@"Turn Over" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action)
        {
            self.OldPlayerDataArray = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self.playerDataArray]];
            
            int quarterNo[2] = {self.quarterNo, QUARTER_NO_FOR_ENTIRE_GAME};
            int playerNo[2] = {self.playerSelectedIndex-1, self.playerCount};
            
            for(int i=0; i<2; i++)
            {
                NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:quarterNo[i]];
                for(int j=0; j<2; j++)
                {
                    NSMutableDictionary* playerData = [quarterGrade objectAtIndex:playerNo[j]];
                    [self updateOffenseGradeForOneTurnOverToPlayerData:playerData];
                }
            }
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

    for(int i=0; i<[self.attackWayKeySet count]; i++)
    {
        NSString* title = [self.attackWaySet objectAtIndex:i];
        UIAlertAction* action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
            {
                self.keyForSearch = [self.attackWayKeySet objectAtIndex:i];
                [self presentViewController:self.resultAlert animated:YES completion:nil];
            }];
        [self.attackWayAlert addAction:action];
    }
    [self.attackWayAlert addAction:cancelAction];

    //Next Quarter Alert
    self.nextQuarterAlert = [UIAlertController alertControllerWithTitle:@"確定？"
                                                              message:nil preferredStyle:UIAlertControllerStyleAlert];
    yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action)
        {
            [self goNextQuarter];
        }];
    noAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){}];
    
    [self.nextQuarterAlert addAction:yesAction];
    [self.nextQuarterAlert addAction:noAction];
    
    //Alert for determining if there is playoff or not
    self.playoffOrNotAlert = [UIAlertController alertControllerWithTitle:@"是否有延長賽？"
                                                                message:nil preferredStyle:UIAlertControllerStyleAlert];
    yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            [self goNextQuarter];
        }];
    noAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
        {
            [self showConclusionAndGernateXlsxFile:YES];
        }];
    cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){}];
    
    [self.playoffOrNotAlert addAction:yesAction];
    [self.playoffOrNotAlert addAction:noAction];
    [self.playoffOrNotAlert addAction:cancelAction];
    
    self.finishOrNotAlert = [UIAlertController alertControllerWithTitle:@"確定？"
                                                                message:nil preferredStyle:UIAlertControllerStyleAlert];
    yesAction = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action)
        {
            [self showConclusionAndGernateXlsxFile:YES];
        }];
    noAction = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){}];
    [self.finishOrNotAlert addAction:yesAction];
    [self.finishOrNotAlert addAction:noAction];
}

-(void) goNextQuarter
{
    self.quarterNo++;
    [self extendPlayerDataWithQuarter:self.quarterNo];
    [self updateZoneGradeView];
    
    NSMutableDictionary* tmpPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.tmpPlistPath];
    [tmpPlistDic setObject:[NSNumber numberWithInt:self.quarterNo] forKey:KEY_FOR_LAST_RECORD_QUARTER];
    
    [tmpPlistDic writeToFile:self.tmpPlistPath atomically:YES];
  
    [self updateNavigationTitle];
    if(self.quarterNo == 4)
        self.navigationItem.rightBarButtonItem.action = @selector(finishButtonClicked);
}

-(void) showConclusionAndGernateXlsxFile:(BOOL)generateXlsxFile
{
    self.isRecordMode = NO;
    if(!self.isShowZoneGrade)
        self.playerDataTableView.hidden = NO;
    
    self.isShowZoneGrade = YES;
    [self.undoButton removeFromSuperview];
    [self.timeButton removeFromSuperview];
    [self.switchModeButton removeFromSuperview];

    
    [self.playerOnFloorListTableView removeFromSuperview];
    [self.playerListTableView setFrame:CGRectMake(25, 10, self.playerListTableView.frame.size.width, self.playerListTableView.frame.size.height)];
    self.playerSelectedIndex = 0;
    
    for(int i=1; i<13; i++)
    {
        UIImageView* zone = (UIImageView*)[self.view viewWithTag:i];
        [zone setUserInteractionEnabled:NO];
    }
    if (self.zoneNo)
        ((UIImageView*)[self.view viewWithTag:self.zoneNo]).highlighted = NO;
    
    //Update Record.plist
    if(!self.showOldRecordNo)
    {
        NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
        NSMutableArray* recordPlistArray = [NSMutableArray arrayWithContentsOfFile:recordPlistPath];
        
        NSMutableDictionary* newItem = [[NSMutableDictionary alloc] init];
        [newItem setObject:[NSNumber numberWithInt:END] forKey:KEY_FOR_LAST_RECORD_QUARTER];
        [newItem setObject:self.playerDataArray forKey:KEY_FOR_GRADE];
        [newItem setObject:self.playerNoSet forKey:KEY_FOR_PLAYER_NO_SET];
        [newItem setObject:self.recordName forKey:KEY_FOR_NAME];
        [newItem setObject:OFFENSE_TYPE_DATA forKey:KEY_FOR_DATA_TYPE];
        
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
    if(generateXlsxFile)
    {
        [self performSelectorInBackground:@selector(xlsxFileGenerateAndUpload:) withObject:[NSNumber numberWithInt:self.quarterNo]];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] init];
        self.navigationItem.leftBarButtonItem.title = @"＜選單";
        self.navigationItem.leftBarButtonItem.target = self;
        self.navigationItem.leftBarButtonItem.action = @selector(backMenuButtonClicked);
    }
    
    self.quarterNo = 0;
    
    self.navigationItem.rightBarButtonItem.title = @"數據成績";
    self.navigationItem.rightBarButtonItem.action = @selector(showOffenseGradeButtonClicked);
    self.navigationItem.title = @"總成績";
    
    //Update Zone Grade;
    [self updateZoneGradeView];
    
    self.lastQuarterButton.hidden = NO;
    self.nextQuarterButton.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - File Operation

-(void) reloadPlayerGradeFromRecordPlist
{
    NSString* recordPlistPath = [NSString stringWithFormat:@"%@/Documents/record.plist", NSHomeDirectory()];
    NSArray* recordPlistArray = [NSArray arrayWithContentsOfFile:recordPlistPath];
    NSDictionary* dataDic = [recordPlistArray objectAtIndex:self.showOldRecordNo-1];
    
    NSLog(@"%@", dataDic);
    
    self.playerDataArray = [dataDic objectForKey:KEY_FOR_GRADE];
    self.playerNoSet = [dataDic objectForKey:KEY_FOR_PLAYER_NO_SET];
    self.quarterNo = END;
    self.playerCount = (int)[self.playerNoSet count];
    
    self.navigationItem.rightBarButtonItem.title = @"數據成績";
    self.navigationItem.rightBarButtonItem.action = @selector(showOffenseGradeButtonClicked);
}

-(void) reloadPlayerGradeFromTmpPlist
{
    NSMutableDictionary* tmpPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.tmpPlistPath];
    self.playerDataArray = [tmpPlistDic objectForKey:KEY_FOR_GRADE];
    self.playerNoSet = [tmpPlistDic objectForKey:KEY_FOR_PLAYER_NO_SET];
    self.quarterNo = [[tmpPlistDic objectForKey:KEY_FOR_LAST_RECORD_QUARTER] intValue];
    self.recordName = [tmpPlistDic objectForKey:KEY_FOR_NAME];
    self.timeCounter = [(NSNumber*)[tmpPlistDic objectForKey:KEY_FOR_TIME] intValue];
    self.playerCount = (int)[self.playerNoSet count];
    
    [self updateNavigationTitle];
    if(self.quarterNo > 3)
        self.navigationItem.rightBarButtonItem.action = @selector(finishButtonClicked);
}

-(void)updateTmpPlist
{
    NSMutableDictionary* tmpPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.tmpPlistPath];
    [tmpPlistDic setObject:self.playerDataArray forKey:KEY_FOR_GRADE];
    
    [tmpPlistDic writeToFile:self.tmpPlistPath atomically:YES];
}

-(void) xlsxFileGenerateAndUpload: (NSNumber*) quarterNo
{
    //Generate the xlsx file
    NSString *documentPath = [[NSBundle mainBundle] pathForResource:@"spreadsheet_for_offense" ofType:@"xlsx"];
    BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:documentPath];
    
    for(int i=0; i<quarterNo.intValue+1; i++)
    {
        BRAWorksheet *worksheet;
        if(i == [spreadsheet.workbook.worksheets count])
        {
            NSString* worksheetName;
            switch (i)
            {
                case 1: worksheetName = @"第一節"; break;
                case 2: worksheetName = @"第二節"; break;
                case 3: worksheetName = @"第三節"; break;
                case 4: worksheetName = @"第四節"; break;
                case 5: worksheetName = @"延長賽第一節"; break;
                case 6: worksheetName = @"延長賽第二節"; break;
                case 7: worksheetName = @"延長賽第三節"; break;
                case 8: worksheetName = @"延長賽第四節"; break;
                case 9: worksheetName = @"延長賽第五節"; break;
                case 10: worksheetName = @"延長賽第六節"; break;
            }
            worksheet = [spreadsheet.workbook createWorksheetNamed:worksheetName byCopyingWorksheet:spreadsheet.workbook.worksheets[0]];
            [worksheet save];
        }
        else
            worksheet = spreadsheet.workbook.worksheets[i];
        
        NSString* cellRef;
        NSArray* totalGradeArray = [self.playerDataArray objectAtIndex:i];
        for(int i=0; i<self.playerCount+1; i++)
        {
            char outIndex = '\0';
            char interIndex = 'A';
            cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex++, i+3];
            if(i < self.playerCount)
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:self.playerNoSet[i]];
            else
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:@"全隊"];
            
            NSDictionary* playerDataDic = [totalGradeArray objectAtIndex:i];
            for(int j=0; j<[self.attackWayKeySet count]; j++)
            {
                NSDictionary* offenseGradeDic = [playerDataDic objectForKey:self.attackWayKeySet[j]];
                NSString* madeCount = [offenseGradeDic objectForKey:KEY_FOR_MADE_COUNT];
                if(interIndex == 91) // (int)'Z' == 90
                {
                    if(outIndex != '\0')
                        outIndex++;
                    else
                        outIndex = 'A';
                    interIndex = 65;
                }
                cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex++, i+3];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:madeCount];
                
                NSString* attemptCount = [offenseGradeDic objectForKey:KEY_FOR_ATTEMPT_COUNT];
                if(interIndex == 91) // (int)'Z' == 90
                {
                    if(outIndex != '\0')
                        outIndex++;
                    else
                        outIndex = 'A';
                    interIndex = 65;
                }
                cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex++, i+3];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:attemptCount];
                
                NSString* foulCount = [offenseGradeDic objectForKey:KEY_FOR_FOUL_COUNT];
                if(interIndex == 91) // (int)'Z' == 90
                {
                    if(outIndex != '\0')
                        outIndex++;
                    else
                        outIndex = 'A';
                    interIndex = 65;
                }
                cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex++, i+3];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:foulCount];
                
                NSString* turnOverCount = [offenseGradeDic objectForKey:KEY_FOR_TURNOVER_COUNT];
                if(interIndex == 91) // (int)'Z' == 90
                {
                    if(outIndex != '\0')
                        outIndex++;
                    else
                        outIndex = 'A';
                    interIndex = 65;
                }
                cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex++, i+3];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:turnOverCount];
                
                NSString* score = [offenseGradeDic objectForKey:KEY_FOR_SCORE_GET];
                if(interIndex == 91) // (int)'Z' == 90
                {
                    if(outIndex != '\0')
                        outIndex++;
                    else
                        outIndex = 'A';
                    interIndex = 65;
                }
                cellRef = [NSString stringWithFormat:@"%c%c%d", outIndex, interIndex++, i+3];
                [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:score];
            }
            
            NSDictionary* bonusGrade = [playerDataDic objectForKey:@"zone12"];
            NSString* madeCountInBonus = [bonusGrade objectForKey:KEY_FOR_MADE_COUNT];
            cellRef = [NSString stringWithFormat:@"BT%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:madeCountInBonus];
            
            NSString* attemptCountInBonus = [bonusGrade objectForKey:KEY_FOR_ATTEMPT_COUNT];
            cellRef = [NSString stringWithFormat:@"BU%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:attemptCountInBonus];
            
            cellRef = [NSString stringWithFormat:@"BV%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:madeCountInBonus];
            
            NSString* totalMadeCount = [playerDataDic objectForKey:KEY_FOR_TOTAL_MADE_COUNT];
            cellRef = [NSString stringWithFormat:@"BW%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:totalMadeCount];
            
            NSString* totalAttemptCount = [playerDataDic objectForKey:KEY_FOR_TOTAL_ATTEMPT_COUNT];
            cellRef = [NSString stringWithFormat:@"BX%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:totalAttemptCount];
            
            NSString* totalFoulCount = [playerDataDic objectForKey:KEY_FOR_TOTAL_FOUL_COUNT];
            cellRef = [NSString stringWithFormat:@"BY%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:totalFoulCount];
            
            NSString* totalTurnoverCount = [playerDataDic objectForKey:KEY_FOR_TOTAL_TURNOVER_COUNT];
            cellRef = [NSString stringWithFormat:@"BZ%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:totalTurnoverCount];
            
            NSString* totalScore = [playerDataDic objectForKey:KEY_FOR_TOTAL_SCORE_GET];
            cellRef = [NSString stringWithFormat:@"CA%d", i+3];
            [[worksheet cellForCellReference:cellRef shouldCreate:YES] setStringValue:totalScore];
            
        }

    }
    
    //Save the xlsx to the app space in the device
    NSString *sheetPath = [NSString stringWithFormat:@"%@/Documents/spreadsheet.xlsx", NSHomeDirectory()];
    NSFileManager* fm = [[NSFileManager alloc] init];
    
    if([fm fileExistsAtPath:sheetPath])
        [fm removeItemAtPath:sheetPath error:nil];
    
    [spreadsheet saveAs:sheetPath];
    
    //Dropbox
    if (![[DBSession sharedSession] isLinked])
        [[DBSession sharedSession] linkFromController:self];

    NSString* filename = [NSString stringWithFormat:@"%@.xlsx", self.recordName];
    
    NSArray* agus = [[NSArray alloc] initWithObjects:filename, sheetPath, nil];
    [self performSelectorOnMainThread:@selector(uploadXlsxFile:) withObject:agus waitUntilDone:0];
  //  [self.restClient uploadFile:filename toPath:@"/" withParentRev:nil fromPath:sheetPath];
}

-(void) uploadXlsxFile:(NSArray*) parameters
{
    [self.restClient uploadFile:[parameters objectAtIndex:0] toPath:@"/" withParentRev:nil fromPath:[parameters objectAtIndex:1]];
}

#pragma mark - DataStruct Updating

-(void)updateTimeOnFloorOfPlayerWithIndexInOnFloorTableView:(int)index
{
    NSMutableDictionary* dic = [self.playerOnFloorDataArray objectAtIndex:index];
    NSNumber* indexInPPPTableviewNo = [dic objectForKey:KEY_FOR_INDEX_IN_PPP_TABLEVIEW];
    NSNumber* timeWhenWentOnFloor = [dic objectForKey:KEY_FOR_TIME_WHEN_GO_ON_FLOOR];
    int timeOnFloor = self.timeCounter - timeWhenWentOnFloor.intValue;
    
    NSMutableArray* quarterGrade = [self.playerDataArray objectAtIndex:self.quarterNo];
    NSMutableDictionary* playerData = [quarterGrade objectAtIndex:indexInPPPTableviewNo.intValue - 1];
    int time = timeOnFloor + ((NSNumber*)[playerData objectForKey:KEY_FOR_TOTAL_TIME_ON_FLOOR]).intValue;
    [playerData setObject:[NSNumber numberWithInt:time] forKey:KEY_FOR_TOTAL_TIME_ON_FLOOR];
    
    NSMutableArray* playerAllGameGrade = [self.playerDataArray objectAtIndex:0];
    playerData = [playerAllGameGrade objectAtIndex:indexInPPPTableviewNo.intValue-1];
    time = timeOnFloor + ((NSNumber*)[playerData objectForKey:KEY_FOR_TOTAL_TIME_ON_FLOOR]).intValue;
    [playerData setObject:[NSNumber numberWithInt:time] forKey:KEY_FOR_TOTAL_TIME_ON_FLOOR];
    [self updateTmpPlist];
}

-(void) newPlayerGradeDataStruct
{
    self.playerDataArray = [NSMutableArray arrayWithCapacity:2];

    [self extendPlayerDataWithQuarter:0];
    [self extendPlayerDataWithQuarter:1];
    
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
    [tmpPlistDic setObject:[NSNumber numberWithInt:0] forKey:KEY_FOR_TIME];
    [tmpPlistDic setObject:OFFENSE_TYPE_DATA forKey:KEY_FOR_DATA_TYPE];
    
    [tmpPlistDic writeToFile:self.tmpPlistPath atomically:YES];
    
    self.navigationItem.title = @"第一節";
}

-(void) extendPlayerDataWithQuarter:(int) quarterNo
{
    NSMutableArray* quarterData = [NSMutableArray arrayWithCapacity:self.playerCount+1];
    for(int i=0; i<self.playerCount+1; i++)
    {
        NSMutableDictionary* playerDataItem = [[NSMutableDictionary alloc] init];
        
        if(i < [self.playerNoSet count])
            [playerDataItem setObject:[self.playerNoSet objectAtIndex:i] forKey:@"no"];
        else
            [playerDataItem setObject:@"Team" forKey:@"no"];
        
        [playerDataItem setObject:[NSString stringWithFormat:@"%d", quarterNo] forKey:@"QUARTER"];
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
            [result2 setObject:@"0" forKey:KEY_FOR_TURNOVER_COUNT];
            [result2 setObject:@"0" forKey:KEY_FOR_SCORE_GET];
            [playerDataItem setObject:result2 forKey:[self.attackWayKeySet objectAtIndex:j]];
        }
        
        [playerDataItem setObject:@"0" forKey:KEY_FOR_TOTAL_SCORE_GET];
        [playerDataItem setObject:@"0" forKey:KEY_FOR_TOTAL_MADE_COUNT];
        [playerDataItem setObject:@"0" forKey:KEY_FOR_TOTAL_ATTEMPT_COUNT];
        [playerDataItem setObject:@"0" forKey:KEY_FOR_TOTAL_FOUL_COUNT];
        [playerDataItem setObject:@"0" forKey:KEY_FOR_TOTAL_TURNOVER_COUNT];
        [playerDataItem setObject:@"0" forKey:KEY_FOR_TOTAL_TIME_ON_FLOOR];
        
        [quarterData addObject:playerDataItem];
    }
    [self.playerDataArray addObject:quarterData];
    [self updateTmpPlist];
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
    
    int totalAttemptCount = [[playerData objectForKey:KEY_FOR_TOTAL_ATTEMPT_COUNT] intValue];
    [playerData setObject:[NSString stringWithFormat:@"%d", totalAttemptCount+1] forKey:KEY_FOR_TOTAL_ATTEMPT_COUNT];
    
    int totalMadeCount = [[playerData objectForKey:KEY_FOR_TOTAL_MADE_COUNT] intValue];
    [playerData setObject:[NSString stringWithFormat:@"%d", totalMadeCount+1] forKey:KEY_FOR_TOTAL_MADE_COUNT];
}

-(void)updateOffenseGradeForOneAttempToPlayerData:(NSMutableDictionary*) playerData
{
    NSMutableDictionary* attackData = [playerData objectForKey:self.keyForSearch];
    int attemptCount = [[attackData objectForKey:KEY_FOR_ATTEMPT_COUNT] intValue];
    [attackData setObject:[NSString stringWithFormat:@"%d", attemptCount+1] forKey:KEY_FOR_ATTEMPT_COUNT];
    [playerData setObject:attackData forKey:self.keyForSearch];
    
    int totalAttemptCount = [[playerData objectForKey:KEY_FOR_TOTAL_ATTEMPT_COUNT] intValue];
    [playerData setObject:[NSString stringWithFormat:@"%d", totalAttemptCount+1] forKey:KEY_FOR_TOTAL_ATTEMPT_COUNT];
}

-(void) updateOffenseGradeForOneFoulToPlayerData:(NSMutableDictionary*) playerData
{
    NSMutableDictionary* attackData = [playerData objectForKey:self.keyForSearch];
    int foulCount = [[attackData objectForKey:KEY_FOR_FOUL_COUNT] intValue];
    [attackData setObject:[NSString stringWithFormat:@"%d", foulCount+1] forKey:KEY_FOR_FOUL_COUNT];
    
    [playerData setObject:attackData forKey:self.keyForSearch];
    
    int totalFoulCount = [[playerData objectForKey:KEY_FOR_TOTAL_FOUL_COUNT] intValue];
    [playerData setObject:[NSString stringWithFormat:@"%d", totalFoulCount+1] forKey:KEY_FOR_TOTAL_FOUL_COUNT];
}

-(void) updateOffenseGradeForOneTurnOverToPlayerData:(NSMutableDictionary*) playerData
{
    NSMutableDictionary* attackData = [playerData objectForKey:self.keyForSearch];
    
    int turnOverCount = [[attackData objectForKey:KEY_FOR_TURNOVER_COUNT] intValue];
    [attackData setObject:[NSString stringWithFormat:@"%d", turnOverCount+1] forKey:KEY_FOR_TURNOVER_COUNT];
    
    [playerData setObject:attackData forKey:self.keyForSearch];
    
    int totalTurnoverCount = [[playerData objectForKey:KEY_FOR_TOTAL_TURNOVER_COUNT] intValue];
    [playerData setObject:[NSString stringWithFormat:@"%d", totalTurnoverCount+1] forKey:KEY_FOR_TOTAL_TURNOVER_COUNT];
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
    int totalScoreGet = [[playerData objectForKey:KEY_FOR_TOTAL_SCORE_GET] intValue];
    NSString* totalScoreGetStr = [NSString stringWithFormat:@"%d", totalScoreGet+score];
    
    [playerData setObject:totalScoreGetStr forKey:KEY_FOR_TOTAL_SCORE_GET];
}

#pragma mark - UI Updating

-(void)timeCounterChange
{
    self.timeCounter++;
    int min = self.timeCounter/60;
    int sec = self.timeCounter%60;
    [self.timeButton setTitle:[NSString stringWithFormat:@"%02d:%02d", min, sec] forState:UIControlStateNormal];
    
    if(self.timeCounter%3 == 0)
    {
        NSMutableDictionary* tmpPlistDic = [NSMutableDictionary dictionaryWithContentsOfFile:self.tmpPlistPath];
        [tmpPlistDic setObject:[NSNumber numberWithInt:self.timeCounter] forKey:KEY_FOR_TIME];
        [tmpPlistDic writeToFile:self.tmpPlistPath atomically:YES];
    }
}

-(void)updateGradeView
{
    switch(self.quarterNo)
    {
        case 0:
            self.navigationItem.title = @"總成績";
            break;
        case 1:
            self.navigationItem.title = @"第一節成績";
            break;
        case 2:
            self.navigationItem.title = @"第二節成績";
            break;
        case 3:
            self.navigationItem.title = @"第三節成績";
            break;
        case 4:
            self.navigationItem.title = @"第四節成績";
            break;
        case 5:
            self.navigationItem.title = @"延長賽第一節成績";
            break;
        case 6:
            self.navigationItem.title = @"延長賽第二節成績";
            break;
        case 7:
            self.navigationItem.title = @"延長賽第三節成績";
            break;
        case 8:
            self.navigationItem.title = @"延長賽第四節成績";
            break;
        case 9:
            self.navigationItem.title = @"延長賽第五節成績";
            break;
        case 10:
            self.navigationItem.title = @"延長賽第六節成績";
            break;
    }
    
    if(self.isShowZoneGrade)
        [self updateZoneGradeView];
    else
        [(UITableView*)[self.view viewWithTag:PLAYER_GRADE_TABLEVIEW_TAG] reloadData];
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

-(void) updateNavigationTitle
{
    switch(self.quarterNo)
    {
        case 1:
            self.navigationItem.title = @"第一節";
            break;
        case 2:
            self.navigationItem.title = @"第二節";
            break;
        case 3:
            self.navigationItem.title = @"第三節";
            break;
        case 4:
            self.navigationItem.title = @"第四節";
            break;
        case 5:
            self.navigationItem.title = @"延長賽第一節";
            break;
        case 6:
            self.navigationItem.title = @"延長賽第二節";
            break;
        case 7:
            self.navigationItem.title = @"延長賽第三節";
            break;
        case 8:
            self.navigationItem.title = @"延長賽第四節";
            break;
        case 9:
            self.navigationItem.title = @"延長賽第五節";
            break;
        case 10:
            self.navigationItem.title = @"延長賽第六節";
            break;
    }
}

-(void)hideZone12orNot:(BOOL)yesOrNo
{
    [self.view viewWithTag:12].hidden = yesOrNo;
    [self.view viewWithTag:1201].hidden = yesOrNo;
    [self.view viewWithTag:1202].hidden = yesOrNo;
    [self.view viewWithTag:1203].hidden = yesOrNo;
}

- (void) drawPicture
{
    self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];
    
    CGFloat x = (self.view.frame.size.width- CGRectGetMaxX(self.playerListTableView.frame) - BACKGROUND_WIDTH)/5 + CGRectGetMaxX(self.playerListTableView.frame);
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
    
    //Show Grade Switch Button
    self.switchModeButton = [[UIButton alloc] init];
    [self.switchModeButton setFrame:CGRectMake(CGRectGetMinX(bonusZone.frame), CGRectGetMinY(self.backgroundImageView.frame), bonusZone.frame.size.width, bonusZone.frame.size.height)];
    self.switchModeButton.layer.borderWidth = 1;
    self.switchModeButton.layer.cornerRadius = 5;
    self.switchModeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.switchModeButton setTitle:@"成績" forState:UIControlStateNormal];
    [self.switchModeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.switchModeButton addTarget:self action:@selector(switchButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.switchModeButton setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:self.switchModeButton];
    
    //Undo Button
    self.undoButton = [[UIButton alloc] init];
    [self.undoButton setFrame:CGRectMake(CGRectGetMinX(bonusZone.frame), CGRectGetMaxY(self.switchModeButton.frame)+15, bonusZone.frame.size.width, bonusZone.frame.size.height)];
    self.undoButton.layer.borderWidth = 1;
    self.undoButton.layer.cornerRadius = 5;
    [self.undoButton setTitle:@"Undo" forState:UIControlStateNormal];
    [self.undoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.undoButton addTarget:self action:@selector(undoButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.undoButton setShowsTouchWhenHighlighted:YES];
    [self.view addSubview:self.undoButton];
    
    //Timer Button
    self.timeButton = [[UIButton alloc] init];
    [self.timeButton setFrame:CGRectMake(CGRectGetMinX(self.undoButton.frame), CGRectGetMaxY(self.undoButton.frame)+15, bonusZone.frame.size.width, bonusZone.frame.size.height)];
    if(self.timeCounter)
    {
        int min = self.timeCounter/60;
        int sec = self.timeCounter%60;
        [self.timeButton setTitle:[NSString stringWithFormat:@"%02d:%02d", min, sec] forState:UIControlStateNormal];
    }
    else
        [self.timeButton setTitle:@"00:00" forState:UIControlStateNormal];
    [self.timeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.timeButton addTarget:self action:@selector(timeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.timeButton];
    
    //Add Two Arrow for Quarter change
    self.lastQuarterButton = [[UIButton alloc] init];
    [self.lastQuarterButton setImage:[UIImage imageNamed:@"leftArrow.png"] forState:UIControlStateNormal];
    [self.lastQuarterButton sizeToFit];
    self.lastQuarterButton.frame = CGRectMake(self.backgroundImageView.frame.origin.x-self.lastQuarterButton.frame.size.width*0.25-5, self.backgroundImageView.frame.origin.y+40, self.lastQuarterButton.frame.size.width*0.25, self.lastQuarterButton.frame.size.height*0.25);
    [self.lastQuarterButton addTarget:self action:@selector(gradeOfLastQuarterButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.lastQuarterButton.hidden = YES;
    [self.view addSubview:self.lastQuarterButton];
    
    self.nextQuarterButton = [[UIButton alloc] init];
    [self.nextQuarterButton setImage:[UIImage imageNamed:@"rightArrow.png"] forState:UIControlStateNormal];
    [self.nextQuarterButton sizeToFit];
    self.nextQuarterButton.frame = CGRectMake(CGRectGetMaxX(self.backgroundImageView.frame)+5, self.backgroundImageView.frame.origin.y+40, self.nextQuarterButton.frame.size.width*0.25, self.nextQuarterButton.frame.size.height*0.25);
    [self.nextQuarterButton addTarget:self action:@selector(gradeOfNextQuaterButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.nextQuarterButton.hidden = YES;
    [self.view addSubview:self.nextQuarterButton];
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

#pragma mark - Button Clicked

-(void) timeButtonClicked
{
    if(!self.isTimerRunning)
    {
        [self.timeButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCounterChange) userInfo:nil repeats:YES];
        self.isTimerRunning = YES;
    }
    else
    {
        [self.timeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.timer invalidate];
        self.timer = nil;
        self.isTimerRunning = NO;
        for(int i=0; i<5; i++)
        {
            [self updateTimeOnFloorOfPlayerWithIndexInOnFloorTableView:i];
            NSMutableDictionary* dic = [self.playerOnFloorDataArray objectAtIndex:i];
            [dic setObject:[NSNumber numberWithInt:self.timeCounter] forKey:KEY_FOR_TIME_WHEN_GO_ON_FLOOR];
        }
        
    }
}

-(void)backMenuButtonClicked
{
    [self.navigationController popToRootViewControllerAnimated:YES];
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

- (void) nextQuarterButtonClicked
{
    [self presentViewController:self.nextQuarterAlert animated:YES completion:nil];
}

- (void) finishButtonClicked
{
    if(self.quarterNo != 10)
        [self presentViewController:self.playoffOrNotAlert animated:YES completion:nil];
    else
        [self presentViewController:self.finishOrNotAlert animated:YES completion:nil];
}

- (void) gradeOfNextQuaterButtonClicked
{
    if (self.quarterNo < [self.playerDataArray count]-1)
    {
        self.quarterNo++;
        [self updateGradeView];
    }
}

- (void) gradeOfLastQuarterButtonClicked
{
    if(self.quarterNo > 0)
    {
        self.quarterNo--;
        [self updateGradeView];
    }
}

- (void) showZoneGradeButtonClicked
{
    self.isShowZoneGrade = YES;
    [self updateZoneGradeView];
    self.navigationItem.rightBarButtonItem.title = @"數據成績";
    self.navigationItem.rightBarButtonItem.action = @selector(showOffenseGradeButtonClicked);
    
    [self hideZone12orNot:NO];
    
    [self.view viewWithTag:PLAYER_GRADE_TABLEVIEW_TAG].hidden = YES;
    
}

- (void) showOffenseGradeButtonClicked
{
    self.isShowZoneGrade = NO;
    self.navigationItem.rightBarButtonItem.title = @"區域成績";
    self.navigationItem.rightBarButtonItem.action = @selector(showZoneGradeButtonClicked);
    
    [self hideZone12orNot:YES];
    
    self.playerDataTableView.hidden = NO;
    [self.playerDataTableView reloadData];
}

- (void) switchButtonClicked
{
    [self.playerListTableView deselectRowAtIndexPath:self.playerListTableView.indexPathForSelectedRow animated:NO];
    self.playerSelectedIndex = 0;
    if (self.isRecordMode)
    {
        [self.playerOnFloorListTableView removeFromSuperview];
        [self.playerListTableView setFrame:CGRectMake(25, 10, self.playerListTableView.frame.size.width, self.playerListTableView.frame.size.height)];
        for(int i=1; i<13; i++)
        {
            UIImageView* zone = (UIImageView*)[self.view viewWithTag:i];
            [zone setUserInteractionEnabled:NO];
        }
        if (self.zoneNo)
            ((UIImageView*)[self.view viewWithTag:self.zoneNo]).highlighted = NO;
        
        [self.switchModeButton setTitle:@"紀錄" forState:UIControlStateNormal];
        [self.playerDataTableView reloadData];
        self.nextQuarterButton.hidden = NO;
        self.lastQuarterButton.hidden = NO;
        self.timeButton.hidden = YES;
        self.undoButton.hidden = YES;
        self.isRecordMode = NO;
        self.navigationItem.rightBarButtonItem.title = @"數據成績";
        self.navigationItem.rightBarButtonItem.action = @selector(showOffenseGradeButtonClicked);
        
        [self.playerOnFloorListTableView deselectRowAtIndexPath:self.playerOnFloorListTableView.indexPathForSelectedRow animated:NO];
        [self updateGradeView];
    }
    else
    {
        [self.view addSubview:self.playerOnFloorListTableView];
        [self.playerListTableView setFrame:CGRectMake(55, 10, self.playerListTableView.frame.size.width, self.playerListTableView.frame.size.height)];
        for(int i=1; i<13; i++)
        {
            UIImageView* zone = (UIImageView*)[self.view viewWithTag:i];
            [zone setUserInteractionEnabled:YES];
        }
        
        [self hideZone12orNot:NO];
        
        self.quarterNo = (int)[self.playerDataArray count]-1;
        [self.switchModeButton setTitle:@"成績" forState:UIControlStateNormal];
        self.playerDataTableView.hidden = YES;
        self.nextQuarterButton.hidden = YES;
        self.lastQuarterButton.hidden = YES;
        self.timeButton.hidden = NO;
        self.undoButton.hidden = NO;
        self.isRecordMode = YES;
        [self updateNavigationTitle];
        self.navigationItem.rightBarButtonItem.title = @"本節結束";
        if(self.quarterNo < 4)
            self.navigationItem.rightBarButtonItem.action = @selector(nextQuarterButtonClicked);
        else
            self.navigationItem.rightBarButtonItem.action = @selector(finishButtonClicked);
        [self updateZoneGradeView];
        
        if(!self.isShowZoneGrade)
        {
            self.isShowZoneGrade = YES;
            [self.view viewWithTag:PLAYER_GRADE_TABLEVIEW_TAG].hidden = YES;
        }
    }
}

- (void) undoButtonClicked
{
    if(self.OldPlayerDataArray)
    {
        self.playerDataArray = self.OldPlayerDataArray;
        
        [self updateZoneGradeView];
        [self updateTmpPlist];
    }
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == NO_TABLEVIEW_TAG)
       return (self.playerCount + 2); //One for title, the other one for team grade
    else if(tableView.tag == PLAYER_ON_FLOOR_TABLEVIEW_TAG)
        return MIN(self.playerCount, 5)+1;
    return [self.attackWayKeySet count] + 4;
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
                cell.NoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, TITLE_CELL_HEIGHT)];
                cell.NoLabel.textAlignment = NSTextAlignmentCenter;
                cell.NoLabel.backgroundColor = [UIColor lightGrayColor];
                cell.NoLabel.text = @"PPP";
                [cell addSubview:cell.NoLabel];
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
                cell.NoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, CELL_HEIGHT)];
                cell.NoLabel.textAlignment = NSTextAlignmentCenter;
                cell.NoLabel.text = @"全隊";
                [cell addSubview:cell.NoLabel];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }
            return cell;
        }
        
        BBRTableViewCell* cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.layer.borderWidth = 1;
        cell.NoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, CELL_HEIGHT)];
        cell.NoLabel.textAlignment = NSTextAlignmentCenter;
        cell.NoLabel.text = [NSString stringWithFormat:@"%@", [self.playerNoSet objectAtIndex:indexPath.row-1]];
        [cell addSubview:cell.NoLabel];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        return cell;
    }
    else if(tableView.tag == PLAYER_ON_FLOOR_TABLEVIEW_TAG)
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
                label.text = @"場上";
                [cell addSubview:label];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            return cell;
        }
        
        BBRTableViewCell* cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.layer.borderWidth = 1;
        cell.NoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_WIDTH, CELL_HEIGHT)];
        cell.NoLabel.textAlignment = NSTextAlignmentCenter;
        cell.NoLabel.text = [NSString stringWithFormat:@"%@", [self.playerNoSet objectAtIndex:indexPath.row-1]];
        [cell addSubview:cell.NoLabel];
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
    
    if(indexPath.row < [self.attackWayKeySet count]+1 || indexPath.row == [self.attackWayKeySet count]+3)
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
        
        if(indexPath.row != [self.attackWayKeySet count]+3)
            label.text = [self.attackWaySet objectAtIndex:indexPath.row-1];
        else
            label.text = @"總成績";
        
        if(!self.playerSelectedIndex)
        {
            madeAndAttemptLabel.text = @"0/0";
            foulLabel.text = @"0";
            turnOverLabel.text = @"0";
            totalScoreGetLabel.text = @"0";
        }
        else
        {
            if(indexPath.row != [self.attackWayKeySet count]+3)
            {
                NSDictionary* attackData = [playerData objectForKey:[self.attackWayKeySet objectAtIndex:indexPath.row-1]];
                madeAndAttemptLabel.text = [NSString stringWithFormat:@"%@/%@", [attackData objectForKey:KEY_FOR_MADE_COUNT], [attackData objectForKey:KEY_FOR_ATTEMPT_COUNT]];
                foulLabel.text = [attackData objectForKey:KEY_FOR_FOUL_COUNT];
                turnOverLabel.text = [attackData objectForKey:KEY_FOR_TURNOVER_COUNT];
                totalScoreGetLabel.text = [attackData objectForKey:KEY_FOR_SCORE_GET];
            }
            else
            {
                madeAndAttemptLabel.text = [NSString stringWithFormat:@"%@/%@", [playerData objectForKey:KEY_FOR_TOTAL_MADE_COUNT], [playerData objectForKey:KEY_FOR_TOTAL_ATTEMPT_COUNT]];
                foulLabel.text = [playerData objectForKey:KEY_FOR_TOTAL_FOUL_COUNT];
                turnOverLabel.text = [playerData objectForKey:KEY_FOR_TOTAL_TURNOVER_COUNT];
                totalScoreGetLabel.text = [playerData objectForKey:KEY_FOR_TOTAL_SCORE_GET];
            }
        }
        
        [cell addSubview:madeAndAttemptLabel];
        [cell addSubview:foulLabel];
        [cell addSubview:turnOverLabel];
        [cell addSubview:totalScoreGetLabel];
    }
    else if(indexPath.row == [self.attackWayKeySet count]+1)
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
    else if(indexPath.row == [self.attackWayKeySet count]+2)
    {
        NSNumber* time = [playerData objectForKey:KEY_FOR_TOTAL_TIME_ON_FLOOR];
        int min = time.intValue/60;
        int sec = time.intValue%60;
        label.text = [self.attackWaySet objectAtIndex:indexPath.row-1];
        
        UILabel* timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(label.frame), label.frame.origin.y, tableView.frame.size.width*0.7, PLAYER_GRADE_TABLECELL_HEIGHT)];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.layer.borderWidth = 1;
        if(self.playerSelectedIndex != self.playerCount + 1)
            timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", min, sec];
        else
            timeLabel.text = @"-";
        [cell addSubview:timeLabel];
    }
    [cell addSubview:label];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == PLAYER_ON_FLOOR_TABLEVIEW_TAG)
    {
        if(indexPath.row)
        {
            NSMutableDictionary* dic = [self.playerOnFloorDataArray objectAtIndex:indexPath.row-1];
            NSNumber *playerSelectedIndex = [dic objectForKey:KEY_FOR_INDEX_IN_PPP_TABLEVIEW];
            self.playerSelectedIndex = playerSelectedIndex.intValue;
        
            if(self.zoneNo)
                [self showAttackList];
        }
        else
            self.playerSelectedIndex = 0;
    
        [self updateZoneGradeView];
    }
    else if(tableView.tag == NO_TABLEVIEW_TAG)
    {
        if(!self.isRecordMode)
        {
            self.playerSelectedIndex = (int)indexPath.row;
            if(!self.isShowZoneGrade)
                [(UITableView*)[self.view viewWithTag:PLAYER_GRADE_TABLEVIEW_TAG] reloadData];
            else
                [self updateZoneGradeView];
        }
        else if(indexPath.row != 0 && indexPath.row != self.playerCount+1)
        {
            BBRTableViewCell* cellOfSelected = [tableView cellForRowAtIndexPath:indexPath];
            
            UIAlertController* changePlayerAlert = [UIAlertController alertControllerWithTitle:@"下場球員" message:nil preferredStyle: UIAlertControllerStyleAlert];
            BOOL isPlayerOnFloorAlready = NO;
            for(int i=1; i<6; i++)
            {
                NSIndexPath* index = [NSIndexPath indexPathForRow:i inSection:0];
                BBRTableViewCell* cellOfChanged = [self.playerOnFloorListTableView cellForRowAtIndexPath:index];
                if([cellOfChanged.NoLabel.text isEqualToString:cellOfSelected.NoLabel.text])
                {
                    isPlayerOnFloorAlready = YES;
                    break;
                }
                UIAlertAction* playerOnFloorNoAction = [UIAlertAction actionWithTitle:cellOfChanged.NoLabel.text style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                {
                    //caculate the player being placed's time on floor
                    [self updateTimeOnFloorOfPlayerWithIndexInOnFloorTableView:i-1];
                    
                    //update the data of the player on floor
                    NSMutableDictionary* dic = [self.playerOnFloorDataArray objectAtIndex:i-1];
                    cellOfChanged.NoLabel.text = cellOfSelected.NoLabel.text;
                    [dic setObject:[NSNumber numberWithInt:[cellOfSelected.NoLabel.text intValue]] forKey:KEY_FOR_INDEX_IN_PPP_TABLEVIEW];
                    [dic setObject:[NSNumber numberWithInt:self.timeCounter] forKey:KEY_FOR_TIME_WHEN_GO_ON_FLOOR];
                }];
                [changePlayerAlert addAction:playerOnFloorNoAction];
            }
            if(!isPlayerOnFloorAlready)
            {
                UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){}];
                [changePlayerAlert addAction:cancelAction];
                [self presentViewController:changePlayerAlert animated:YES completion:nil];
            }
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        else if(indexPath.row == self.playerCount+1)
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == NO_TABLEVIEW_TAG || tableView.tag == PLAYER_ON_FLOOR_TABLEVIEW_TAG)
    {
        if(!indexPath.row)
            return TITLE_CELL_HEIGHT;
        return CELL_HEIGHT;
    }
    //if(tableview.tag == PLAYER_GRADE_TABLEVIEW_TAG)
    return PLAYER_GRADE_TABLECELL_HEIGHT;
}

#pragma mark - DBRestClientDelegate

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
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
