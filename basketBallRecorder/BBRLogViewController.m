//
//  ViewController.m
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/22.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "BBRLogViewController.h"
#import "BBROffenseViewController.h"
#import "BBRTableViewCell.h"
#import "BBRMenuViewController.h"
#import "BBRDefenseViewController.h"
#import "BBRBoxScoreViewController.h"
#import "BBRMacro.h"

#define TITLE_CELL_HEIGHT 40
#define CELL_HEIGHT 60

@interface BBRLogViewController ()

@end

@implementation BBRLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.BBRtableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.2, self.view.frame.size.height*0.1, self.view.frame.size.width*0.6, self.view.frame.size.height*0.85)];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    NSLocale *datelocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_TW"];
    datePicker.locale = datelocale;
    datePicker.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    datePicker.datePickerMode = UIDatePickerModeDate;
    [datePicker addTarget:self action:@selector(chooseDate:) forControlEvents:UIControlEventValueChanged];
    
    self.BBRtableView.delegate = self;
    self.BBRtableView.dataSource = self;
    
    [self.view addSubview:self.BBRtableView];

    self.textFieldArray = [NSMutableArray arrayWithCapacity:20];
    for (int i=0; i<20; i++)
        [self.textFieldArray setObject:@"" atIndexedSubscript:i];
    
//    UIAlertController* nameUncompleteAlert = [UIAlertController alertControllerWithTitle:@"" message:@"隊伍名稱輸入不完全" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                              handler:^(UIAlertAction *action){}];

//    [nameUncompleteAlert addAction:okAction];
    
    UIAlertController* otherAlert = [UIAlertController alertControllerWithTitle:@"比賽隊伍" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
    {
        NSArray<UITextField*>* textFields = otherAlert.textFields;
        self.myTeamName = textFields[0].text;
        self.opponentName = textFields[1].text;
        self.gameDate = textFields[2].text;
     /* if([teamName.text isEqualToString:@""] || [anotherTeamName isEqual:@""])
        {
            [self presentViewController:nameUncompleteAlert animated:YES completion:nil];
        }
        else*/
        }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
        {
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
        }];
    
    [otherAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.delegate = self;
         textField.placeholder = @"你的隊伍名稱";
     }];
    [otherAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.delegate = self;
         textField.placeholder = @"對手隊伍名稱";
     }];
    [otherAlert addTextFieldWithConfigurationHandler:^(UITextField* textField)
     {
         textField.delegate = self;
         textField.placeholder = @"YYYY_MM_DD";
         textField.inputView = datePicker;
     }];
    [otherAlert addAction:okAction];
    [otherAlert addAction:cancelAction];
    
    UIAlertController* opponentAlert = [UIAlertController alertControllerWithTitle:@"對手球隊" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [opponentAlert addTextFieldWithConfigurationHandler:^(UITextField *textField)
    {
        textField.delegate = self;
        textField.placeholder = @"名稱";
    }];
    [opponentAlert addTextFieldWithConfigurationHandler:^(UITextField* textField)
    {
        textField.delegate = self;
        textField.placeholder = @"YYYY_MM_DD";
        textField.inputView = datePicker;
    }];
    okAction = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            NSArray<UITextField*>* textFields = opponentAlert.textFields;
            self.opponentName = textFields[0].text;
            self.gameDate = textFields[1].text;
        }];
    cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
        {
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
        }];
    [opponentAlert addAction:okAction];
    [opponentAlert addAction:cancelAction];
    
    
    NSArray<NSString*> *SBLTeamNameArray = [NSArray arrayWithObjects:@"裕隆納智捷", @"璞園建築", @"台灣啤酒", @"富邦勇士", @"台灣銀行", @"金門酒廠", @"達欣工程", nil];
    
    UIAlertController* SBLAlert2 = [UIAlertController alertControllerWithTitle:@"對手隊伍" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    for(NSString* name in SBLTeamNameArray)
    {
        UIAlertAction* nameAction = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
            {
                self.opponentName = name;
                [self.view addSubview:self.fogView];
                [self.view addSubview:self.teamNameView];
            }];
        [SBLAlert2 addAction:nameAction];
    }
    cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
        {
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
        }];
    [SBLAlert2 addAction:cancelAction];
    
    
    UIAlertController* SBLAlert = [UIAlertController alertControllerWithTitle:@"你的隊伍" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    for(NSString* name in SBLTeamNameArray)
    {
        UIAlertAction* nameAction = [UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
            {
                self.myTeamName = name;
                [self presentViewController:SBLAlert2 animated:YES completion:nil];
            }];
        [SBLAlert addAction:nameAction];
    }
    cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
        {
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
        }];
    [SBLAlert addAction:cancelAction];
    
    UIAlertController* youtTeamAlert = [UIAlertController alertControllerWithTitle:@"你的球隊" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* NTUAction = [UIAlertAction actionWithTitle:NAME_OF_NTU_MALE_BASKETBALL style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            self.myTeamName = NAME_OF_NTU_MALE_BASKETBALL;
            self.isSBLGame = NO;
            [self presentViewController:opponentAlert animated:YES completion:nil];
        }];
    
    UIAlertAction* SBLAction = [UIAlertAction actionWithTitle:@"SBL球隊" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            self.isSBLGame = YES;
            [self presentViewController:SBLAlert animated:YES completion:nil];
        }];
    
    UIAlertAction* otherAction = [UIAlertAction actionWithTitle:@"其他" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
            self.isSBLGame = NO;
            [self presentViewController:otherAlert animated:YES completion:nil];
        }];
    
    cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action)
        {
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
        }];
    [youtTeamAlert addAction:NTUAction];
