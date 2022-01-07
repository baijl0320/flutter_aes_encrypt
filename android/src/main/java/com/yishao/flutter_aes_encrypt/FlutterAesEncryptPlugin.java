package com.yishao.flutter_aes_encrypt;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** FlutterAesEncryptPlugin */
public class FlutterAesEncryptPlugin implements FlutterPlugin, MethodCallHandler {
  private MethodChannel channel;

  private static final String CHARSET = "utf-8";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "flutter_aes_encrypt");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("aesEncrypt")) {
      encrypt(call, result);
    } else if (call.method.equals("aesDecrypt")) {
      decrypt(call, result);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  // 加密
  @RequiresApi(api = Build.VERSION_CODES.O)
  public void encrypt(@NonNull MethodCall call, @NonNull Result result) {
    try {
      String input = call.argument("input");
      String key = call.argument("key");
      byte[] data = input.getBytes(CHARSET);
      int length = data.length;
      int offsize = 16 - length % 16;
      ByteBuffer byteBuffer = ByteBuffer.allocate(length + offsize);
      byteBuffer.put(data);
      for (int i = 0; i < offsize; i++) {
        byte padding = 0;
        byteBuffer.put(padding);
      }
      byte[] tmpData = byteBuffer.array();
      @SuppressLint("GetInstance")
      Cipher cipher = Cipher.getInstance("AES/ECB/NoPadding");
      SecretKeySpec keyspec = new SecretKeySpec(key.getBytes(CHARSET), "AES");
      cipher.init(Cipher.ENCRYPT_MODE, keyspec);
      byte[] encryptArray = cipher.doFinal(tmpData);
      String encryptResult = Base64.getEncoder().encodeToString(encryptArray);
      result.success(encryptResult);
    } catch (Exception e) {
      e.printStackTrace();
      result.success(null);
    }
  }

  // 解密
  @RequiresApi(api = Build.VERSION_CODES.O)
  public void decrypt(@NonNull MethodCall call, @NonNull Result result) {
    try {
      String input = call.argument("input");
      String key = call.argument("key");
      byte[] encryptedData = Base64.getDecoder().decode(input);

      SecretKeySpec skeySpec = new SecretKeySpec(key.getBytes(CHARSET), "AES");
      @SuppressLint("GetInstance")
      Cipher cipher = Cipher.getInstance("AES/ECB/NoPadding");
      cipher.init(Cipher.DECRYPT_MODE, skeySpec);
      byte[] decryptArray = cipher.doFinal(encryptedData);
      String decryptResult = new String(decryptArray);
      result.success(decryptResult);
    } catch (Exception e) {
      e.printStackTrace();
      result.success(null);
    }
  }
}
