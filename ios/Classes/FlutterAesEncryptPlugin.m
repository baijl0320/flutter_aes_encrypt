#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "FlutterAesEncryptPlugin.h"

@implementation FlutterAesEncryptPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_aes_encrypt"
            binaryMessenger:[registrar messenger]];
  FlutterAesEncryptPlugin* instance = [[FlutterAesEncryptPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    NSString *method = [call method];
    NSDictionary *arguments = [call arguments];
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else if ([method isEqualToString:@"aesEncrypt"]) { // 加密
        id input = arguments[@"input"];
        id key = arguments[@"key"];
        if ([input isKindOfClass:[NSString class]] && [input length] && [key isKindOfClass:[NSString class]] && [key length]) {
            NSString *strInput = (NSString *)input;
            NSString *strKey = (NSString *)key;

            char keyPtr[kCCKeySizeAES128+1];
            memset(keyPtr, 0, sizeof(keyPtr));
            [strKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

            NSMutableData* data = [strInput dataUsingEncoding:NSUTF8StringEncoding];
            NSUInteger dataLength = [data length];
            int offset = 16 - dataLength % 16;
            char byte = '0';
            for (int i = 0; i < offset; i++) {
                [data appendBytes:&byte length:1];
            }
            dataLength += offset;
            size_t bufferSize = dataLength + kCCBlockSizeAES128;
            void *buffer = malloc(bufferSize);
            size_t numBytesEncrypted = 0;
            CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                                  kCCAlgorithmAES128,
                                                  0x0000|kCCOptionECBMode,
                                                  keyPtr,
                                                  kCCBlockSizeAES128,
                                                  NULL,
                                                  [data bytes],
                                                  dataLength,
                                                  buffer,
                                                  bufferSize,
                                                  &numBytesEncrypted);
            if (cryptStatus == kCCSuccess) {
                NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
                NSString *normalString = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                NSString *base64String = [resultData base64EncodedStringWithOptions:0];
                result(base64String);
            } else {
                result(nil);
            }
        } else {
            result(nil);
        }
    } else if ([method isEqualToString:@"aesDecrypt"]) { // 解密
        id input = arguments[@"input"];
        id key = arguments[@"key"];
        if ([input isKindOfClass:[NSString class]] && [input length] && [key isKindOfClass:[NSString class]] && [key length]) {
            NSString *strInput = (NSString *)input;
            NSString *strKey = (NSString *)key;

            char keyPtr[kCCKeySizeAES128 + 1];
            memset(keyPtr, 0, sizeof(keyPtr));
            [strKey getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

            NSData *data = [[NSData alloc] initWithBase64EncodedString:strInput options:0];
            NSUInteger dataLength = [data length];
            size_t bufferSize = dataLength + kCCBlockSizeAES128;
            void *buffer = malloc(bufferSize);

            size_t numBytesCrypted = 0;
            CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                                  kCCAlgorithmAES128,
                                                  0x0000|kCCOptionECBMode,
                                                  keyPtr,
                                                  kCCBlockSizeAES128,
                                                  NULL,
                                                  [data bytes],
                                                  dataLength,
                                                  buffer,
                                                  bufferSize,
                                                  &numBytesCrypted);
            if (cryptStatus == kCCSuccess) {
                NSData *resultData = [NSData dataWithBytesNoCopy:buffer length:numBytesCrypted];
                NSString *str = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
                result([[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding]);
            } else {
                result(nil);
            }
        } else {
            result(nil);
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
