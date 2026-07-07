extends SceneTree

func _init():
    var path = "res://asset/dub/11.mp3"
    print("Testing path: ", path)
    var f = FileAccess.open(path, FileAccess.READ)
    if f != null:
        print("FileAccess can open it.")
    else:
        print("FileAccess CANNOT open it.")
        
    var r = ResourceLoader.exists(path)
    print("ResourceLoader.exists: ", r)
    
    var stream = load(path)
    if stream != null:
        print("Load successful. Class: ", stream.get_class())
    else:
        print("Load FAILED.")
    
    quit()
