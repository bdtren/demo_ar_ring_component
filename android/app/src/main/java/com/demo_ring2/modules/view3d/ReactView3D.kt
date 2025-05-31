package com.demo_ring2.modules.view3d

import android.content.Context
import android.graphics.PixelFormat
import android.opengl.GLSurfaceView
import android.util.AttributeSet
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.ProgressBar
import com.demo_ring2.modules.view3d.renderer.MyGLRenderer
import java.net.URI

class ReactView3D: LinearLayout {
    private lateinit var surface: GLSurfaceView
    private lateinit var renderer: MyGLRenderer
    private var progressBar: ProgressBar? = null
    var sourceUrl: String = ""
    var contentX: Float = 0f
    var contentY: Float = 0f
    var contentZ: Float = 0f
    var contentDeg: Float = 0f
    var contentWidth: Float = 0f
    var contentHeight: Float = 0f
    var reactWidth: Float = 0f
    var reactHeight: Float = 0f

    constructor(context: Context) : super(context) {
        configureComponent()
    }

    constructor(context: Context, attrs: AttributeSet?) : super(context, attrs) {
        configureComponent()
    }

    constructor(context: Context, attrs: AttributeSet?, defStyleAttr: Int) : super(context, attrs) {
        configureComponent()
    }

    private fun configureComponent() {
        this.layoutParams =
            ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        surface = GLSurfaceView(context)
//        surface.layoutParams = View.lay
        surface.holder.setFormat(PixelFormat.TRANSLUCENT)
        surface.setZOrderOnTop(true)

        surface.setEGLConfigChooser(8, 8, 8, 8, 16, 0)
        // Use OpenGL ES 2.0
        surface.setEGLContextClientVersion(2)
        renderer = MyGLRenderer(context)
        surface.setRenderer(renderer)
        // continuous rendering so model stays visible
        surface.renderMode = GLSurfaceView.RENDERMODE_CONTINUOUSLY

        this.addView(surface)
    }

    fun loadObj() {
        try {
            val stream = if (this.sourceUrl.lowercase().startsWith("http")) {
                val url = URI.create(this.sourceUrl).toURL()
                val name = url.path.split("/").last()
                context.assets.open("custom/$name") //auto generated from react-native-asset
            } else {
                context.assets.open(this.sourceUrl)
            }

            this.renderer.loadObj(stream) {progress ->
                progressBar?.visibility = if (progress) View.GONE else View.VISIBLE

                if (progress) {
                    updateRingPose()
                }
            }
        } catch (e: Exception) {
            Log.e("ReactView3D", "Error loading OBJ file: ${e.message}", e)
            // Handle error appropriately
        }
    }

    fun updateRingPose() {
        surface.queueEvent {
            renderer.updatePose(contentX / reactWidth, contentY / reactHeight, contentZ, contentDeg, contentWidth, contentHeight)
        }
    }
}