// GENERATED AUTOMATICALLY FROM 'Assets/Contra/InputAssets/PlayerInputAsset.inputactions'

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Utilities;

public class @PlayerInputAsset : IInputActionCollection, IDisposable
{
    public InputActionAsset asset { get; }
    public @PlayerInputAsset()
    {
        asset = InputActionAsset.FromJson(@"{
    ""name"": ""PlayerInputAsset"",
    ""maps"": [
        {
            ""name"": ""PlayerControl"",
            ""id"": ""7b413ea7-1641-4a87-9406-8f485977112e"",
            ""actions"": [
                {
                    ""name"": ""Movement"",
                    ""type"": ""Value"",
                    ""id"": ""0c3be794-02f3-4278-8498-9f874a7071a0"",
                    ""expectedControlType"": ""Vector2"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Fire0"",
                    ""type"": ""Button"",
                    ""id"": ""1173bfd9-24eb-4a31-bf4f-e4752202b416"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Jump"",
                    ""type"": ""Button"",
                    ""id"": ""f3e2e57f-6cb2-4828-9b89-fffcbc1f801d"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Look"",
                    ""type"": ""PassThrough"",
                    ""id"": ""50e6c99f-a3b3-48a9-a4c4-a05dbd3c4bcf"",
                    ""expectedControlType"": ""Vector2"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Touch0"",
                    ""type"": ""PassThrough"",
                    ""id"": ""cf678d44-f48e-4e22-b526-8c6505905b92"",
                    ""expectedControlType"": """",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Touch0Position"",
                    ""type"": ""PassThrough"",
                    ""id"": ""9bdb0289-3d02-4088-ae84-2e175ebedcc6"",
                    ""expectedControlType"": """",
                    ""processors"": """",
                    ""interactions"": """"
                }
            ],
            ""bindings"": [
                {
                    ""name"": ""wasd"",
                    ""id"": ""ebf33ee9-ada3-433d-b3db-4596b18100f1"",
                    ""path"": ""2DVector"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": true,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""up"",
                    ""id"": ""823f5525-e94b-40ad-9f4e-cac43cd186c0"",
                    ""path"": ""<Keyboard>/w"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""down"",
                    ""id"": ""42ce4d58-8320-4279-9418-f64ca15d73b8"",
                    ""path"": ""<Keyboard>/s"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""left"",
                    ""id"": ""7f8db34e-8a0d-4c8c-8eb9-f5b43ae9e2ef"",
                    ""path"": ""<Keyboard>/a"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""right"",
                    ""id"": ""ec79f758-4b89-4615-9db8-e05da0586294"",
                    ""path"": ""<Keyboard>/d"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""arrows"",
                    ""id"": ""9420fe16-bf82-4d9e-8eb8-e75e4161941b"",
                    ""path"": ""2DVector"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": true,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""up"",
                    ""id"": ""3c74d9b0-445d-4659-898d-9343a65e8398"",
                    ""path"": ""<Keyboard>/upArrow"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""down"",
                    ""id"": ""b92f0b20-a73f-4bde-9c9b-a709ac990c70"",
                    ""path"": ""<Keyboard>/downArrow"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""left"",
                    ""id"": ""8ce28dda-c4a8-4ee5-9252-ec2b2581239a"",
                    ""path"": ""<Keyboard>/leftArrow"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""right"",
                    ""id"": ""7260d748-2698-41e1-afb2-378f280ab184"",
                    ""path"": ""<Keyboard>/rightArrow"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": """",
                    ""id"": ""4b348e82-8e2d-49b1-9e72-558b71d30889"",
                    ""path"": ""<Gamepad>/leftStick"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Movement"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""543732af-53bc-455d-b13b-f4e8c521f58b"",
                    ""path"": ""<Mouse>/leftButton"",
                    ""interactions"": ""SlowTap,Tap"",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Fire0"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""e644a8e2-8f91-47bd-9e00-55a4d86052a6"",
                    ""path"": ""<Keyboard>/space"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Jump"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""002d7498-94ab-4d93-b288-9c8e26df725b"",
                    ""path"": ""<Mouse>/delta"",
                    ""interactions"": """",
                    ""processors"": ""ScaleVector2(x=0.1,y=0.1)"",
                    ""groups"": """",
                    ""action"": ""Look"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""139463fb-be5a-4494-a047-33e540cb6dc3"",
                    ""path"": ""<Gamepad>/rightStick"",
                    ""interactions"": """",
                    ""processors"": ""NormalizeVector2"",
                    ""groups"": """",
                    ""action"": ""Look"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""8aab4559-3845-4249-a524-b00fda1882ed"",
                    ""path"": ""<Mouse>/leftButton"",
                    ""interactions"": ""Tap"",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Touch0"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""035fb33c-fe98-4dd1-b58a-116ad1e6ae15"",
                    ""path"": ""<Mouse>/position"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Touch0Position"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""52e290eb-fe13-47b9-bacc-6657abfdca61"",
                    ""path"": ""<Touchscreen>/position"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Touch0Position"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                }
            ]
        },
        {
            ""name"": ""PlayerUI"",
            ""id"": ""9eaced39-1fd4-4f3e-aabb-cf5cf2dbdef6"",
            ""actions"": [
                {
                    ""name"": ""Navigate"",
                    ""type"": ""Value"",
                    ""id"": ""7b90cee5-5da0-4fba-b32f-2f5fe346eb9d"",
                    ""expectedControlType"": ""Vector2"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Submit"",
                    ""type"": ""Button"",
                    ""id"": ""8b1d619d-adb4-469e-a249-e9484b48e4f9"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Cancel"",
                    ""type"": ""Button"",
                    ""id"": ""2affa64e-ca74-4d50-a73c-e9a06ae1b2e7"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Point"",
                    ""type"": ""PassThrough"",
                    ""id"": ""b05ba56f-5016-4579-891c-307a4eeadbe7"",
                    ""expectedControlType"": ""Vector2"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""Click"",
                    ""type"": ""PassThrough"",
                    ""id"": ""f5b15d15-d8e2-43bd-b990-30817c719371"",
                    ""expectedControlType"": ""Button"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""ScrollWheel"",
                    ""type"": ""PassThrough"",
                    ""id"": ""a38cde6c-9a1d-4f1e-947b-746b645b631e"",
                    ""expectedControlType"": ""Vector2"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""MiddleClick"",
                    ""type"": ""PassThrough"",
                    ""id"": ""2ba1b952-646f-4532-a35e-a0bc125c2fd9"",
                    ""expectedControlType"": """",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""RightClick"",
                    ""type"": ""PassThrough"",
                    ""id"": ""7cd05471-da31-4320-96c7-e35ae08a8228"",
                    ""expectedControlType"": """",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""TrackedDevicePosition"",
                    ""type"": ""PassThrough"",
                    ""id"": ""9a902ab1-4f9d-46b3-88d6-807e0db631d5"",
                    ""expectedControlType"": ""Vector3"",
                    ""processors"": """",
                    ""interactions"": """"
                },
                {
                    ""name"": ""TrackedDeviceOrientation"",
                    ""type"": ""PassThrough"",
                    ""id"": ""f23fd583-5716-4aa8-aede-bd1bebfe2100"",
                    ""expectedControlType"": ""Quaternion"",
                    ""processors"": """",
                    ""interactions"": """"
                }
            ],
            ""bindings"": [
                {
                    ""name"": ""Gamepad"",
                    ""id"": ""2f54ceae-a603-48c2-8d91-685fcff8228f"",
                    ""path"": ""2DVector"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Navigate"",
                    ""isComposite"": true,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""up"",
                    ""id"": ""b7989810-fa72-4ebc-a47b-36c3eb77bbf1"",
                    ""path"": ""<Gamepad>/leftStick/up"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": "";Gamepad"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""up"",
                    ""id"": ""65a8aabb-05ff-4631-a64b-6f161d92e3a8"",
                    ""path"": ""<Gamepad>/rightStick/up"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": "";Gamepad"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""down"",
                    ""id"": ""a88ddd5f-68c7-4698-815a-57c4f16be6a4"",
                    ""path"": ""<Gamepad>/leftStick/down"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": "";Gamepad"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""down"",
                    ""id"": ""de196675-bf00-41b3-b479-a4503632dc6c"",
                    ""path"": ""<Gamepad>/rightStick/down"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": "";Gamepad"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""left"",
                    ""id"": ""1f0a41fe-3e94-4e52-af04-8c39ff11d14c"",
                    ""path"": ""<Gamepad>/leftStick/left"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": "";Gamepad"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""left"",
                    ""id"": ""c72b0f7e-a5fd-4642-af3d-4ed86ffccccc"",
                    ""path"": ""<Gamepad>/rightStick/left"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": "";Gamepad"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""right"",
                    ""id"": ""8394cfe9-7e5f-464a-8927-e08c9b044218"",
                    ""path"": ""<Gamepad>/leftStick/right"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": "";Gamepad"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""right"",
                    ""id"": ""477b5b0e-4e0a-4867-9859-d5c60d34dd9c"",
                    ""path"": ""<Gamepad>/rightStick/right"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": "";Gamepad"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": """",
                    ""id"": ""e1aafa56-d3cc-4063-940a-f136e6ba96a3"",
                    ""path"": ""<Gamepad>/dpad"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": "";Gamepad"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""Joystick"",
                    ""id"": ""57b4bc1b-26f6-4bae-8ae4-40e9a5bef1c5"",
                    ""path"": ""2DVector"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Navigate"",
                    ""isComposite"": true,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""up"",
                    ""id"": ""3ccedbca-0686-4e52-8a1a-2b0e773b16c2"",
                    ""path"": ""<Joystick>/stick/up"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Joystick"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""down"",
                    ""id"": ""b6341d86-cff0-4917-95de-ec18ad33175f"",
                    ""path"": ""<Joystick>/stick/down"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Joystick"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""left"",
                    ""id"": ""27d120f2-d338-4d18-ad3d-37119192a733"",
                    ""path"": ""<Joystick>/stick/left"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Joystick"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""right"",
                    ""id"": ""7f691439-0cfc-4aff-8218-10daba6ea789"",
                    ""path"": ""<Joystick>/stick/right"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Joystick"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""Keyboard"",
                    ""id"": ""74dc2497-5faf-4785-954f-235371a9397d"",
                    ""path"": ""2DVector"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Navigate"",
                    ""isComposite"": true,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": ""up"",
                    ""id"": ""012e48b6-95d1-419c-b2a6-ced245be4b59"",
                    ""path"": ""<Keyboard>/w"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Keyboard&Mouse"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""up"",
                    ""id"": ""bd672e1d-b20a-43be-8f1c-87972f08ee5a"",
                    ""path"": ""<Keyboard>/upArrow"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Keyboard&Mouse"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""down"",
                    ""id"": ""51e1e051-73d1-4117-9d00-c2987bda5cf9"",
                    ""path"": ""<Keyboard>/s"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Keyboard&Mouse"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""down"",
                    ""id"": ""f100eeaf-bfa5-4772-b058-b5da0b462dd0"",
                    ""path"": ""<Keyboard>/downArrow"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Keyboard&Mouse"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""left"",
                    ""id"": ""7359e0e0-6330-4f3c-b8a7-c5d042fe65b3"",
                    ""path"": ""<Keyboard>/a"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Keyboard&Mouse"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""left"",
                    ""id"": ""eee8a264-43b8-43dd-a219-6d6c318d46ab"",
                    ""path"": ""<Keyboard>/leftArrow"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Keyboard&Mouse"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""right"",
                    ""id"": ""ec929ab9-ee7b-4f6e-b54b-24098ed87fc9"",
                    ""path"": ""<Keyboard>/d"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Keyboard&Mouse"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": ""right"",
                    ""id"": ""1386ba61-b4f8-41c2-a20c-3b970b7f1d4c"",
                    ""path"": ""<Keyboard>/rightArrow"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Keyboard&Mouse"",
                    ""action"": ""Navigate"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": true
                },
                {
                    ""name"": """",
                    ""id"": ""15dd93b5-9d7e-4b70-8352-5d97ee8320e0"",
                    ""path"": ""*/{Submit}"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Submit"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""4067db0c-e245-4e69-91a8-53948fdf6b3b"",
                    ""path"": ""*/{Cancel}"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": """",
                    ""action"": ""Cancel"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""c8955e54-5c9b-450c-8088-d1aa9482bac5"",
                    ""path"": ""<Mouse>/position"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Keyboard&Mouse"",
                    ""action"": ""Point"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""290420f4-ba69-46c2-818a-c25b4ea8514f"",
                    ""path"": ""<Pen>/position"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Keyboard&Mouse"",
                    ""action"": ""Point"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""871eb431-d005-438a-a640-87cbff522758"",
                    ""path"": ""<Touchscreen>/touch*/position"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Touch"",
                    ""action"": ""Point"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""da30a571-a9f0-455e-98bf-8bec11590705"",
                    ""path"": ""<Mouse>/rightButton"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": "";Keyboard&Mouse"",
                    ""action"": ""Click"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""6734dc0b-4de3-4644-bdf4-0918d3a1100f"",
                    ""path"": ""<Pen>/tip"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": "";Keyboard&Mouse"",
                    ""action"": ""Click"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""121e9337-a467-436d-a6e4-9df441c8731b"",
                    ""path"": ""<Touchscreen>/touch*/press"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""Touch"",
                    ""action"": ""Click"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""4fd2b5fe-9882-4eb3-92f3-dd424cedd0fd"",
                    ""path"": ""<XRController>/trigger"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""XR"",
                    ""action"": ""Click"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""3ed2d9f9-8e3f-4ab4-97cb-8efdf6dcbe8d"",
                    ""path"": ""<Mouse>/scroll"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": "";Keyboard&Mouse"",
                    ""action"": ""ScrollWheel"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""5273b645-7b13-40eb-ac18-ca91d297ced7"",
                    ""path"": ""<Mouse>/middleButton"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": "";Keyboard&Mouse"",
                    ""action"": ""MiddleClick"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""1c8816d5-f57a-40f9-81c3-aca37a58ac11"",
                    ""path"": ""<Mouse>/rightButton"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": "";Keyboard&Mouse"",
                    ""action"": ""RightClick"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""8ff8a895-bcd3-4784-b3a3-da90d0fa1efd"",
                    ""path"": ""<XRController>/devicePosition"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""XR"",
                    ""action"": ""TrackedDevicePosition"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                },
                {
                    ""name"": """",
                    ""id"": ""e2e8a8cc-a5a9-4438-8edc-5fc8192b3e39"",
                    ""path"": ""<XRController>/deviceRotation"",
                    ""interactions"": """",
                    ""processors"": """",
                    ""groups"": ""XR"",
                    ""action"": ""TrackedDeviceOrientation"",
                    ""isComposite"": false,
                    ""isPartOfComposite"": false
                }
            ]
        }
    ],
    ""controlSchemes"": []
}");
        // PlayerControl
        m_PlayerControl = asset.FindActionMap("PlayerControl", throwIfNotFound: true);
        m_PlayerControl_Movement = m_PlayerControl.FindAction("Movement", throwIfNotFound: true);
        m_PlayerControl_Fire0 = m_PlayerControl.FindAction("Fire0", throwIfNotFound: true);
        m_PlayerControl_Jump = m_PlayerControl.FindAction("Jump", throwIfNotFound: true);
        m_PlayerControl_Look = m_PlayerControl.FindAction("Look", throwIfNotFound: true);
        m_PlayerControl_Touch0 = m_PlayerControl.FindAction("Touch0", throwIfNotFound: true);
        m_PlayerControl_Touch0Position = m_PlayerControl.FindAction("Touch0Position", throwIfNotFound: true);
        // PlayerUI
        m_PlayerUI = asset.FindActionMap("PlayerUI", throwIfNotFound: true);
        m_PlayerUI_Navigate = m_PlayerUI.FindAction("Navigate", throwIfNotFound: true);
        m_PlayerUI_Submit = m_PlayerUI.FindAction("Submit", throwIfNotFound: true);
        m_PlayerUI_Cancel = m_PlayerUI.FindAction("Cancel", throwIfNotFound: true);
        m_PlayerUI_Point = m_PlayerUI.FindAction("Point", throwIfNotFound: true);
        m_PlayerUI_Click = m_PlayerUI.FindAction("Click", throwIfNotFound: true);
        m_PlayerUI_ScrollWheel = m_PlayerUI.FindAction("ScrollWheel", throwIfNotFound: true);
        m_PlayerUI_MiddleClick = m_PlayerUI.FindAction("MiddleClick", throwIfNotFound: true);
        m_PlayerUI_RightClick = m_PlayerUI.FindAction("RightClick", throwIfNotFound: true);
        m_PlayerUI_TrackedDevicePosition = m_PlayerUI.FindAction("TrackedDevicePosition", throwIfNotFound: true);
        m_PlayerUI_TrackedDeviceOrientation = m_PlayerUI.FindAction("TrackedDeviceOrientation", throwIfNotFound: true);
    }

    public void Dispose()
    {
        UnityEngine.Object.Destroy(asset);
    }

    public InputBinding? bindingMask
    {
        get => asset.bindingMask;
        set => asset.bindingMask = value;
    }

    public ReadOnlyArray<InputDevice>? devices
    {
        get => asset.devices;
        set => asset.devices = value;
    }

    public ReadOnlyArray<InputControlScheme> controlSchemes => asset.controlSchemes;

    public bool Contains(InputAction action)
    {
        return asset.Contains(action);
    }

    public IEnumerator<InputAction> GetEnumerator()
    {
        return asset.GetEnumerator();
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return GetEnumerator();
    }

    public void Enable()
    {
        asset.Enable();
    }

    public void Disable()
    {
        asset.Disable();
    }

    // PlayerControl
    private readonly InputActionMap m_PlayerControl;
    private IPlayerControlActions m_PlayerControlActionsCallbackInterface;
    private readonly InputAction m_PlayerControl_Movement;
    private readonly InputAction m_PlayerControl_Fire0;
    private readonly InputAction m_PlayerControl_Jump;
    private readonly InputAction m_PlayerControl_Look;
    private readonly InputAction m_PlayerControl_Touch0;
    private readonly InputAction m_PlayerControl_Touch0Position;
    public struct PlayerControlActions
    {
        private @PlayerInputAsset m_Wrapper;
        public PlayerControlActions(@PlayerInputAsset wrapper) { m_Wrapper = wrapper; }
        public InputAction @Movement => m_Wrapper.m_PlayerControl_Movement;
        public InputAction @Fire0 => m_Wrapper.m_PlayerControl_Fire0;
        public InputAction @Jump => m_Wrapper.m_PlayerControl_Jump;
        public InputAction @Look => m_Wrapper.m_PlayerControl_Look;
        public InputAction @Touch0 => m_Wrapper.m_PlayerControl_Touch0;
        public InputAction @Touch0Position => m_Wrapper.m_PlayerControl_Touch0Position;
        public InputActionMap Get() { return m_Wrapper.m_PlayerControl; }
        public void Enable() { Get().Enable(); }
        public void Disable() { Get().Disable(); }
        public bool enabled => Get().enabled;
        public static implicit operator InputActionMap(PlayerControlActions set) { return set.Get(); }
        public void SetCallbacks(IPlayerControlActions instance)
        {
            if (m_Wrapper.m_PlayerControlActionsCallbackInterface != null)
            {
                @Movement.started -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnMovement;
                @Movement.performed -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnMovement;
                @Movement.canceled -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnMovement;
                @Fire0.started -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnFire0;
                @Fire0.performed -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnFire0;
                @Fire0.canceled -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnFire0;
                @Jump.started -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnJump;
                @Jump.performed -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnJump;
                @Jump.canceled -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnJump;
                @Look.started -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnLook;
                @Look.performed -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnLook;
                @Look.canceled -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnLook;
                @Touch0.started -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnTouch0;
                @Touch0.performed -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnTouch0;
                @Touch0.canceled -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnTouch0;
                @Touch0Position.started -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnTouch0Position;
                @Touch0Position.performed -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnTouch0Position;
                @Touch0Position.canceled -= m_Wrapper.m_PlayerControlActionsCallbackInterface.OnTouch0Position;
            }
            m_Wrapper.m_PlayerControlActionsCallbackInterface = instance;
            if (instance != null)
            {
                @Movement.started += instance.OnMovement;
                @Movement.performed += instance.OnMovement;
                @Movement.canceled += instance.OnMovement;
                @Fire0.started += instance.OnFire0;
                @Fire0.performed += instance.OnFire0;
                @Fire0.canceled += instance.OnFire0;
                @Jump.started += instance.OnJump;
                @Jump.performed += instance.OnJump;
                @Jump.canceled += instance.OnJump;
                @Look.started += instance.OnLook;
                @Look.performed += instance.OnLook;
                @Look.canceled += instance.OnLook;
                @Touch0.started += instance.OnTouch0;
                @Touch0.performed += instance.OnTouch0;
                @Touch0.canceled += instance.OnTouch0;
                @Touch0Position.started += instance.OnTouch0Position;
                @Touch0Position.performed += instance.OnTouch0Position;
                @Touch0Position.canceled += instance.OnTouch0Position;
            }
        }
    }
    public PlayerControlActions @PlayerControl => new PlayerControlActions(this);

    // PlayerUI
    private readonly InputActionMap m_PlayerUI;
    private IPlayerUIActions m_PlayerUIActionsCallbackInterface;
    private readonly InputAction m_PlayerUI_Navigate;
    private readonly InputAction m_PlayerUI_Submit;
    private readonly InputAction m_PlayerUI_Cancel;
    private readonly InputAction m_PlayerUI_Point;
    private readonly InputAction m_PlayerUI_Click;
    private readonly InputAction m_PlayerUI_ScrollWheel;
    private readonly InputAction m_PlayerUI_MiddleClick;
    private readonly InputAction m_PlayerUI_RightClick;
    private readonly InputAction m_PlayerUI_TrackedDevicePosition;
    private readonly InputAction m_PlayerUI_TrackedDeviceOrientation;
    public struct PlayerUIActions
    {
        private @PlayerInputAsset m_Wrapper;
        public PlayerUIActions(@PlayerInputAsset wrapper) { m_Wrapper = wrapper; }
        public InputAction @Navigate => m_Wrapper.m_PlayerUI_Navigate;
        public InputAction @Submit => m_Wrapper.m_PlayerUI_Submit;
        public InputAction @Cancel => m_Wrapper.m_PlayerUI_Cancel;
        public InputAction @Point => m_Wrapper.m_PlayerUI_Point;
        public InputAction @Click => m_Wrapper.m_PlayerUI_Click;
        public InputAction @ScrollWheel => m_Wrapper.m_PlayerUI_ScrollWheel;
        public InputAction @MiddleClick => m_Wrapper.m_PlayerUI_MiddleClick;
        public InputAction @RightClick => m_Wrapper.m_PlayerUI_RightClick;
        public InputAction @TrackedDevicePosition => m_Wrapper.m_PlayerUI_TrackedDevicePosition;
        public InputAction @TrackedDeviceOrientation => m_Wrapper.m_PlayerUI_TrackedDeviceOrientation;
        public InputActionMap Get() { return m_Wrapper.m_PlayerUI; }
        public void Enable() { Get().Enable(); }
        public void Disable() { Get().Disable(); }
        public bool enabled => Get().enabled;
        public static implicit operator InputActionMap(PlayerUIActions set) { return set.Get(); }
        public void SetCallbacks(IPlayerUIActions instance)
        {
            if (m_Wrapper.m_PlayerUIActionsCallbackInterface != null)
            {
                @Navigate.started -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnNavigate;
                @Navigate.performed -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnNavigate;
                @Navigate.canceled -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnNavigate;
                @Submit.started -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnSubmit;
                @Submit.performed -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnSubmit;
                @Submit.canceled -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnSubmit;
                @Cancel.started -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnCancel;
                @Cancel.performed -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnCancel;
                @Cancel.canceled -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnCancel;
                @Point.started -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnPoint;
                @Point.performed -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnPoint;
                @Point.canceled -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnPoint;
                @Click.started -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnClick;
                @Click.performed -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnClick;
                @Click.canceled -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnClick;
                @ScrollWheel.started -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnScrollWheel;
                @ScrollWheel.performed -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnScrollWheel;
                @ScrollWheel.canceled -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnScrollWheel;
                @MiddleClick.started -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnMiddleClick;
                @MiddleClick.performed -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnMiddleClick;
                @MiddleClick.canceled -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnMiddleClick;
                @RightClick.started -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnRightClick;
                @RightClick.performed -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnRightClick;
                @RightClick.canceled -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnRightClick;
                @TrackedDevicePosition.started -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnTrackedDevicePosition;
                @TrackedDevicePosition.performed -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnTrackedDevicePosition;
                @TrackedDevicePosition.canceled -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnTrackedDevicePosition;
                @TrackedDeviceOrientation.started -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnTrackedDeviceOrientation;
                @TrackedDeviceOrientation.performed -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnTrackedDeviceOrientation;
                @TrackedDeviceOrientation.canceled -= m_Wrapper.m_PlayerUIActionsCallbackInterface.OnTrackedDeviceOrientation;
            }
            m_Wrapper.m_PlayerUIActionsCallbackInterface = instance;
            if (instance != null)
            {
                @Navigate.started += instance.OnNavigate;
                @Navigate.performed += instance.OnNavigate;
                @Navigate.canceled += instance.OnNavigate;
                @Submit.started += instance.OnSubmit;
                @Submit.performed += instance.OnSubmit;
                @Submit.canceled += instance.OnSubmit;
                @Cancel.started += instance.OnCancel;
                @Cancel.performed += instance.OnCancel;
                @Cancel.canceled += instance.OnCancel;
                @Point.started += instance.OnPoint;
                @Point.performed += instance.OnPoint;
                @Point.canceled += instance.OnPoint;
                @Click.started += instance.OnClick;
                @Click.performed += instance.OnClick;
                @Click.canceled += instance.OnClick;
                @ScrollWheel.started += instance.OnScrollWheel;
                @ScrollWheel.performed += instance.OnScrollWheel;
                @ScrollWheel.canceled += instance.OnScrollWheel;
                @MiddleClick.started += instance.OnMiddleClick;
                @MiddleClick.performed += instance.OnMiddleClick;
                @MiddleClick.canceled += instance.OnMiddleClick;
                @RightClick.started += instance.OnRightClick;
                @RightClick.performed += instance.OnRightClick;
                @RightClick.canceled += instance.OnRightClick;
                @TrackedDevicePosition.started += instance.OnTrackedDevicePosition;
                @TrackedDevicePosition.performed += instance.OnTrackedDevicePosition;
                @TrackedDevicePosition.canceled += instance.OnTrackedDevicePosition;
                @TrackedDeviceOrientation.started += instance.OnTrackedDeviceOrientation;
                @TrackedDeviceOrientation.performed += instance.OnTrackedDeviceOrientation;
                @TrackedDeviceOrientation.canceled += instance.OnTrackedDeviceOrientation;
            }
        }
    }
    public PlayerUIActions @PlayerUI => new PlayerUIActions(this);
    public interface IPlayerControlActions
    {
        void OnMovement(InputAction.CallbackContext context);
        void OnFire0(InputAction.CallbackContext context);
        void OnJump(InputAction.CallbackContext context);
        void OnLook(InputAction.CallbackContext context);
        void OnTouch0(InputAction.CallbackContext context);
        void OnTouch0Position(InputAction.CallbackContext context);
    }
    public interface IPlayerUIActions
    {
        void OnNavigate(InputAction.CallbackContext context);
        void OnSubmit(InputAction.CallbackContext context);
        void OnCancel(InputAction.CallbackContext context);
        void OnPoint(InputAction.CallbackContext context);
        void OnClick(InputAction.CallbackContext context);
        void OnScrollWheel(InputAction.CallbackContext context);
        void OnMiddleClick(InputAction.CallbackContext context);
        void OnRightClick(InputAction.CallbackContext context);
        void OnTrackedDevicePosition(InputAction.CallbackContext context);
        void OnTrackedDeviceOrientation(InputAction.CallbackContext context);
    }
}
