using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LauchBullet : MonoBehaviour
{ 
   //[SerializeField]
    public float speed = 50.0f;
    // 用该 对象与 player 的距离来实现销毁？
    public Transform LauchPosition;
    public GameObject LauchObjct;
    private void Start()
    {
        this.gameObject.transform.Find("bullet").GetComponent<Rigidbody2D>().velocity = transform.right * speed * Time.deltaTime;
    }
    private void Update()
    {
        Instantiate(LauchObjct, LauchPosition.position, LauchPosition.rotation);
    }








}
