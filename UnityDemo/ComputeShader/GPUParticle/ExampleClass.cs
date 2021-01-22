// Convert the 2D position of the mouse into a
// 3D position.  Display these on the game window.

using UnityEngine;

public class ExampleClass : MonoBehaviour
{
    private Camera cam;

    void Start()
    {
        cam = Camera.main;
    }

    void OnGUI()
    {
        //Vector3 point = new Vector3();
        //Event currentEvent = Event.current;
        //Vector2 mousePos = new Vector2();

        //// Get the mouse position from Event.
        //// Note that the y position from Event is inverted.
        //mousePos.x = currentEvent.mousePosition.x;
        //mousePos.y = cam.pixelHeight - currentEvent.mousePosition.y;

        //point = cam.ScreenToWorldPoint(new Vector3(mousePos.x, mousePos.y, cam.nearClipPlane));
        var mousePos = Input.mousePosition;
        var point = cam.ScreenToWorldPoint(new Vector3(mousePos.x,mousePos.y,mousePos.z));

        GUILayout.BeginArea(new Rect(20, 20, 250, 120));
        GUILayout.Label("Screen pixels: " + cam.pixelWidth + ":" + cam.pixelHeight);
        GUILayout.Label("Mouse position: " + mousePos);
        GUILayout.Label("World position: " + point.ToString("F3"));
        GUILayout.EndArea();
    }
}