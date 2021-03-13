using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LauchBullet : MonoBehaviour
{ 
   //[SerializeField]
    public float speed = 50.0f;

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
