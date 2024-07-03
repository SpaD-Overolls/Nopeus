--- STEAMODDED HEADER

--- MOD_NAME: Nopeus
--- MOD_ID: nopeus
--- MOD_AUTHOR: [jenwalter666]
--- MOD_DESCRIPTION: An extension of MoreSpeeds which includes more options, including a new speed which makes the event manager run as fast as it can.
--- PRIORITY: 999999999
--- BADGE_COLOR: ff3c3c
--- PREFIX: nopeus
--- VERSION: 1.0.0
--- LOADER_VERSION_GEQ: 1.0.0

local setting_tabRef = G.UIDEF.settings_tab
function G.UIDEF.settings_tab(tab)
    local setting_tab = setting_tabRef(tab)

    if tab == 'Game' then
        local speeds = create_option_cycle({label = localize('b_set_gamespeed'), scale = 0.8, options = {0.25, 0.5, 1, 2, 3, 4, 8, 16, 32, 64, 999}, opt_callback = 'change_gamespeed', current_option = (
            G.SETTINGS.GAMESPEED == 0.25 and 1 or
            G.SETTINGS.GAMESPEED == 0.5 and 2 or 
            G.SETTINGS.GAMESPEED == 1 and 3 or 
            G.SETTINGS.GAMESPEED == 2 and 4 or
            G.SETTINGS.GAMESPEED == 3 and 5 or
            G.SETTINGS.GAMESPEED == 4 and 6 or 
            G.SETTINGS.GAMESPEED == 8 and 7 or 
            G.SETTINGS.GAMESPEED == 16 and 8 or 
            G.SETTINGS.GAMESPEED == 32 and 9 or 
            G.SETTINGS.GAMESPEED == 64 and 10 or 
            G.SETTINGS.GAMESPEED == 999 and 11 or 
            3 -- Default to 1 if none match, adjust as necessary
        )})
        setting_tab.nodes[1] = speeds
    end
    return setting_tab
end

function Event:init(config)
    self.trigger = config.trigger or 'immediate'
    if config.blocking ~= nil then 
        self.blocking = config.blocking
    else
        self.blocking = true
    end
    if config.blockable ~= nil then 
        self.blockable = config.blockable
    else
        self.blockable = true
    end
    self.complete = false
    self.start_timer = config.start_timer or false
    self.func = config.func or function() return true end
    self.delay = G.SETTINGS.GAMESPEED < 999 and config.delay or (self.trigger == 'ease' and 0.0001 or 0)
    self.no_delete = config.no_delete
    self.created_on_pause = config.pause_force or G.SETTINGS.paused
    self.timer = config.timer or (self.created_on_pause and 'REAL') or 'TOTAL'
    
    if self.trigger == 'ease' then
        self.ease = {
            type = config.ease or 'lerp',
            ref_table = config.ref_table,
            ref_value = config.ref_value,
            start_val = config.ref_table[config.ref_value],
            end_val = config.ease_to,
            start_time = nil,
            end_time = nil,
        }
    self.func = config.func or function(t) return t end
    end
    if self.trigger == 'condition' then
        self.condition = {
            ref_table = config.ref_table,
            ref_value = config.ref_value,
            stop_val = config.stop_val,
        }
    self.func = config.func or function() return self.condition.ref_table[self.condition.ref_value] == self.condition.stop_val end
    end
    self.time = G.TIMERS[self.timer]
end

  G.FUNCS.end_consumeable = function(e, delayfac)
    delayfac = delayfac or 1
    stop_use()
    if G.booster_pack then
      if G.booster_pack_sparkles then G.booster_pack_sparkles:fade(1*delayfac) end
      if G.booster_pack_stars then G.booster_pack_stars:fade(1*delayfac) end
      if G.booster_pack_meteors then G.booster_pack_meteors:fade(1*delayfac) end
      G.booster_pack.alignment.offset.y = G.ROOM.T.y + 9

      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2*delayfac,blocking = false, blockable = false,
      func = function()
          G.booster_pack:remove()
          G.booster_pack = nil
        return true
      end}))
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 1*delayfac,blocking = false, blockable = false,
      func = function()
        if G.booster_pack_sparkles then G.booster_pack_sparkles:remove(); G.booster_pack_sparkles = nil end
        if G.booster_pack_stars then G.booster_pack_stars:remove(); G.booster_pack_stars = nil end
        if G.booster_pack_meteors then G.booster_pack_meteors:remove(); G.booster_pack_meteors = nil end
        return true
      end}))
    end

    delay(0.2*delayfac)
    G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2*delayfac,
    func = function()
      G.FUNCS.draw_from_hand_to_deck()
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2*delayfac,
          func = function()
                if G.shop and G.shop.alignment.offset.py then 
                  G.shop.alignment.offset.y = G.shop.alignment.offset.py
                  G.shop.alignment.offset.py = nil
                end
                if G.blind_select and G.blind_select.alignment.offset.py then
                  G.blind_select.alignment.offset.y = G.blind_select.alignment.offset.py
                  G.blind_select.alignment.offset.py = nil
                end
                if G.round_eval and G.round_eval.alignment.offset.py then
                  G.round_eval.alignment.offset.y = G.round_eval.alignment.offset.py
                  G.round_eval.alignment.offset.py = nil
                end
                G.CONTROLLER.interrupt.focus = true
                
                G.E_MANAGER:add_event(Event({func = function()        
                    if G.shop then G.CONTROLLER:snap_to({node = G.shop:get_UIE_by_ID('next_round_button')}) end
                return true end }))
                G.STATE = G.GAME.PACK_INTERRUPT
                ease_background_colour_blind(G.GAME.PACK_INTERRUPT)
                G.GAME.PACK_INTERRUPT = nil
          return true
      end}))
      for i = 1, #G.GAME.tags do
        if G.GAME.tags[i]:apply_to_run({type = 'new_blind_choice'}) then break end
      end
      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2*delayfac,
          func = function()
			G.pack_cards:remove()
			G.pack_cards = nil
          return true
      end}))

      G.E_MANAGER:add_event(Event({trigger = 'after',delay = 0.2*delayfac,
          func = function()
            save_run()
            return true
      end}))

      return true
    end}))
  end