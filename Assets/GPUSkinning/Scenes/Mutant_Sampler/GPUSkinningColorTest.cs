using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GPUSkinningColorTest : MonoBehaviour
{
    public GPUSkinningPlayerMono BluePlayerMono;

    public GPUSkinningPlayerMono RedPlayerMono;

    private void OnGUI()
    {
        if (GUILayout.Button("设置GPUSkinning"))
        {
            // 设置蓝色
            BluePlayerMono.Player.SetColorData(new Vector3(0.36f, 1.09f, 1.69f));
            // 设置红色
            RedPlayerMono.Player.SetColorData(new Vector3(1.69f, 0.36f, 0.38f));
        }
    }
}
