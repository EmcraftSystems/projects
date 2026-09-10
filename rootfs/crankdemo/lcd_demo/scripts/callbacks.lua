local ds1_code = "100"
local ds2_code = "100"
local key_y_1 ="146"
local ds1_state="1"
local volume_delta=10
local left_volume=50
local right_volume=50
local max_volume=100
local min_volume=0
local ds2_state=0
local t_state=1
local idval = {}
local data = {}
local g_control = nil
local timeout_timer = nil
local g_tumbler_list ={}
local g_current_tumbler = nil


 
function cb_test(mapargs) 
gdata = gre.get_control_attrs(mapargs.context_control)
local data_table = gre.get_data("DS1_DS2.ds1_blink_num.ds1_blink_value")
local ds1_code = data_table["DS1_DS2.ds1_blink_num.ds1_blink_value"]
    
key_x=gdata["x"]
key_y=gdata["y"]
 
if key_y==38 then
    if key_x==139 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'1'
         gre.animation_trigger("activate1")
    end 
    if key_x==203 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'2'
       gre.animation_trigger("activate2")
    end 
    if key_x==266 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'3'
        gre.animation_trigger("activate3")
    end   
end
if key_y==96 then
    if key_x==139 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'4'
        gre.animation_trigger("activate4")
    end 
    if key_x==203 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'5'
        gre.animation_trigger("activate5")
    end 
    if key_x==266 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'6'
        gre.animation_trigger("activate6")
    end   
end  
if key_y==154 then
    if key_x==139 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'7'
      gre.animation_trigger("activate7")
    end 
    if key_x==203 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'8'
      gre.animation_trigger("activate8")
    end 
   
    if key_x==266 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'9'
      gre.animation_trigger("activate9")
    end   
end
if key_y==212 then
    if key_x==139 then
      ds1_code=string.sub(ds1_code,1,string.len(ds1_code)-1)
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code
      gre.animation_trigger("activateless")
    end
    if key_x==203 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'0'
      gre.animation_trigger("activate0")
    end 
    if key_x==266 then
      ds1_code=""
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code
      gre.animation_trigger("activatedell")
    end   
end
gre.set_data(data)
end

function cb_ds2(mapargs) 
local data = {}
local gdata = {}
  
gdata = gre.get_control_attrs(mapargs.context_control)
local data_table = gre.get_data("lcd_DS2_active.ds2_blink_num.ds2_blink_value")
local ds2_code = data_table["lcd_DS2_active.ds2_blink_num.ds2_blink_value"]
  
key_x=gdata["x"]
key_y=gdata["y"]
  
if key_y==38 then
    if key_x==139 then
      data["lcd_DS2_active.ds2_blink_num.ds2_blink_value"]=ds2_code..'1'
      gre.animation_trigger("activate1")
    end 
    if key_x==203 then
      data["lcd_DS2_active.ds2_blink_num.ds2_blink_value"]=ds2_code..'2'
      gre.animation_trigger("activate2")
    end 
    if key_x==266 then
      data["lcd_DS2_active.ds2_blink_num.ds2_blink_value"]=ds2_code..'3'
      gre.animation_trigger("activate3")
    end   
end
if key_y==96 then
    if key_x==139 then
      data["lcd_DS2_active.ds2_blink_num.ds2_blink_value"]=ds2_code..'4'
      gre.animation_trigger("activate4")
    end 
    if key_x==203 then
      data["lcd_DS2_active.ds2_blink_num.ds2_blink_value"]=ds2_code..'5'
      gre.animation_trigger("activate5")
    end 
  
    if key_x==266 then
      data["lcd_DS2_active.ds2_blink_num.ds2_blink_value"]=ds2_code..'6'
      gre.animation_trigger("activate6")
    end   
