//
//  ViewController.m
//  ZhifuDemo
//
//  Created by  陈午阳 on 16/4/18.
//  Copyright © 2016年  陈午阳. All rights reserved.
//

#import "ViewController.h"
#import "Order.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"
#import "APAuthV2Info.h"
#import "Product.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *payButton = [UIButton buttonWithType:UIButtonTypeCustom];
    payButton.frame = CGRectMake(100, 200, 100, 40);
    payButton.backgroundColor = [UIColor yellowColor];
    [payButton addTarget:self action:@selector(payButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payButton];

}



- (void)payButtonAction:(id)sender
{
    //这里的三个参数是公司和支付宝签约之后得到的，没有这三个参数无法完成支付
    NSString *partner = @"2088121361642385";
    NSString *seller = @"13971524120@163.com";
    NSString *privateKey = @"MIICeAIBADANBgkqhkiG9w0BAQEFAASCAmIwggJeAgEAAoGBAKliV5mKiM7rzIXdqNle2wuzDFqpTcxHaQa95MQ1zC+G3DVFNPjFg867AMjWW6WGbIQPVGdyPq9rCcF5L4WKId1RlIqH/ZRsj09LNgzzesO7snM36ijiBzLell4slTfOdc1G/TMFUsU5FG+a9bkdNX3RZg+SJ2CtIq+Mdl56EQOtAgMBAAECgYBJ1z9NBiGh4xWj/f+P01Q2g3WNSGVL+o2EjN/f0XwT8/ynlGYFVUWip88tvpTxUeqYn34yIpHFMyprl4Lp+k/MUCNFhScLIcRnAG0FjCxAC/m91hzyICnjVWO02C6eu7USMsI8Fgs9WVfmdAGbIHwT7GA61EbsrJ5vVKnlUz7nmQJBANL0qW1TGPNlRE1S5imtFCN4gUq348Qz3KRFvQlWFoAlfl5TG3cLlhsfo65uvGszhyHswrRvWulGjOvjgCplXesCQQDNjUfOFbyAP0W2Cs+J5jxOt3uK236vuCxaZucsbUk/p/plOot3M7WgRAtrI00IriTYebg1LM3yEWWItcKvVIbHAkEAhC4ZGw8+SwPg0DJpVSPFwpP3L0IZzQ5R6fxofjka0CCuFZwtUWJJI6WngdyQ4vreaTtYpIZBiHlUQ1nBLM9nEQJBALDY6btsRhbM2SxLVs3dEWvkPt10BSYnvbk1qZU2nXuwCSWI3i77hTtS78QIxiE+uqKo7oyJdNLcls+tGcgBYEcCQQCMVGlXiJTvKSgC7miIy8Y/if4wAHLdSjH7NP7Yqvupj1z7nSIn3z6Xd2fo7wd8bAVYQPPSr5lBjj/x2BQHTNNC";
    //partner和seller获取失败，提示
    if ([partner length] == 0 || [seller length] == 0 || [privateKey length] == 0) {
        //partner或者seller获取失败提示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"缺少partner或者seller或是私钥" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    //生成订单信息及签名
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = partner;
    order.seller = seller;
#warning 这里需要填商品信息
    order.tradeNO = @"227444277543059";//订单ID(由商家自行制定)
    order.productName = @"测试商品";//商品标题
    order.productDescription = @"Text";//商品描述
    order.amount = @"0.01";//商品价格
    order.notifyURL = @"http://www.whyixiu.com/pay/notify";//回调url  这个url是在支付后，支付宝通知后台服务器，是数据同步更新，必须填，否则支付无法成功
#warning 下面的参数是固定的，不需要改变
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showUrl = @"m.alipay.com";
#warning 应用注册scheme，在info->URL types->URL scheme处设置
    NSString *appScheme = @"thinklion";
    
    //将商品信息拼接出字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec===%@",orderSpec);
    //获取私钥匙并将商户信息签名，外部商户可以根据情况存放私钥和签名，只需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];
    NSLog(@"signedString===%@",signedString);
    
    //将签名成功字符串格式化为订单字符串，请严格按照该格式
    NSString * orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",orderSpec, signedString, @"RSA"];
    if(signedString != nil){

        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSInteger orderState=[resultDic[@"resultStatus"] integerValue];
            if (orderState == 9000) {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"支付成功" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alertVC addAction:sure];
                [self presentViewController:alertVC animated:YES completion:nil];
                return ;
            }
            
            NSString *returnStr;
            switch (orderState) {
                case 8000:
                    returnStr=@"订单正在处理中";
                    break;
                case 4000:
                    returnStr=@"订单支付失败";
                    break;
                case 6001:
                    returnStr=@"订单取消";
                    break;
                case 6002:
                    returnStr=@"网络连接出错";
                    break;
                default:
                    break;
                    
            }
            NSLog(@"------------%@",returnStr);
        }];
    }
}




@end
