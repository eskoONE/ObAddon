----------------------------------------------------------------
--  MODULE: ZDoom Story Generator
----------------------------------------------------------------
--
--  Copyright (C) 2019 MsrSgtShooterPerson
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2
--  of the License, or (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
-------------------------------------------------------------------

gui.import("zdoom_stories.lua")

table.name_up(ZDOOM_STORIES.STORIES)

function ZStoryGen_format_story_chunk(story_strings, info)

  gui.printf("--== ZDoom: Story generator ==--\n\n")

  local line_max_length = 32

  -- replace special word tags with their proper ones from the name gen
  story_strings = string.gsub(story_strings, "_RAND_DEMON", info.demon_name)
  story_strings = string.gsub(story_strings, "_EVULZ", info.demon_title)
  story_strings = string.gsub(story_strings, "_GOTHIC_LEVEL", info.gothic_level)
  story_strings = string.gsub(story_strings, "_RAND_CONTRIBUTOR", info.contributor_name)

  -- remove the spaces left behind by Lua's square bracket stuff.
  story_strings = string.gsub(story_strings, "      ", "")
  gui.printf(story_strings .. "\n\n")
  story_strings = string.gsub(story_strings, "\n", " ")
  story_strings = string.gsub(story_strings, "_SPACE", '"\n"')

  -- ensure words are always within the width of Doom's intermission screens
  -- based on the above defined line_max_length
  local i = 1
  local manhandled_string = ''
  local manhandled_string_length = 1
  local story_lines = {}

  -- check word count
  local word_count = 0
  for word in story_strings:gmatch("%S+") do
    word_count = word_count + 1
  end

  for word in story_strings:gmatch("%S+") do

    if manhandled_string_length == 1 then
      manhandled_string = '"' .. manhandled_string
    end

    manhandled_string_length = manhandled_string_length + word:len()

    if manhandled_string_length + word:len() > line_max_length then
      manhandled_string = manhandled_string .. word .. '\\n"\n'
      table.insert(story_lines, manhandled_string)
      manhandled_string = ''
      manhandled_string_length = 1
    else
      manhandled_string = manhandled_string .. word .. ' '
    end

    if i == word_count then
      table.insert(story_lines,';\n')
    end

    i = i + 1
  end

  return story_lines
end

function ZStoryGen_fetch_story_chunk(lev_info)
  local info = { }

  if lev_info then
    info.level_name = lev_info.description
  end

  -- some names based on the namelib need to pass through the unique noun generator on
  -- the occasion it picks up the noun gen keywords, or the keywords will
  -- stay as they are in the string
  local demon_name = rand.key_by_probs(namelib.NAMES.GOTHIC.lexicon.e)
  demon_name = string.gsub(demon_name, "NOUNGENEXOTIC", namelib.generate_unique_noun("exotic"))
  info.demon_name = demon_name

  info.demon_title = rand.key_by_probs(ZDOOM_STORIES.EVIL_TITLES)
  info.gothic_level = Naming_grab_one("GOTHIC")
  info.contributor_name = rand.key_by_probs(namelib.NAMES.TITLE.lexicon.c)

  return rand.key_by_probs(ZDOOM_STORIES.LIST), info
end

function ZStoryGen_hook_me_with_a_story(story_id, info)
  local story_chunk = ZDOOM_STORIES.STORIES[story_id]
  local story_string = rand.pick(story_chunk.hooks)
  local story_table = ZStoryGen_format_story_chunk(story_string, info)
  return story_table
end

function ZStoryGen_conclude_my_story(story_id, info)
  local story_chunk = ZDOOM_STORIES.STORIES[story_id]
  local story_string = rand.pick(story_chunk.conclusions)
  local story_table = ZStoryGen_format_story_chunk(story_string, info)
  return story_table
end

function ZStoryGen_init()

  local hooks = {}
  local conclusions = {}
  local x = 1
  local language_lump = ''

  while x <= #GAME.episodes do
    local story_id, info = ZStoryGen_fetch_story_chunk()
    hooks[x] = ZStoryGen_hook_me_with_a_story(story_id, info)
    conclusions[x] = ZStoryGen_conclude_my_story(story_id, info)
    x = x + 1
  end

  gui.printf(table.tostr(hooks[1]))
  -- create language lump
  x = 0
  while x <= #GAME.episodes do
    language_lump = language_lump .. "STORYSTART" .. x .. " =\n"
    for _,line in pairs(hooks[x]) do
      language_lump = language_lump .. line
    end
    language_lump = language_lump .. "STORYEND" .. x .. " =\n"
    for _,line in (conclusions[x]) do
      language_lump = language_lump .. line
    end
    x = x + 1
  end

  gui.wad_add_text_lump("LANGUAGE",language_lump)
end

-- LOOK AT ALL THIS CODE NOW
-- SO HAPPY ALEXA PLAY D_RUNNIN