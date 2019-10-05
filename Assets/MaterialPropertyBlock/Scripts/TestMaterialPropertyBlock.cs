using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestMaterialPropertyBlock : MonoBehaviour
{
    private MaterialPropertyBlock m_mpb;

    private List<GameObject> m_CubeList = new List<GameObject>();

    private void Start()
    {
        m_mpb = new MaterialPropertyBlock();

        GameObject assetObject = Resources.Load<GameObject>("Cube");
        for (int i = 0; i < 10; i++)
        {
            GameObject go = GameObject.Instantiate<GameObject>(assetObject);
            m_CubeList.Add(go);
        }
    }

    public void OnGUI()
    {
        if (GUILayout.Button("Set MaterialPropertyBlock"))
        {
            for (int i = 0; i < 5; i++)
            {
                Renderer renderer = m_CubeList[i].GetComponent<Renderer>();
                renderer.GetPropertyBlock(m_mpb);
                m_mpb.SetColor("_Color", Color.green);
                renderer.SetPropertyBlock(m_mpb);
            }
            for (int i = 5; i < 8; i++)
            {
                Renderer renderer = m_CubeList[i].GetComponent<Renderer>();
                renderer.GetPropertyBlock(m_mpb);
                m_mpb.SetColor("_Color", Color.blue);
                renderer.SetPropertyBlock(m_mpb);
            }
        }
    }
}
