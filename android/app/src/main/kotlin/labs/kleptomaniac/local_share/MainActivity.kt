package labs.kleptomaniac.local_share

import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.OpenableColumns
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    private val channelName="app.channel.share"
    private val TAG="ANYDROP_ANDROID"
    private var sharedData:MutableMap<String,ByteArray> = mutableMapOf()

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleSendIntent(intent)
    }

    @SuppressLint("NewApi")
    @TargetApi(Build.VERSION_CODES.HONEYCOMB)
    private fun handleSendIntent(intent:Intent){
        val action = intent.action
        val type = intent.type
        Log.d(TAG,"Received Intent for $action,$type")
        if(Intent.ACTION_SEND == action){
           val sharedItemCount  = intent.clipData?.itemCount?:0
            for (i in 0 until sharedItemCount){
                val uri = intent.clipData?.getItemAt(i)?.uri
                uri?.let {
                    val inputStream = contentResolver.openInputStream(it)
                    inputStream?.let {stream->
                        val fileName = getFilename(it)
                        sharedData[fileName] = stream.readBytes()
                    }

                }

            }
        }

    }

    private fun getFilename(uri: Uri): String {
        contentResolver.query(uri,
                null,null,null,null)?.use {
            cursor ->
            val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
            cursor.moveToFirst()
            return cursor.getString(nameIndex)
        }
        return ""
    }
}
