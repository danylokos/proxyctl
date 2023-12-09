
/* 

    Headers:
    https://github.com/nst/iOS-Runtime-Headers/tree/fbb634c78269b0169efdead80955ba64eaaa2f21/PrivateFrameworks/WiFiKit.framework

*/


@interface WFNetworkScanRecord : NSObject
@property (nonatomic, copy) NSString *ssid;
@end

@interface WFInterface : NSObject
@property (nonatomic,retain) WFNetworkScanRecord *currentNetwork; 

- (void)asyncCurrentNetwork:(void (^)(WFNetworkScanRecord *))handler;
@end

@interface WFClient : NSObject
@property (nonatomic, retain) WFInterface *interface;

+ (instancetype)sharedInstance;
@end

@interface WFSettingsProxy : NSObject
@property (nonatomic) BOOL customProxy;
@property (nonatomic, retain) NSDictionary *items;
@property (nonatomic, copy) NSString *server;
@property (nonatomic, copy) NSString *port;
@property (nonatomic) BOOL authenticated;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;

+ (instancetype)offConfig;
- (instancetype)initWithManualServer:(NSString *)server port:(NSString *)port username:(NSString *)username password:(NSString *)password;
@end

@interface WFOperation : NSOperation
@end

@interface WFGetSettingsOperation : WFOperation
@property (nonatomic, retain) NSArray *settings;
@property (nonatomic, copy) NSString *ssid;

- (instancetype)initWithSSID:(NSString *)SSID;
@end

@interface WFSaveSettingsOperation : WFOperation
@property (nonatomic, retain) NSArray *settings;
@property (nonatomic, copy) NSString *ssid;

- (instancetype)initWithSSID:(NSString *)SSID settings:(NSArray *)settings;
@end