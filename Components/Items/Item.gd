extends Node2D

export(PackedScene) var debris 
export(Texture) var item_texture

func _ready():
	var _c = $DebrisCandy.connect("debris_deleted", self, "queue_free")

func _on_ExplosionSensor_area_entered(_area):
	$DebrisCandy.activate()
