extends Node2D

export(PackedScene) var debris 
export(Texture) var item_texture

func _ready():
	if !!item_texture:
		$Sprite.texture = item_texture
	#This may cause issues if we pass in textures without frames
	$Sprite.frame = randi() % (($Sprite.hframes * $Sprite.vframes))

func _on_ExplosionSensor_area_entered(area):
	var new_debris : Debris = debris.instance()
	add_child(new_debris)
	new_debris.global_position = global_position
	new_debris.connect("debris_deleted", self, "queue_free")
	$Sprite.visible = false
	new_debris.set_sprite_frame($Sprite.frame)