end  
if key_y==154 then
    if key_x==139 then
     data["lcd_DS2_active.ds2_blink_num.ds2_blink_value"]=ds2_code..'7'
     gre.animation_trigger("activate7")
    end 
    if key_x==203 then
      data["lcd_DS2_active.ds2_blink_num.ds2_blink_value"]=ds2_code..'8'
       gre.animation_trigger("activate8")
    end 
    if key_x==266 then
      data["lcd_DS2_active.ds2_blink_num.ds2_blink_value"]=ds2_code..'9'
      gre.animation_trigger("activate9")
    end   
end
if key_y==212 then
    if key_x==139 then
  
     ds2_code=string.sub(ds2_code,1,string.len(ds2_code)-1)
     data["lcd_DS2_active.ds2_blink_num.ds2_blink_value"]=ds2_code
     gre.animation_trigger("activateless")
     end
   if key_x==203 then
      data["lcd_DS2_active.ds2_blink_num.ds2_blink_value"]=ds2_code..'0'
      gre.animation_trigger("activate0")
   end 
  if key_x==266 then
    ds2_code=""
    data["lcd_DS2_active.ds2_blink_num.ds2_blink_value"]=ds2_code
    gre.animation_trigger("activatedell")
  end   
end
gre.set_data(data)
end

function stop_anime(mapargs) 

local data
data = gre.timer_clear_interval(idval)
end

function anime_repeate(mapargs) 
idval = gre.timer_set_interval(cb1_func, 500)
  
end
    
function cb1_func()
gre.animation_trigger("NewAnimation")
end

function deactivate_buttons(mapargs) 
local dk_data = {}
  dk_data["active"] = 0
  gre.set_control_attrs("ds1_keyboard.1", dk_data) 
  gre.set_control_attrs("ds1_keyboard.2", dk_data) 
  gre.set_control_attrs("ds1_keyboard.3", dk_data)
  gre.set_control_attrs("ds1_keyboard.4", dk_data)
  gre.set_control_attrs("ds1_keyboard.5", dk_data)
  gre.set_control_attrs("ds1_keyboard.6", dk_data)
  gre.set_control_attrs("ds1_keyboard.7", dk_data)
  gre.set_control_attrs("ds1_keyboard.8", dk_data)
  gre.set_control_attrs("ds1_keyboard.9", dk_data)
  gre.set_control_attrs("ds1_keyboard.0", dk_data)
  gre.set_control_attrs("ds1_keyboard.less", dk_data)
  gre.set_control_attrs("ds1_keyboard.del", dk_data)
  gre.set_control_attrs("ds2_keyboard.1", dk_data) 
  gre.set_control_attrs("ds2_keyboard.2", dk_data) 
  gre.set_control_attrs("ds2_keyboard.3", dk_data)
  gre.set_control_attrs("ds2_keyboard.4", dk_data)
  gre.set_control_attrs("ds2_keyboard.5", dk_data)
  gre.set_control_attrs("ds2_keyboard.6", dk_data)
  gre.set_control_attrs("ds2_keyboard.7", dk_data)
  gre.set_control_attrs("ds2_keyboard.8", dk_data)
  gre.set_control_attrs("ds2_keyboard.9", dk_data)
  gre.set_control_attrs("ds2_keyboard.0", dk_data)
  gre.set_control_attrs("ds2_keyboard.less", dk_data)
  gre.set_control_attrs("ds2_keyboard.del", dk_data)
  gre.set_control_attrs("DS1_DS2.DS2_button", dk_data)
  gre.set_control_attrs("DS1_DS2.DS1_button", dk_data)
  gre.set_control_attrs("led_menu.back_button_up", dk_data)
      
end

