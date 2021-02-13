using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
public class PlayerBehavior : MonoBehaviour
{
    readonly Vector3 flippedScale = new Vector3(-1, 1, 1);

    [Header("Character")]
    [SerializeField] Animator animator = null;
    [SerializeField] Transform puppet = null;

    [Header("Movement")]
    [SerializeField] float acceleration = 0.0f;
    [SerializeField] float maxSpeed = 0.0f;
    [SerializeField] float jumpForce = 0.0f;
    [SerializeField] float minFlipSpeed = 0.1f;
    [SerializeField] float jumpGravityScale = 1.0f;
    [SerializeField] float fallGravityScale = 1.0f;
    [SerializeField] float groundedGravityScale = 1.0f;
    [SerializeField] bool resetSpeedOnLand = false;


    private Rigidbody2D controllerRigidbody;
    private Collider2D controllerCollider;


    private Vector2 movementInput;
    private bool jumpInput;

    private Vector2 prevVelocity;


    private bool isJumping;
    private bool isFalling;

    private bool attack01Input;
    private bool isAttack01ing;
    

    private int animatorRunningSpeed;
    private int animatorJumpTrigger;
    //用不上
    private int  animatorAttack01Trigger;

    public bool CanMove { get; set; }


    private void Start()
    {
        controllerRigidbody = GetComponent<Rigidbody2D>();
        controllerCollider = GetComponent<Collider2D>();

        animatorRunningSpeed = Animator.StringToHash("idle2walk");
        animatorJumpTrigger = Animator.StringToHash("Jump");
        animatorAttack01Trigger = Animator.StringToHash("attack01");
        CanMove = true;
    }

    private void Update()
    {
        var keyboard = Keyboard.current;

        if (!CanMove || keyboard == null)
            return;

        // Horizontal movement
        float moveHorizontal = 0.0f;

        if (keyboard.aKey.isPressed)
            moveHorizontal = -1.0f;
        else if (keyboard.dKey.isPressed)
        {
            
            moveHorizontal = 1.0f;;
        }
        //else if (keyboard.dKey.wasReleasedThisFrame)
        //{
        //    moveHorizontal = 0.0f;
            
        //}
        //else if (keyboard.aKey.wasReleasedThisFrame)
        //{
        //    moveHorizontal = 0.0f;

        //}
        movementInput = new Vector2(moveHorizontal, 0);

        // Jumping input
        if (!isJumping && keyboard.spaceKey.wasPressedThisFrame)
            jumpInput = true;

        if (!isAttack01ing && keyboard.jKey.wasPressedThisFrame)
            attack01Input = true;

    }

    private void FixedUpdate()
    {
        UpdateVelocity();
        UpdateDirection();
        UpdateAttack();
    }


    private void UpdateVelocity()
    {

        Vector2 velocity = controllerRigidbody.velocity;

        // Apply acceleration directly as we'll want to clamp
        // prior to assigning back to the body.
        velocity += movementInput * acceleration * Time.fixedDeltaTime;

        // We've consumed the movement, reset it.
        movementInput = Vector2.zero;

        // Clamp horizontal speed.
        velocity.x = Mathf.Clamp(velocity.x, -maxSpeed, maxSpeed);
        // Assign back to the body.
        controllerRigidbody.velocity = velocity;

        // Update animator running speed
        var horizontalSpeedNormalized = Mathf.Abs(velocity.x) / maxSpeed;
        animator.SetFloat(animatorRunningSpeed, horizontalSpeedNormalized);
    }

    private void UpdateDirection()
    {
        // Use scale to flip character depending on direction
        if (controllerRigidbody.velocity.x > minFlipSpeed)
        {
            puppet.localScale = Vector3.one;
        }
        else if (controllerRigidbody.velocity.x < -minFlipSpeed)
        {
            puppet.localScale = flippedScale;
        }
    }
    // 肯能有多个 的攻击
    private void UpdateAttack()
    {
        if (attack01Input && !isAttack01ing)
        {
            animator.SetTrigger(animatorAttack01Trigger);
            isAttack01ing = true;
            attack01Input = false;
        }
        else if(isAttack01ing)
        {
            isAttack01ing = false;

        }
    }



}
