package com.example.gifmaker

import android.content.Intent
import android.content.Intent.EXTRA_STREAM
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.InputStream


class MainActivity: FlutterActivity() {

    var accesscode=123

    private val CHANNEL = "samples.flutter.dev/gifmaker"
    var myresult:MethodChannel.Result?=null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if(call.method.equals("StartSecondActivity")){

                checkpermiss(result)
            }
            else if(call.method.equals("toast")){

               Toast.makeText(context,"Gif successfully saved to device",Toast.LENGTH_LONG).show()
                result.success("success")
            }
            else if(call.method.equals("toastforlowvalue")){

               Toast.makeText(context,"Length should be atleast 1 second",Toast.LENGTH_LONG).show()
                result.success("success")
            }
            else{
                result.notImplemented()
            }
            // Note: this method is invoked on the main thread.
            // TODO
        }
    }





    fun checkpermiss(result:MethodChannel.Result)
    {
        myresult=result
        if(Build.VERSION.SDK_INT>=23)
        {
            if(ActivityCompat.checkSelfPermission(this,android.Manifest.permission.WRITE_EXTERNAL_STORAGE)!=PackageManager.PERMISSION_GRANTED)
            {
                requestPermissions(arrayOf(android.Manifest.permission
                        .WRITE_EXTERNAL_STORAGE),accesscode)
                return
            }
        }
        gotpermission()
    }


    //react to request permission result
    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        when(requestCode)
        {
            accesscode->
            {
                if(grantResults[0]==PackageManager.PERMISSION_GRANTED)
                {
                    gotpermission()
                }
                else
                {
                    myresult!!.success("failed")
                    Toast.makeText(this,"Please provide storage permission access to continue", Toast.LENGTH_SHORT).show()
                    return
                }
            }
        }
    }

    fun gotpermission(){
        myresult!!.success("success")
    }



}