function activate_buttons(mapargs) 
local dk_data = {}
  dk_data["active"] = 1
  gre.set_control_attrs("ds1_keyboard.1", dk_data) 
  gre.set_control_attrs("ds1_keyboard.2", dk_data) 
  gre.set_control_attrs("ds1_keyboard.3", dk_data)
  gre.set_control_attrs("ds1_keyboard.4", dk_data)
  gre.set_control_attrs("ds1_keyboard.5", dk_data)
  gre.set_control_attrs("ds1_keyboard.6", dk_data)
  gre.set_control_attrs("ds1_keyboard.7", dk_data)
  gre.set_control_attrs("ds1_keyboard.8", dk_data)
  gre.set_control_attrs("ds1_keyboard.9", dk_data)
  gre.set_control_attrs("ds1_keyboard.0", dk_data)
  gre.set_control_attrs("ds1_keyboard.less", dk_data)
  gre.set_control_attrs("ds1_keyboard.del", dk_data)
  gre.set_control_attrs("ds2_keyboard.1", dk_data) 
  gre.set_control_attrs("ds2_keyboard.2", dk_data) 
  gre.set_control_attrs("ds2_keyboard.3", dk_data)
  gre.set_control_attrs("ds2_keyboard.4", dk_data)
  gre.set_control_attrs("ds2_keyboard.5", dk_data)
  gre.set_control_attrs("ds2_keyboard.6", dk_data)
  gre.set_control_attrs("ds2_keyboard.7", dk_data)
  gre.set_control_attrs("ds2_keyboard.8", dk_data)
  gre.set_control_attrs("ds2_keyboard.9", dk_data)
  gre.set_control_attrs("ds2_keyboard.0", dk_data)
  gre.set_control_attrs("ds2_keyboard.less", dk_data)
  gre.set_control_attrs("ds2_keyboard.del", dk_data)
  gre.set_control_attrs("DS1_DS2.DS2_button", dk_data)
  gre.set_control_attrs("DS1_DS2.DS1_button", dk_data)
  gre.set_control_attrs("led_menu.back_button_up", dk_data)
      
end

function cb_press_key(mapargs) 
 local data = {}
 local gdata = {}
 local dk_data = {}
  
  dk_data = gre.get_control_attrs("led_menu.black_line")
 
 key_y_1 = dk_data ["y"]
    
 
 if key_y_1==146 then
   gdata = gre.get_control_attrs(mapargs.context_control)
   local data_table = gre.get_data("DS1_DS2.ds1_blink_num.ds1_blink_value")
   local ds1_code = data_table["DS1_DS2.ds1_blink_num.ds1_blink_value"]
    
  
  key_x=gdata["x"]
  key_y=gdata["y"]
  
  
  if key_y==38 then
    if key_x==139 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'1'
         gre.animation_trigger("activate1")
    end 
    if key_x==203 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'2'
       gre.animation_trigger("activate2")
    end 
    if key_x==266 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'3'
        gre.animation_trigger("activate3")
    end   
  end
  if key_y==96 then
    if key_x==139 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'4'
        gre.animation_trigger("activate4")
    end 
    if key_x==203 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'5'
        gre.animation_trigger("activate5")
    end 
  
    if key_x==266 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'6'
        gre.animation_trigger("activate6")
    end   
  end  
   if key_y==154 then
    if key_x==139 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'7'
        gre.animation_trigger("activate7")
    end 
    if key_x==203 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'8'
        gre.animation_trigger("activate8")
    end 
   
    if key_x==266 then
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'9'
        gre.animation_trigger("activate9")
    end   
  end
  if key_y==212 then
    if key_x==139 then
    
     ds1_code=string.sub(ds1_code,1,string.len(ds1_code)-1)
   
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code
        gre.animation_trigger("activateless")
     end
   if key_x==203 then
   data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code..'0'
     gre.animation_trigger("activate0")
 
   end 
   
    if key_x==266 then
      ds1_code=""
      data["DS1_DS2.ds1_blink_num.ds1_blink_value"]=ds1_code
        gre.animation_trigger("activatedell")
   end   
  end
