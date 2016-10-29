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
    
    self.fogView = [[UIView alloc] initWithFrame:self.view.frame];
    self.fogView.backgroundColor = [UIColor blackColor];
    self.fogView.alpha = 0.6;
    [self.view addSubview:self.fogView];
    
    self.teamNameView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.3, CGRectGetHeight(self.view.frame)*0.25, CGRectGetWidth(self.view.frame)*0.4, CGRectGetHeight(self.view.frame)*0.5)];
    self.teamNameView.layer.cornerRadius = 10;
    self.teamNameView.backgroundColor = [UIColor whiteColor];
   // self.teamNameView.layer.borderWidth = 2;
    [self.view addSubview:self.teamNameView];
    
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.teamNameView.frame)*0.3, 0, CGRectGetWidth(self.teamNameView.frame)*0.4, CGRectGetHeight(self.teamNameView.frame)*0.17)];
    title.text = @"比賽隊伍";
    title.textAlignment = NSTextAlignmentCenter;
    [title setFont:[UIFont systemFontOfSize:20]];
    [title setAdjustsFontSizeToFitWidth:YES];
    [self.teamNameView addSubview:title];
    
    UILabel* homeTeamLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(title.frame), CGRectGetWidth(self.teamNameView.frame)*0.3, CGRectGetHeight(self.teamNameView.frame)*0.17)];
    homeTeamLabel.text = @"你的隊伍：";
    homeTeamLabel.textAlignment = NSTextAlignmentCenter;
    [homeTeamLabel setFont:[UIFont systemFontOfSize:18]];
    [homeTeamLabel setAdjustsFontSizeToFitWidth:YES];
    [self.teamNameView addSubview:homeTeamLabel];
    
    UIButton* NTUCheckboxButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(homeTeamLabel.frame), CGRectGetMinY(homeTeamLabel.frame)+(CGRectGetHeight(homeTeamLabel.frame)-18)/2, 18, 18)];
    NTUCheckboxButton.tag = 1;
    [NTUCheckboxButton setImage:[UIImage imageNamed:@"checkbox_unselected.png"] forState:UIControlStateNormal];
    [NTUCheckboxButton setImage:[UIImage imageNamed:@"checkbox_selected.png"] forState:UIControlStateSelected];
    [NTUCheckboxButton addTarget:self action:@selector(checkboxButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.teamNameView addSubview:NTUCheckboxButton];
    
    UILabel* NTUTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(NTUCheckboxButton.frame)+5, CGRectGetMinY(homeTeamLabel.frame), CGRectGetWidth(self.teamNameView.frame)*0.5, CGRectGetHeight(self.teamNameView.frame)*0.17)];
    NTUTitleLabel.text = NAME_OF_NTU_MALE_BASKETBALL;
    NTUTitleLabel.textAlignment = NSTextAlignmentCenter;
    [NTUTitleLabel setFont:[UIFont systemFontOfSize:18]];
    [NTUTitleLabel setAdjustsFontSizeToFitWidth:YES];
    [self.teamNameView addSubview:NTUTitleLabel];
    
    UIButton* otherCheckboxButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(homeTeamLabel.frame), CGRectGetMaxY(homeTeamLabel.frame)+(CGRectGetHeight(homeTeamLabel.frame)-18)/2, 18, 18)];
    otherCheckboxButton.tag = 2;
    [otherCheckboxButton setImage:[UIImage imageNamed:@"checkbox_unselected.png"] forState:UIControlStateNormal];
    [otherCheckboxButton setImage:[UIImage imageNamed:@"checkbox_selected.png"] forState:UIControlStateSelected];
    [otherCheckboxButton addTarget:self action:@selector(checkboxButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.teamNameView addSubview:otherCheckboxButton];
    
    UITextField* otherTeamNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(otherCheckboxButton.frame)+5, CGRectGetMaxY(homeTeamLabel.frame), CGRectGetWidth(self.teamNameView.frame)*0.5, CGRectGetHeight(self.teamNameView.frame)*0.17)];
    otherTeamNameTextField.tag = 3;
    otherTeamNameTextField.layer.cornerRadius = 5;
    otherTeamNameTextField.layer.borderWidth = 1;
    otherTeamNameTextField.placeholder = @"其他";
    otherTeamNameTextField.textAlignment = NSTextAlignmentCenter;
    [self.teamNameView addSubview:otherTeamNameTextField];
    
    UILabel* awayTeamLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(otherTeamNameTextField.frame)+CGRectGetHeight(self.teamNameView.frame)*0.08, CGRectGetWidth(self.teamNameView.frame)*0.3, CGRectGetHeight(self.teamNameView.frame)*0.17)];
    awayTeamLabel.text = @"對手隊伍：";
    awayTeamLabel.textAlignment = NSTextAlignmentCenter;
    [awayTeamLabel setFont:[UIFont systemFontOfSize:18]];
    [awayTeamLabel setAdjustsFontSizeToFitWidth:YES];
    [self.teamNameView addSubview:awayTeamLabel];
    
    UITextField* awayTeamNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(awayTeamLabel.frame)+5, CGRectGetMinY(awayTeamLabel.frame), CGRectGetWidth(self.teamNameView.frame)*0.6, CGRectGetHeight(self.teamNameView.frame)*0.17)];
    awayTeamNameTextField.tag = 4;
    awayTeamNameTextField.layer.cornerRadius = 5;
    awayTeamNameTextField.layer.borderWidth = 1;
    awayTeamNameTextField.textAlignment = NSTextAlignmentCenter;
    [self.teamNameView addSubview:awayTeamNameTextField];
    
    UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.teamNameView.frame)*0.1, CGRectGetMaxY(awayTeamNameTextField.frame)+CGRectGetHeight(self.teamNameView.frame)*0.02, CGRectGetWidth(self.teamNameView.frame)*0.35, CGRectGetHeight(self.teamNameView.frame)*0.2)];
    [okButton addTarget:self action:@selector(okButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [okButton setTitle:@"確定" forState:UIControlStateNormal];
    [okButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [okButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.teamNameView addSubview:okButton];
    
    UIButton* cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(okButton.frame)+CGRectGetWidth(self.teamNameView.frame)*0.1, CGRectGetMaxY(awayTeamNameTextField.frame)+CGRectGetHeight(self.teamNameView.frame)*0.02, CGRectGetWidth(self.teamNameView.frame)*0.35, CGRectGetHeight(self.teamNameView.frame)*0.2)];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.teamNameView addSubview:cancelButton];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSArray *resultArray = [self.playerNoSet sortedArrayUsingSelector:@selector(compare:)];
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY_MM_dd"];
    NSString* recordName = [NSString stringWithFormat:@"%@_vs_%@", self.myTeamName, self.opponentName];
    
    if([segue.identifier isEqualToString:SEGUE_ID_FOR_OFFENSE])
    {
        BBROffenseViewController* mainViewCntler = [segue destinationViewController];
        mainViewCntler.playerNoSet = resultArray;
        mainViewCntler.playerCount = self.playerCount;
        mainViewCntler.myTeamName = self.myTeamName;
        mainViewCntler.opponentName = self.opponentName;
        NSString* filename = [NSString stringWithFormat:@"%@-%@", recordName, [dateFormatter stringFromDate:[NSDate date]]];
        mainViewCntler.recordName = filename;
    }
    else if([segue.identifier isEqualToString:SEGUE_ID_FOR_DEFENSE])
    {
        BBRDefenseViewController* mainViewCntler = [segue destinationViewController];
        mainViewCntler.playerNoSet = resultArray;
        mainViewCntler.playerCount = self.playerCount;
        
        NSString* filename = [NSString stringWithFormat:@"%@-%@_防守", recordName, [dateFormatter stringFromDate:[NSDate date]]];
        mainViewCntler.recordName = filename;
    }
    else if([segue.identifier isEqualToString:SEGUE_ID_FOR_BOX_SCORE])
    {
        BBRBoxScoreViewController* mainViewCntler = [segue destinationViewController];
        //NSLog(@"%@", resultArray);
        mainViewCntler.playerNoSet = resultArray;
        mainViewCntler.playerCount = self.playerCount;
        
        NSString* filename = [NSString stringWithFormat:@"%@-%@_技術", recordName, [dateFormatter stringFromDate:[NSDate date]]];
        mainViewCntler.recordName = filename;
    }
}

#pragma mark - action

- (void)cancelButtonClicked
{
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

- (void)okButtonClicked
{
    UIButton* NTUCheckboxButton = (UIButton*)[self.teamNameView viewWithTag:1];
    UIButton* otherCheckboxButton = (UIButton*)[self.teamNameView viewWithTag:2];
    
    if(!NTUCheckboxButton.isSelected && !otherCheckboxButton.isSelected)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"請選擇你的隊伍" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"好" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    else if(NTUCheckboxButton.isSelected)
        self.myTeamName = @"台大校男籃";
    else
    {
        UITextField* otherTeamNameTextField = (UITextField*)[self.teamNameView viewWithTag:3];
        self.myTeamName = otherTeamNameTextField.text;
    }
    
    UITextField* opponentNameTextField = (UITextField*)[self.teamNameView viewWithTag:4];
    self.opponentName = opponentNameTextField.text;
    
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
    [self.textFieldArray setObject:textField.text atIndexedSubscript:textField.tag-1];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.editingTextField = textField;
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