#ifdef BIJI
    [youtTeamAlert addAction:SBLAction];
#endif
    [youtTeamAlert addAction:otherAction];
    [youtTeamAlert addAction:cancelAction];
    [self presentViewController:youtTeamAlert animated:YES completion:nil];
    
    self.fogView = [[UIView alloc] initWithFrame:self.view.frame];
    self.fogView.backgroundColor = [UIColor blackColor];
    self.fogView.alpha = 0.6;
    
    self.teamNameView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.3, CGRectGetHeight(self.view.frame)*0.1, CGRectGetWidth(self.view.frame)*0.4, CGRectGetHeight(self.view.frame)*0.8)];
    self.teamNameView.layer.cornerRadius = 10;
    self.teamNameView.backgroundColor = [UIColor whiteColor];
    
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.teamNameView.frame)*0.3, CGRectGetWidth(self.teamNameView.frame)*0.03, CGRectGetWidth(self.teamNameView.frame)*0.4, CGRectGetHeight(self.teamNameView.frame)*0.1)];
    title.text = @"比賽資訊";
    title.textAlignment = NSTextAlignmentCenter;
    [title setFont:[UIFont systemFontOfSize:20]];
    [title setAdjustsFontSizeToFitWidth:YES];
    [self.teamNameView addSubview:title];
    
    UILabel* homeTeamLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(title.frame)+CGRectGetHeight(self.teamNameView.frame)*0.02, CGRectGetWidth(self.teamNameView.frame)*0.3, CGRectGetHeight(self.teamNameView.frame)*0.1)];
    homeTeamLabel.text = @"比賽類型：";
    homeTeamLabel.textAlignment = NSTextAlignmentCenter;
    [homeTeamLabel setFont:[UIFont systemFontOfSize:18]];
    [homeTeamLabel setAdjustsFontSizeToFitWidth:YES];
    [self.teamNameView addSubview:homeTeamLabel];
    
    UIButton* RegularCheckboxButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(homeTeamLabel.frame), CGRectGetMinY(homeTeamLabel.frame)+(CGRectGetHeight(homeTeamLabel.frame)-18)/2, 18, 18)];
    RegularCheckboxButton.tag = 1;
    [RegularCheckboxButton setImage:[UIImage imageNamed:@"checkbox_unselected.png"] forState:UIControlStateNormal];
    [RegularCheckboxButton setImage:[UIImage imageNamed:@"checkbox_selected.png"] forState:UIControlStateSelected];
    [RegularCheckboxButton addTarget:self action:@selector(checkboxButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.teamNameView addSubview:RegularCheckboxButton];
    
    UILabel* RegularTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(RegularCheckboxButton.frame)+5, CGRectGetMinY(homeTeamLabel.frame), CGRectGetWidth(self.teamNameView.frame)*0.5, CGRectGetHeight(self.teamNameView.frame)*0.1)];
    RegularTitleLabel.text = @"例行賽";
    RegularTitleLabel.textAlignment = NSTextAlignmentCenter;
    [RegularTitleLabel setFont:[UIFont systemFontOfSize:18]];
    [RegularTitleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.teamNameView addSubview:RegularTitleLabel];
    
    UIButton* PlayoffCheckboxButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(homeTeamLabel.frame), CGRectGetMaxY(homeTeamLabel.frame)+(CGRectGetHeight(homeTeamLabel.frame)-18)/2, 18, 18)];
    PlayoffCheckboxButton.tag = 2;
    [PlayoffCheckboxButton setImage:[UIImage imageNamed:@"checkbox_unselected.png"] forState:UIControlStateNormal];
    [PlayoffCheckboxButton setImage:[UIImage imageNamed:@"checkbox_selected.png"] forState:UIControlStateSelected];
    [PlayoffCheckboxButton addTarget:self action:@selector(checkboxButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.teamNameView addSubview:PlayoffCheckboxButton];
    
    UILabel* PlayoffTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(PlayoffCheckboxButton.frame)+5, CGRectGetMaxY(RegularTitleLabel.frame), CGRectGetWidth(self.teamNameView.frame)*0.5, CGRectGetHeight(self.teamNameView.frame)*0.1)];
    PlayoffTitleLabel.text = @"季後賽";
    PlayoffTitleLabel.textAlignment = NSTextAlignmentCenter;
    [PlayoffTitleLabel setFont:[UIFont systemFontOfSize:18]];
    [PlayoffTitleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.teamNameView addSubview:PlayoffTitleLabel];
    
    UILabel* sessionNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(PlayoffTitleLabel.frame)+CGRectGetHeight(self.teamNameView.frame)*0.05, CGRectGetWidth(self.teamNameView.frame)*0.3, CGRectGetHeight(self.teamNameView.frame)*0.1)];
    sessionNoLabel.text = @"球季編號：";
    sessionNoLabel.textAlignment = NSTextAlignmentCenter;
    [sessionNoLabel setFont:[UIFont systemFontOfSize:18]];
    [sessionNoLabel setAdjustsFontSizeToFitWidth:YES];
    [self.teamNameView addSubview:sessionNoLabel];
    
    UITextField* sessionNoTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(sessionNoLabel.frame)+5, CGRectGetMinY(sessionNoLabel.frame), CGRectGetWidth(self.teamNameView.frame)*0.6, CGRectGetHeight(self.teamNameView.frame)*0.1)];
    sessionNoTextField.tag = 4;
    sessionNoTextField.delegate = self;
    sessionNoTextField.layer.cornerRadius = 5;
    sessionNoTextField.layer.borderWidth = 1;
    sessionNoTextField.textAlignment = NSTextAlignmentCenter;
    [self.teamNameView addSubview:sessionNoTextField];
    
    UILabel* gameNoLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(sessionNoLabel.frame)+CGRectGetHeight(self.teamNameView.frame)*0.05, CGRectGetWidth(self.teamNameView.frame)*0.3, CGRectGetHeight(self.teamNameView.frame)*0.1)];
    gameNoLabel.text = @"比賽編號：";
    gameNoLabel.textAlignment = NSTextAlignmentCenter;
    [gameNoLabel setFont:[UIFont systemFontOfSize:18]];
    [gameNoLabel setAdjustsFontSizeToFitWidth:YES];
    [self.teamNameView addSubview:gameNoLabel];
    
    UITextField* gameNoTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(gameNoLabel.frame)+5, CGRectGetMinY(gameNoLabel.frame), CGRectGetWidth(self.teamNameView.frame)*0.6, CGRectGetHeight(self.teamNameView.frame)*0.1)];
    gameNoTextField.tag = 5;
    gameNoTextField.delegate = self;
    gameNoTextField.layer.cornerRadius = 5;
    gameNoTextField.layer.borderWidth = 1;
    gameNoTextField.textAlignment = NSTextAlignmentCenter;
    [self.teamNameView addSubview:gameNoTextField];
    
    UILabel* dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(gameNoLabel.frame)+CGRectGetHeight(self.teamNameView.frame)*0.05, CGRectGetWidth(self.teamNameView.frame)*0.3, CGRectGetHeight(self.teamNameView.frame)*0.1)];
    dateLabel.text = @"比賽日期：";
    dateLabel.textAlignment = NSTextAlignmentCenter;
    [dateLabel setFont:[UIFont systemFontOfSize:18]];
    [dateLabel setAdjustsFontSizeToFitWidth:YES];
    [self.teamNameView addSubview:dateLabel];
    
    UITextField* dateTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(dateLabel.frame)+5, CGRectGetMinY(dateLabel.frame), CGRectGetWidth(self.teamNameView.frame)*0.6, CGRectGetHeight(self.teamNameView.frame)*0.1)];
    dateTextField.tag = 6;
    dateTextField.delegate = self;
    dateTextField.layer.cornerRadius = 5;
    dateTextField.layer.borderWidth = 1;
    dateTextField.textAlignment = NSTextAlignmentCenter;
    dateTextField.inputView = datePicker;
    [self.teamNameView addSubview:dateTextField];
    
    UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.teamNameView.frame)*0.1, CGRectGetMaxY(dateTextField.frame)+CGRectGetHeight(self.teamNameView.frame)*0.04, CGRectGetWidth(self.teamNameView.frame)*0.35, CGRectGetHeight(self.teamNameView.frame)*0.1125)];
    [okButton addTarget:self action:@selector(okButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [okButton setTitle:@"確定" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [okButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.teamNameView addSubview:okButton];
    
    UIButton* cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(okButton.frame)+CGRectGetWidth(self.teamNameView.frame)*0.1, CGRectGetMinY(okButton.frame), CGRectGetWidth(self.teamNameView.frame)*0.35, CGRectGetHeight(self.teamNameView.frame)*0.1125)];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.teamNameView addSubview:cancelButton];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSArray *resultArray = [self.playerNoSet sortedArrayUsingSelector:@selector(compare:)];
    NSString* recordName = [NSString stringWithFormat:@"%@_vs_%@", self.myTeamName, self.opponentName];
    
    if([segue.identifier isEqualToString:SEGUE_ID_FOR_OFFENSE])
    {
        BBROffenseViewController* mainViewCntler = [segue destinationViewController];
        mainViewCntler.playerNoSet = resultArray;
        mainViewCntler.playerCount = self.playerCount;
        mainViewCntler.myTeamName = self.myTeamName;
        mainViewCntler.opponentName = self.opponentName;
        mainViewCntler.isSBLGame = self.isSBLGame;
        mainViewCntler.sessionNo = self.sessionNo;
        mainViewCntler.gameNo = self.gameNo;
        mainViewCntler.gameType = self.gameType;
        mainViewCntler.gameDate = self.gameDate;
        NSString* filename;
        if(!self.isSBLGame)
            filename = [NSString stringWithFormat:@"%@-%@", recordName, self.gameDate];
        else
            filename = [NSString stringWithFormat:@"%@%@-%@-%@", self.sessionNo, self.gameNo, recordName, self.gameDate];
        mainViewCntler.recordName = filename;
    }
    else if([segue.identifier isEqualToString:SEGUE_ID_FOR_DEFENSE])
    {
        BBRDefenseViewController* mainViewCntler = [segue destinationViewController];
        mainViewCntler.playerNoSet = resultArray;
        mainViewCntler.playerCount = self.playerCount;
        mainViewCntler.myTeamName = self.myTeamName;
        mainViewCntler.isSBLGame = self.isSBLGame;
        mainViewCntler.sessionNo = self.sessionNo;
        mainViewCntler.gameNo = self.gameNo;
        mainViewCntler.gameType = self.gameType;
        mainViewCntler.gameDate = self.gameDate;
        
        NSString* filename = [NSString stringWithFormat:@"%@-%@_防守", recordName, self.gameDate];
        mainViewCntler.recordName = filename;
    }
    else if([segue.identifier isEqualToString:SEGUE_ID_FOR_BOX_SCORE])
    {
        BBRBoxScoreViewController* mainViewCntler = [segue destinationViewController];
        //NSLog(@"%@", resultArray);
        mainViewCntler.playerNoSet = resultArray;
        mainViewCntler.playerCount = self.playerCount;
        mainViewCntler.isSBLGame = self.isSBLGame;
        mainViewCntler.sessionNo = self.sessionNo;
        mainViewCntler.gameNo = self.gameNo;
        mainViewCntler.gameType = self.gameType;
        mainViewCntler.myTeamName = self.myTeamName;
        mainViewCntler.gameDate = self.gameDate;
        
        NSString* filename = [NSString stringWithFormat:@"%@-%@_技術", recordName, self.gameDate];
        mainViewCntler.recordName = filename;
    }
}

