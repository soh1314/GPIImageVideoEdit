//
//  ViewController.m
//  GPU-Video-Edit
//
//  Created by xiaoke_mh on 16/4/13.
//  Copyright © 2016年 m-h. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView * _tableview;
    NSArray * _titileArr;
    NSArray * _className;
    
    
    
}


@end

@implementation ViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    NSURL * videourl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Square" ofType:@"mp4"]];
    
    self.title = @"EditList";
    
    _titileArr = @[@"录制视频+滤镜",@"本地视频+滤镜"];
    _className = @[@"CameraFilterVC",@"LocalVideoEditVC"];
    
    
    _tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableview.showsVerticalScrollIndicator = NO;
    _tableview.showsHorizontalScrollIndicator = NO;
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.rowHeight = 50.0f;
    [self.view addSubview:_tableview];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _titileArr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellId = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _titileArr[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class class = NSClassFromString(_className[indexPath.row]);
    if (class) {
        UIViewController * vc = [(UIViewController *)[class alloc] init];
        vc.title = _className[indexPath.row];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