else

 gdata = gre.get_control_attrs(mapargs.context_control)
   local data_table = gre.get_data("DS1_DS2.ds2_blink_num.ds2_blink_value")
   local ds2_code = data_table["DS1_DS2.ds2_blink_num.ds2_blink_value"]
    
 key_x=gdata["x"]
 key_y=gdata["y"]
  
  
  if key_y==38 then
    if key_x==139 then
      data["DS1_DS2.ds2_blink_num.ds2_blink_value"]=ds2_code..'1'
         gre.animation_trigger("activate1")
    end 
    if key_x==203 then
      data["DS1_DS2.ds2_blink_num.ds2_blink_value"]=ds2_code..'2'
       gre.animation_trigger("activate2")
    end 
    if key_x==266 then
      data["DS1_DS2.ds2_blink_num.ds2_blink_value"]=ds2_code..'3'
        gre.animation_trigger("activate3")
    end   
  end
  if key_y==96 then
    if key_x==139 then
      data["DS1_DS2.ds2_blink_num.ds2_blink_value"]=ds2_code..'4'
        gre.animation_trigger("activate4")
    end 
    if key_x==203 then
      data["DS1_DS2.ds2_blink_num.ds2_blink_value"]=ds2_code..'5'
        gre.animation_trigger("activate5")
    end 
  
    if key_x==266 then
      data["DS1_DS2.ds2_blink_num.ds2_blink_value"]=ds2_code..'6'
        gre.animation_trigger("activate6")
    end   
  end  
   if key_y==154 then
    if key_x==139 then
      data["DS1_DS2.ds2_blink_num.ds2_blink_value"]=ds2_code..'7'
        gre.animation_trigger("activate7")
    end 
    if key_x==203 then
      data["DS1_DS2.ds2_blink_num.ds2_blink_value"]=ds2_code..'8'
        gre.animation_trigger("activate8")
    end 
   
    if key_x==266 then
      data["DS1_DS2.ds2_blink_num.ds2_blink_value"]=ds2_code..'9'
        gre.animation_trigger("activate9")
    end   
  end
  if key_y==212 then
    if key_x==139 then
    
     ds2_code=string.sub(ds2_code,1,string.len(ds2_code)-1)
   
      data["DS1_DS2.ds2_blink_num.ds2_blink_value"]=ds2_code
        gre.animation_trigger("activateless")
     end
   if key_x==203 then
   data["DS1_DS2.ds2_blink_num.ds2_blink_value"]=ds2_code..'0'
     gre.animation_trigger("activate0")
 
   end 
   
    if key_x==266 then
      ds2_code=""
      data["DS1_DS2.ds2_blink_num.ds2_blink_value"]=ds2_code
        gre.animation_trigger("activatedell")
   end   
  end
end
gre.set_data(data)
end

function volume_up(mapargs) 
local data = {}
local dk_data = {}
dk_data = gre.get_control_attrs("audio_menu.black_line")
key_y_1 = dk_data ["y"]
 
if key_y_1==146 then
data["audio_active.left_indicator.left_vol_image"]="images/au_"..left_volume..".png"
  left_volume = left_volume + volume_delta
   data["audio_active.left_indicator.left_vol_image"]="images/au_"..left_volume..".png"
  if left_volume > max_volume then
    left_volume = max_volume
    data["audio_active.left_indicator.left_vol_image"]="images/au_100.png"
  end
  data["audio_control.left_control.left_value"] = left_volume
else  
data["audio_active.right_indicator.right_vol_image"]="images/au_"..right_volume..".png"
  right_volume = right_volume + volume_delta
     data["audio_active.right_indicator.right_vol_image"]="images/au_"..right_volume..".png"
  if right_volume > max_volume then
    right_volume = max_volume
      data["audio_active.right_indicator.right_vol_image"]="images/au_100.png"
  end
   data["audio_control.right_control.right_value"] = right_volume
end  
  gre.set_data(data)
end

function volume_down(mapargs) 
-- Your code goes here ...

local data = {}
local dk_data = {}
dk_data = gre.get_control_attrs("audio_menu.black_line")
 
  
key_y_1 = dk_data ["y"]
 
