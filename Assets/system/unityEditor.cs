using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

//[MenuItem("系统文件/帧率调整")]
//static void SetFps()
//{ 

//}
public class SystemControlor:MonoBehaviour
{
    [ExecuteInEditMode]
    [MenuItem("SystemController/SetFps")]
    static void SetFps()
    {
        QualitySettings.vSyncCount = 1;
        Application.targetFrameRate = 30;
    }
}
