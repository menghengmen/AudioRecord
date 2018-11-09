//
//  ViewController.m
//  Audio
//
//  Created by 哈哈 on 2018/11/9.
//  Copyright © 2018年 MengHeng. All rights reserved.
//

#import "ViewController.h"
#import "SYAudio.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) NSString *filePath;

@property (nonatomic, strong) UITableView *mainTableView;
@property (nonatomic, strong) NSMutableArray *mainArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"录音及播放音频";
    
   
    
    UIBarButtonItem *clearItem = [[UIBarButtonItem alloc] initWithTitle:@"clear" style:UIBarButtonItemStyleDone target:self action:@selector(clearItemClick:)];
    UIBarButtonItem *stopItem = [[UIBarButtonItem alloc] initWithTitle:@"stop" style:UIBarButtonItemStyleDone target:self action:@selector(stopItemClick:)];
    UIBarButtonItem *playItem = [[UIBarButtonItem alloc] initWithTitle:@"play" style:UIBarButtonItemStyleDone target:self action:@selector(playItemClick:)];
    self.navigationItem.rightBarButtonItems = @[clearItem, stopItem, playItem];
    
    [self setUI];
}

#pragma mark - 视图

- (void)setUI
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
    self.mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 10.0 - 40.0 - 10.0) style:UITableViewStylePlain];
    [self.view addSubview:self.mainTableView];
    self.mainTableView.tableFooterView = [[UIView alloc] init];
    self.mainTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.mainTableView.backgroundColor = [UIColor clearColor];
    self.mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.mainTableView.separatorInset = UIEdgeInsetsZero;
    self.mainTableView.layoutMargins = UIEdgeInsetsZero;
    self.mainTableView.delegate = self;
    self.mainTableView.dataSource = self;
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:button];
    button.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(10.0, (CGRectGetHeight(self.view.bounds) - 10.0 - 40.0), (CGRectGetWidth(self.view.bounds) - 10.0 * 2), 40.0);
    button.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
    [button setTitle:@"按下开始录音" forState:UIControlStateNormal];
    [button setTitle:@"正在录音 释放停止录音" forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    // 录音响应
    [button addTarget:self action:@selector(recordStartButtonDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(recordStopButtonUp:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(recordStopButtonExit:) forControlEvents:UIControlEventTouchDragExit];
}

#pragma Action
- (void)recordStartButtonDown:(UIButton *)button
{
    [self startRecorder];
}

- (void)recordStopButtonUp:(UIButton *)button
{
    [self saveRecorder];
}

- (void)recordStopButtonExit:(UIButton *)button
{
    [self saveRecorder];
}
#pragma mark - 音频处理方法

// 开始录音
- (void)startRecorder
{
    self.filePath = [SYAudioFile SYAudioGetFilePathWithDate];
    [[SYAudio shareAudio] audioRecorderStartWithFilePath:self.filePath];
}

// 停止录音，并保存
- (void)saveRecorder
{
    [[SYAudio shareAudio] audioRecorderStop];
    
    // 保存音频信息
    if (!self.mainArray)
    {
        self.mainArray = [[NSMutableArray alloc] init];
    }
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:self.filePath forKey:@"FilePath"];
    NSString *fileName = [SYAudioFile SYAudioGetFileNameWithFilePath:self.filePath type:YES];
    [dict setValue:fileName forKey:@"FileName"];
    long long fileSize = [SYAudioFile SYAudioGetFileSizeWithFilePath:self.filePath];
    [dict setValue:@(fileSize) forKey:@"FileSize"];
    NSTimeInterval fileTime = [[SYAudio shareAudio] durationAudioRecorderWithFilePath:self.filePath];
    [dict setValue:@(fileTime) forKey:@"FileTime"];
    [self.mainArray addObject:dict];
    
    // 刷新列表
    [self.mainTableView reloadData];
}


#pragma mark - UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mainArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const identifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        
        cell.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        cell.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.textColor = [UIColor orangeColor];
        
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    NSDictionary *dict = self.mainArray[indexPath.row];
    NSString *fileName = dict[@"FileName"];
    NSNumber *fileSize = dict[@"FileSize"];
    NSNumber *fileTime = dict[@"FileTime"];
    NSString *filePath = dict[@"FilePath"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@(size=%@Byte duration=%.2fs)", fileName, fileSize, fileTime.doubleValue];
    cell.detailTextLabel.text = filePath;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = self.mainArray[indexPath.row];
    NSString *filePath = dict[@"FilePath"];
    
    [[SYAudio shareAudio] audioPlayWithFilePath:filePath];
    
}
@end