if key_y_1==146 then
 data["audio_active.left_indicator.left_vol_image"]="images/au_"..left_volume..".png"
  left_volume = left_volume - volume_delta
     data["audio_active.left_indicator.left_vol_image"]="images/au_"..left_volume..".png"
  if left_volume < min_volume then
    left_volume = min_volume
     data["audio_active.left_indicator.left_vol_image"]="images/au_0.png"
  end
 
 data["audio_control.left_control.left_value"] = left_volume
else  
  data["audio_active.right_indicator.right_vol_image"]="images/au_"..right_volume..".png"
  right_volume = right_volume - volume_delta
  data["audio_active.right_indicator.right_vol_image"]="images/au_"..right_volume..".png"
  if right_volume < min_volume then
    right_volume = min_volume
    data["audio_active.right_indicator.right_vol_image"]="images/au_0.png"
  end
    data["audio_control.right_control.right_value"] = right_volume
end  
gre.set_data(data)
end

function cb_init(mapargs)
  local data = {}
  local row = 0
  
  for n=99, 30, -1 do
    row = row + 1
    data["levels.table.br."..row..".1"] = tostring(n)
  end
  data["table_rows"] = row
  gre.set_data(data)  
  gre.send_event_target("resize_table","levels.table")
end

function get_cell_data(control)

  local v = {}
  v = gre.get_table_attrs(control, "visible_rows", "rows")
  --local sel_row = math.ceil(v["visible_rows"] / 2)
  local sel_row = math.ceil(v["visible_rows"] / 3)
  
  local d = {}
  d = gre.get_table_cell_attrs(control, 1, 1,"height")
  --print("height = "..d["height"].." selected = "..sel_row)
  return d["height"], sel_row, v["rows"]
end

-- When the button is pressed then we start recording interesting data
function cb_list_press(mapargs)
  local ev = mapargs["context_event_data"];
  
  -- If we had a tumbler, mark it as unpressed now in case we missed it 
  if g_current_tumbler then
    local info = g_current_tumbler and g_tumbler_list[g_current_tumbler]
    if info ~= nil then
      info.press = 0
    end
  end
  
  -- Initialize the mouse and control tracking
  g_current_tumbler = mapargs.context_control
  
  local info = {}
  info.press = 1
  info.pos = tonumber(ev["y"])

  info.last_pos = info.pos
  info.offset = 0
  info.acceleration = 0
  info.speed = 0;
  
  -- Use this to determine snapping and drag limits
  local height, selector, num_rows = get_cell_data(g_current_tumbler)
  info.cell_height = height       -- The height of the individual cells
  info.cell_selector_offset = selector  -- How many cells down from the origin we use as our selector

  --TODO: If the timer isn't already firing, start it 
  local data = gre.get_data(g_current_tumbler..".grd_height", g_current_tumbler..".grd_yoffset", g_current_tumbler..".type")
  info.height = height * num_rows
  info.list_y = data[g_current_tumbler..".grd_yoffset"]
  if data[g_current_tumbler..".type"] ~= nil then
    info.type = data[g_current_tumbler..".type"]
  else
    info.type = 0
  end
  
  if info.type == 1 then  
    local v = {}
    v = gre.get_table_attrs(mapargs.context_control, "rows")
  
    local d = {}
    d = gre.get_table_cell_attrs(mapargs.context_control, 1, 1,"height")
    
    if ((v["rows"] * d["height"]) < 1020) then
      info.y_max = 120
      info.y_min = 120
    else
      info.y_max = 120
      info.y_min = (-1 * v["rows"] * d["height"]) + 1020 + 120
    end 
  end
  
  -- Add the control structure to the master list   
  g_tumbler_list[g_current_tumbler] = info
  
  gre.send_event("tumbler_timer_start")