#pragma mark - action

-(void)chooseDate:(UIDatePicker *)datePicker
{
    NSDate *date = datePicker.date;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYY_MM_dd"];
    self.editingTextField.text = [df stringFromDate:date];
}

- (void)cancelButtonClicked
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (void)okButtonClicked
{
    UIButton* regularCheckboxButton = (UIButton*)[self.teamNameView viewWithTag:1];
    UIButton* playoffCheckboxButton = (UIButton*)[self.teamNameView viewWithTag:2];
    
    if(!regularCheckboxButton.isSelected && !playoffCheckboxButton.isSelected)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"請選擇比賽類型" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else if(regularCheckboxButton.isSelected)
        self.gameType = REGULAR_GAME;
    else
        self.gameType = PLAYOFFS_GAME;
    
    UITextField* sessionNoTextField = (UITextField*)[self.teamNameView viewWithTag:4];
    self.sessionNo = sessionNoTextField.text;
    if(self.sessionNo.length < 2)
        self.sessionNo = [NSString stringWithFormat:@"0%@", self.sessionNo];
    
    UITextField* gameNoTextField = (UITextField*)[self.teamNameView viewWithTag:5];
    self.gameNo = gameNoTextField.text;
    if(self.gameNo.length < 2)
        self.gameNo = [NSString stringWithFormat:@"0%@", self.gameNo];
    
    UITextField* gameDateTextField = (UITextField*)[self.teamNameView viewWithTag:6];
    self.gameDate = gameDateTextField.text;
    
    [self.teamNameView removeFromSuperview];
    [self.fogView removeFromSuperview];
}

