PREFABS.Wall_urban_tall_vent =
{
  file   = "wall/gtd_wall_urban_EPIC.wad"
  map    = "MAP01"

  prob   = 20
  theme = "urban"

  env = "outdoor"

  uses_epic_textures = true

  where  = "edge"
  height = 128
  deep   = 80

  bound_z1 = 0
  bound_z2 = 128

  x_fit = "frame"
  z_fit = "top"
}

PREFABS.Wall_urban_fire_exit_low =
{
  template = "Wall_urban_tall_vent"
  map = "MAP02"

  height = 200
  deep = 48

  bound_z2 = 200
}

PREFABS.Wall_urban_fire_exit_high =
{
  template = "Wall_urban_tall_vent"
  map = "MAP03"

  height = 384
  deep = 48

  bound_z2 = 384
}