end
-- When we drag, we reset the amount we are going to move based on the
-- position delta between the motion events.  The bigger the delta the
-- faster we should be scrolling the list.
function cb_list_motion(mapargs)
  local ev = mapargs["context_event_data"];
  if ev == nil then
    return
  end
  
  -- If we don't have a current tumbler or we haven't pressed, then bail out
  local info = g_current_tumbler and g_tumbler_list[g_current_tumbler]
  if info == nil or info.press ~= 1 then
    return
  end
  
  -- Mouse tracking ...
  info.last_pos = info.pos;
  info.pos = tonumber(ev["y"])
  info.offset = info.last_pos - info.pos
  info.acceleration = info.offset       -- Adjust by some time factor if desired
  
  -- Speed is actually an amount to move ...
  info.speed = -1 * info.acceleration
  
  if info.press == 1 then
    info.list_y = info.list_y - info.offset
    local data = {}
    data[g_current_tumbler..".grd_yoffset"] = info.list_y
    gre.set_data(data)
  end

end

-- Once the list is released, then mark the control structure as being 
function cb_list_release(mapargs)
  local info = g_current_tumbler and g_tumbler_list[g_current_tumbler]
  if info == nil then
    return
  end
  
  --cb_list_motion(mapargs)
  info.press = 0
end

-- The timer is what performs the movement of the list.
-- It may be that the list is moved in response to the mouse being held down
-- or it may be that the movement is due to the deceleration that happens after
-- the mouse hase been released.
function cb_timer(mapargs)  
  -- If we don't have a current tumbler then bail out
  local info = g_current_tumbler and g_tumbler_list[g_current_tumbler]
  if (info == nil) then
    return
  end
  -- Decelerate the automatic scroll (reset if the mouse moves)
  info.speed = info.speed * 0.97
  
  -- Update the position, unless we are still tracking a press
  if info.press ~= 0 then
    return
  end
  info.list_y = math.floor(info.list_y + info.speed)  


  -- Don't allow the list to scroll beyond the cell selector threshold in either direction
  --local selector_cell_y = info.cell_height * (info.cell_selector_offset - 1)
  local selector_cell_y = info.cell_height * (info.cell_selector_offset)
  
  if(info.list_y > selector_cell_y) then
    info.list_y = selector_cell_y
  elseif (info.list_y + info.height) < (selector_cell_y + info.cell_height) then
    info.list_y = selector_cell_y + info.cell_height - info.height
  end
    
  local data = {}
 
  data[g_current_tumbler..".grd_yoffset"] = info.list_y 
    
  -- Once we get to a small enough speed threshold then stop the timer .. and snap 
  if(info.speed >= 0 and info.speed < 0.5) or (info.speed < 0 and info.speed > -0.5) then
    gre.send_event("tumbler_timer_stop")
    
    if(info.type == 0) then
      --print("Type 0")
      local newy= math.floor((info.list_y) / info.cell_height) * info.cell_height
      if (info.list_y % info.cell_height) > (info.cell_height / 2) then
        info.list_y = newy + info.cell_height
        
      else
        info.list_y = newy
        
      end
    else
           
      if info.list_y < g_tumbler_list[g_current_tumbler].y_min then
        info.list_y = g_tumbler_list[g_current_tumbler].y_min
      elseif info.list_y> g_tumbler_list[g_current_tumbler].y_max then
        info.list_y = g_tumbler_list[g_current_tumbler].y_max
      end   
    
    end
    
    data[g_current_tumbler..".grd_yoffset"] = info.list_y
    gre.set_data(data)


-- Grab the values
    row = info.list_y/info.cell_height
    if (row < 0) then
      row = row * -1 +4
    else
      row = (row - 4) *-1
    end
    data = gre.get_data(tostring(g_current_tumbler)..".br."..row..".1")
    
    data["brightness.brightness_value.current_value"]=data[tostring(g_current_tumbler)..".br."..row..".1"]
    gre.set_data(data)
    g_current_tumbler = nil

    gre.send_event("tumbler_timer_stop")
  else
    data[g_current_tumbler..".grd_yoffset"] = info.list_y
    gre.set_data(data)
  end 
end


            


