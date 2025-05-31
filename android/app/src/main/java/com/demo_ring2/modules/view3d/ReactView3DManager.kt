package com.demo_ring2.modules.view3d

import android.view.View
import com.demo_ring2.modules.view3d.ReactView3D
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.facebook.react.viewmanagers.View3DManagerInterface
import com.facebook.react.viewmanagers.View3DManagerDelegate

@ReactModule(name = ReactView3DManager.REACT_CLASS)
class ReactView3DManager(context: ReactApplicationContext) : SimpleViewManager<ReactView3D>(),
    View3DManagerInterface<ReactView3D> {
    private val delegate: View3DManagerDelegate<ReactView3D, ReactView3DManager> =
        View3DManagerDelegate(this)

    override fun getDelegate(): ViewManagerDelegate<ReactView3D> = delegate

    override fun getName(): String = REACT_CLASS

    override fun createViewInstance(context: ThemedReactContext): ReactView3D = ReactView3D(context)

    companion object {
        const val REACT_CLASS = "View3D"
    }

    @ReactProp(name = "source")
    override fun setSource(view: ReactView3D, value: String?) {
        if (value.isNullOrEmpty()) {
//            view.emitOnScriptLoaded(ReactView3D.OnScriptLoadedEventResult.error)
            return
        }

        view.sourceUrl = value
        view.loadObj()
    }

    @ReactProp(name = "x")
    override fun setX(view: ReactView3D, value: Float) {
        view.contentX = value
        view.updateRingPose()
    }

    @ReactProp(name = "y")
    override fun setY(view: ReactView3D, value: Float) {
        view.contentY = value
        view.updateRingPose()
    }

    @ReactProp(name = "z")
    override fun setZ(view: ReactView3D, value: Float) {
        view.contentZ = value
        view.updateRingPose()
    }

    @ReactProp(name = "angleDeg")
    override fun setAngleDeg(view: ReactView3D, value: Float) {
        view.contentDeg = value
        view.updateRingPose()
    }

    @ReactProp(name = "contentWidth")
    override fun setContentWidth(view: ReactView3D, value: Float) {
        view.contentWidth = value
        view.updateRingPose()
    }

    @ReactProp(name = "contentHeight")
    override fun setContentHeight(view: ReactView3D, value: Float) {
        view.contentHeight = value
        view.updateRingPose()
    }

    @ReactProp(name = "reactWidth")
    override fun setReactWidth(view: ReactView3D, value: Float) {
        view.reactWidth = value
        view.updateRingPose()
    }

    @ReactProp(name = "reactHeight")
    override fun setReactHeight(view: ReactView3D, value: Float) {
        view.reactHeight = value
        view.updateRingPose()
    }

//    @ReactProp(name = "sourceUrl")
//    override fun setSourceURL(view: ReactView3D, sourceURL: String?) {
//        if (sourceURL == null) {
//            view.emitOnScriptLoaded(ReactView3D.OnScriptLoadedEventResult.error)
//            return;
//        }
//        view.loadUrl(sourceURL, emptyMap())
//    }
//
//    override fun getExportedCustomBubblingEventTypeConstants(): Map<String, Any> =
//        mapOf(
//            "onScriptLoaded" to
//                    mapOf(
//                        "phasedRegistrationNames" to
//                                mapOf(
//                                    "bubbled" to "onScriptLoaded",
//                                    "captured" to "onScriptLoadedCapture"
//                                )))
}

