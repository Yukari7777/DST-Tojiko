local assets =
{
	Asset( "ANIM", "anim/tojiko.zip" ),
	Asset( "ANIM", "anim/ghost_tojiko_build.zip" ),
}

local skins =
{
	normal_skin = "tojiko",
	ghost_skin = "ghost_tojiko_build",
}

return CreatePrefabSkin("tojiko_none",
{
	base_prefab = "tojiko",
	type = "base",
	assets = assets,
	skins = skins, 
	skin_tags = {"TOJIKO", "CHARACTER", "BASE"},
	build_name_override = "tojiko",
	rarity = "Character",
})