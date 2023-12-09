/*
 
    proxyctl
 
    WiFiKit.tbd from:
    https://github.com/theos/sdks/blob/146e41ff2c292168388929e43c9b4de2f00e36b3/iPhoneOS16.5.sdk/System/Library/PrivateFrameworks/WiFiKit.framework/WiFiKit.tbd

 */

// #define DEBUG 1

#ifdef DEBUG
    #define DLog(fmt, ...) NSLog(fmt, ##__VA_ARGS__);
#else
    #define DLog(...)
#endif

#import <Foundation/Foundation.h>
#import "WiFiKit-types.h"

NSString *getSSID() {
    WFClient *client = [WFClient sharedInstance];
    DLog(@"WFClient: %@", client);
    
    WFInterface *interface = [client interface];
    DLog(@"WFInterface: %@", interface);
    
    __block WFNetworkScanRecord *curNetScanRec = [interface currentNetwork];
    DLog(@"WFInterface.currentNetwork: %@", curNetScanRec);
    if (curNetScanRec == nil) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [interface asyncCurrentNetwork:^(WFNetworkScanRecord *netScanRec) {
            DLog(@"WFNetworkScanRecord: %@", netScanRec);
            curNetScanRec = netScanRec;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }
    return [curNetScanRec ssid];
}

WFSettingsProxy *getProxySettings(NSArray *settings) {
    for (id settingsObj in settings) {
        if ([settingsObj isKindOfClass:[WFSettingsProxy class]]) {
            return settingsObj;
        }
    }
    return nil;
}

NSArray *getSettings(NSOperationQueue *queue, NSString *SSID) {
    WFGetSettingsOperation *op = [[WFGetSettingsOperation alloc] initWithSSID:SSID];
    DLog(@"WFGetSettingsOperation: %@", op);
    [queue addOperation:op];
    [queue waitUntilAllOperationsAreFinished];
    DLog(@"WFGetSettingsOperation.settings: %@", [op settings]);
    return [op settings];
}

NSArray *saveSettings(NSOperationQueue *queue, NSString *SSID, NSArray *settings) {
    WFSaveSettingsOperation *op = [[WFSaveSettingsOperation alloc] initWithSSID:SSID settings:settings];
    DLog(@"WFSaveSettingsOperation: %@", op);
    [queue addOperation:op];
    [queue waitUntilAllOperationsAreFinished];
    DLog(@"WFSaveSettingsOperation.settings: %@", [op settings]);
    return [op settings];
}

int main(int argc, char const *argv[]) {
    NSString *SSID = getSSID();
    if (SSID == nil) {
        NSLog(@"Couldn't resolve SSID");
        return -1;
    }
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    getSettings(queue, SSID);
    
    WFSettingsProxy *proxySettings;
    if (argc > 2) {
        NSString *host = [NSString stringWithCString:argv[1] encoding:NSUTF8StringEncoding];
        NSString *port = [NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding];
        proxySettings = [[WFSettingsProxy alloc] initWithManualServer:host port:port username:nil password:nil];
    } else {
        proxySettings = [WFSettingsProxy offConfig];
    }
    DLog(@"WFSettingsProxy: %@", proxySettings);
    
    saveSettings(queue, SSID, @[proxySettings]);
    
    NSArray *updSettings = getSettings(queue, SSID);
    NSLog(@"Settings for SSID \"%@\":\n\t%@", SSID, getProxySettings(updSettings));
    
    WFSettingsProxy *prxoySettings = getProxySettings(updSettings);
    if ([prxoySettings customProxy]) {
        NSLog(@"Proxy enabled");
    } else {
        NSLog(@"Proxy disabled");
    }
    
    return 0;
}
