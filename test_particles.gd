extends SceneTree
func _init():
    print("Constants in ParticleProcessMaterial:")
    for k in ParticleProcessMaterial:
        if str(k).begins_with("EMISSION_SHAPE"):
            print(k)
    quit()
