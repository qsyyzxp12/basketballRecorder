//
//  ViewController.m
//  basketBallRecorder
//
//  Created by Lin Chih-An on 2016/2/22.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "BBRLogViewController.h"
#import "BBRMainViewController.h"
#import "BBRTableViewCell.h"

#define TITLE_CELL_HEIGHT 40
#define CELL_HEIGHT 60
@interface BBRLogViewController ()

@end

@implementation BBRLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.BBRtableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 65, self.view.frame.size.width, self.view.frame.size.height-65)];
    
    self.BBRtableView.delegate = self;
    self.BBRtableView.dataSource = self;
    
    [self.view addSubview:self.BBRtableView];

    self.textFieldArray = [NSMutableArray arrayWithCapacity:20];
    for (int i=0; i<20; i++)
        [self.textFieldArray setObject:@"" atIndexedSubscript:i];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BBRMainViewController* mainViewCntler = [segue destinationViewController];
    NSArray *resultArray = [self.playerNoSet sortedArrayUsingSelector:@selector(compare:)];
    mainViewCntler.playerNoSet = resultArray;
    mainViewCntler.playerCount = self.playerCount;
}

#pragma mark - action

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
/*
    if(self.playerCount < 5)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"人數小於5人" message:nil preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){}];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
*/        [self performSegueWithIdentifier:@"showMainController" sender:nil];
}

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
