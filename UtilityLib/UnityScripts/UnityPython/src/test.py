import UnityEngine

# ironPython will set value
transform = None
speed = 4

def Start():
    UnityEngine.Debug.Log("start.." + transform.ToString())

def Update():
    #UnityEngine.Debug.Log("Update "+transform.ToString())
    h = UnityEngine.Input.GetAxis("Horizontal")
    v = UnityEngine.Input.GetAxis("Vertical")
    dir = UnityEngine.Vector3(h,0,v);
    transform.position += dir * speed * UnityEngine.Time.deltaTime