-(void) checkboxButtonClicked:(UIButton*) sender
{
    sender.selected = !sender.selected;
    UIButton* theOtherCheckButton = [self.teamNameView viewWithTag:!(sender.tag-1)+1];
    if(theOtherCheckButton.isSelected)
        theOtherCheckButton.selected = !theOtherCheckButton.selected;
}

- (IBAction)finishButtonClicked:(id)sender
{
    [self.editingTextField resignFirstResponder];
    self.playerNoSet = [NSMutableArray arrayWithCapacity:20];
    self.playerCount = 0;
    for (NSString* noStr in self.textFieldArray)
    {
        if (![noStr isEqualToString:@""])
        {
            [self.playerNoSet addObject:noStr];
            self.playerCount++;
        }
    }

    if(self.playerCount < 5)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"人數小於5人" message:nil preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"紀錄項目" message:nil preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction* offenseAction = [UIAlertAction actionWithTitle:@"進攻" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
            {
                [self performSegueWithIdentifier:SEGUE_ID_FOR_OFFENSE sender:nil];
            }];
        UIAlertAction* defenseAction = [UIAlertAction actionWithTitle:@"防守" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
            {
                [self performSegueWithIdentifier:SEGUE_ID_FOR_DEFENSE sender:nil];
            }];
        UIAlertAction* boxScoreAction = [UIAlertAction actionWithTitle:@"技術" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
            {
                [self performSegueWithIdentifier:SEGUE_ID_FOR_BOX_SCORE sender:nil];
            }];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action){}];
        [alert addAction:offenseAction];
        [alert addAction:defenseAction];
        [alert addAction:boxScoreAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

/*
- (IBAction)clearButtonClicked:(id)sender
{
//    UITableViewCell *onecell = [tableView cellForRowAtIndexPath:indexPath];
    for (int i=1; i<21; i++)
    {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        BBRTableViewCell* cell = [self.BBRtableView cellForRowAtIndexPath:indexPath];
        cell.numberTextField.text = @"";
    }
    for (int i=0; i<20; i++)
        [self.textFieldArray setObject:@"" atIndexedSubscript:i];
}
*/
#pragma mark - tableView delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 21;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"indexPath = %ld", (long)indexPath.row);
    if(indexPath.row == 0)
    {
        BBRTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"title"];
        if(!cell)
        {
            cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"title"];
            cell.layer.borderWidth = 1;
            
            cell.indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_HEIGHT, TITLE_CELL_HEIGHT)];
            cell.indexLabel.font = [UIFont systemFontOfSize:20];
            cell.indexLabel.textAlignment = NSTextAlignmentCenter;
            cell.indexLabel.backgroundColor = [UIColor lightGrayColor];
            cell.indexLabel.text = @"人數";
            [cell addSubview:cell.indexLabel];
            
            UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(CELL_HEIGHT, 0, tableView.frame.size.width-CELL_HEIGHT, TITLE_CELL_HEIGHT)];
            title.layer.borderWidth = 1;
            title.font= [UIFont systemFontOfSize:20];
            title.textAlignment = NSTextAlignmentCenter;
            title.text = @"背號";
            [cell addSubview:title];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }

    BBRTableViewCell* cell = [[BBRTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];

    cell.layer.borderWidth = 1;

    cell.indexLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CELL_HEIGHT, CELL_HEIGHT)];
    cell.indexLabel.font = [UIFont systemFontOfSize:20];
    cell.indexLabel.textAlignment = NSTextAlignmentCenter;
    cell.indexLabel.backgroundColor = [UIColor lightGrayColor];
    cell.indexLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    [cell addSubview:cell.indexLabel];
            
    cell.numberTextField = [[UITextField alloc] initWithFrame:CGRectMake(CELL_HEIGHT, 0, tableView.frame.size.width-CELL_HEIGHT, CELL_HEIGHT)];
    cell.numberTextField.layer.borderWidth = 1;
    cell.numberTextField.tag = indexPath.row;
    cell.numberTextField.textAlignment = NSTextAlignmentCenter;
    cell.numberTextField.text = [self.textFieldArray objectAtIndex:indexPath.row-1];
    cell.numberTextField.delegate = self;
    [cell addSubview:cell.numberTextField];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.editingTextField resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(!indexPath.row)
        return TITLE_CELL_HEIGHT;
    return CELL_HEIGHT;
}

#pragma mark - textField

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    self.teamNameView.frame = CGRectMake(CGRectGetWidth(self.view.frame)*0.3, CGRectGetHeight(self.view.frame)*0.1, CGRectGetWidth(self.view.frame)*0.4, CGRectGetHeight(self.view.frame)*0.8);
    
    if([textField isDescendantOfView:self.BBRtableView])
        [self.textFieldArray setObject:textField.text atIndexedSubscript:textField.tag-1];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([textField isDescendantOfView:self.teamNameView])
    {
        CGRect textFieldRectInView = [self.teamNameView convertRect:textField.frame toView:self.view];
        if(CGRectGetMaxY(textFieldRectInView) > CGRectGetHeight(self.view.frame)-258)
        {
            CGFloat x = self.teamNameView.frame.origin.x;
            CGFloat y = self.teamNameView.frame.origin.y - 100 /*+ CGRectGetMaxY(self.teamNameView.frame) - (CGRectGetHeight(self.view.frame)-258)*/;
            self.teamNameView.frame = CGRectMake(x, y, self.teamNameView.frame.size.width, self.teamNameView.frame.size.height);
        }
    }
    self.editingTextField = textField;
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
