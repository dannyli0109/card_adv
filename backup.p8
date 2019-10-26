pico-8 cartridge // http://www.pico-8.com
version 18
__lua__


function _init()
	start_game()
	a = ""
end

function _update60()
	--draw_wind()
	update_game()
end

function _draw()
	cls()
	draw_game()
	local s = "hello there"
	cursor(0,0)
	--print(a)
	--[[
	cursor(0,0)
	while(sub(s,#s,#s) != " ") do
		s = sub(s,0,#s-1)
		print(s)
	end
	]]

end

function start_game()
	init_mobs()
	init_dialogues()
	init_base_cards()
	init_combinded_cards()
	init_effects()
	dir_x = explodeval("-1,1,0,0,1,1,-1,-1")
	dir_y = explodeval("0,0,-1,1,-1,1,1,-1")
	player = create_player()
	player.add_card(create_card(1))
	player.add_card(create_card(2))
	player.add_card(create_card(1))
	player.add_card(create_card(2))
	player.add_card(create_card(1))
	player.add_card(create_card(3))
	player.add_card(create_card(3))
	
	game = create_game()
	--a = ""
	
end

--update

function update_game()
	game.handle_input()
	game.update()
end

--draw

function draw_game()
	game.draw()
	
	cursor(0,0)
 --print(a.."hello")
	print(a, 0,0,10)
	--print(mob_name[1])
end


-->8
-- data

function init_mobs()
	mob_name 						= explode("slime,blue slime,red slime")
	mob_hp 								= explodeval("10,20,30")
	mob_attack 				= explodeval("8,10,12")
	mob_color 					= explodeval("11,12,8")
	mob_spr_x 					= explodeval("0,0,0")
	mob_spr_y 					= explodeval("112,112,112")
	mob_spr_w 					= explodeval("16,16,16")
	mob_spr_h 					= explodeval("16,16,16")
	mob_spr_frames = explodeval("4,4,4")
end

function init_dialogues()
	dialogue_opening = explode("you have nothing...,you don't know where you are...,you are weak...,even the weakest slime kills you in one hit...,but you want to stay alive...,to find the purpose of your pathetic life...,you walk and walk around this place...,you found serval paths in front of you...")
end

function init_base_cards()
	b_card_name 	= explode("long sword,magic wand,shield")
	b_card_spr_x = explodeval("0,12,24")
	b_card_spr_y = explodeval("16,16,16")
	b_card_spr_w = explodeval("12,12,12")
	b_card_spr_h = explodeval("16,16,16")
end

function init_combinded_cards()
	c_card_name 		= explode("dual wield,arcane strike,knight sperits,arcane strike,meteor,counter spell,knight sperits,counter spell,barricade")
	c_card_card_1 = explodeval("1,1,1,2,2,2,3,3,3")
	c_card_card_2 = explodeval("1,2,3,1,2,3,1,2,3")
	c_card_target = explode("enemy,enemy,enemy,enemy,enemy_all,self,enemy,self,enemy")
	c_card_effect = explode("damage:5;damage:5,pure_damage:5,damage:5;block:5,pure_damage:5,pure_damage:3,spell_immue:1,damage:5;block:5,spell_immue:1,block:10")
end


function init_effects()
	effects = {}
	effects["damage"] = damage
	effects["pure_damage"] = pure_damage
	effects["block"] = block
	effects["spell_immue"] = spell_immue
end
-->8
--skills

function damage(target, dmg)
		if (target.block >= dmg) then
			target.block -= dmg
		else 
			dmg -= target.block
			target.block = 0
			target.hp = max(0, target.hp - dmg)
		end
		sfx(1)
end

function pure_damage(target, dmg)
	target.hp = max(0, target.hp - dmg)
		sfx(1)
end

function block(target, amt)
	player.block += amt
	sfx(2)
end

function spell_immue(target, amt)
	
end








function compute_skills(s1,s2,mob)
	local cards = player.hand
	local combinded_card = get_combined_card(
		s1,
		s2
	)
	
	local sks = split_skills(c_card_effect[combinded_card])
	
	return function()
		for i=1,#sks do
			local effect, amt = split_skills_param(sks[i])
			effects[effect](mob, amt)
			yield()
		end
	end
end
-->8
--ui
function add_wind(_x, _y, _w, _h, _txt, _transparent,_butt)
	local w ={
		x=_x,
		y=_y,
		w=_w,
		h=_h,
		txt=_txt,
		sprite=nil,
		butt=_butt,
		life = 0,
		transparent = _transparent or false
	}
	return w
end

function add_sprite_wind(_x, _y, _w, _h, _sprite, _transparent,_butt)
	local w = add_wind(_x, _y, _w, _h, {}, _transparent,_butt)
	w.sprite = _sprite
	return w
end

function draw_wind(_wind)
	for w in all (_wind) do
		local wx,wy,ww,wh = w.x, w.y, w.w, w.h
		local ogy = wy
		if not w.transparent then
			rectfill(wx,wy,wx+ww-1,wy+wh-1,7)
			rectfill(wx+1,wy+1,wx+ww-2,wy+wh-2,0)
		end
		
		if not (w.sprite) then
			wy -= #w.txt * 3
			--w.txt = split_text_array(w.txt,128,10)

			for i=1,#w.txt do
				local txt=w.txt[i]
				print(
					txt, 
					wx + (ww/2-1) - #txt * 2, 
					wy + (wh/2-1) + i*2,
					6
				)
				wy+= 8
			end	
		else 
			local sprite = w.sprite
			sspr(
				sprite.x,
				sprite.y,
				sprite.w,
				sprite.h,
				wx + (ww/2-1) - sprite.w/2,
				wy + (wh/2-1) - sprite.h/2
			)
		end
		
		
		if w.butt then
			oprint8("❎", wx+ww-15,ogy+wh-2+sin(time() * 2),6,0)
		end
		
	end
end


function draw_cursor(wind,selection)
	local selected = wind[selection]
	spr(64,selected.x - 8, selected.y + selected.h/2 - 4 + sin(time() * 2))
end


function create_status_bar()
	
end


function draw_hand(cards,_x,_y,_w,_h,_cw,_ch,_tgt,_slt,_slt2)
	--local card_padding = 4
	if #cards <= 0 then return end
	
	local spaces = min(flr((_w-_cw)/(#cards-1)), _cw + 2)
	
	local padding_x = (_w - (spaces * (#cards - 1) + _cw))/2
	--a = #cards * _cw
	
	
	--a = padding_x
	for i=1,#cards do
		if (i == _tgt or i == _slt or i == _slt2) then
			
		else
			cards[i].draw(
				(i-1) * (spaces) + _x + padding_x,
				_y,
				_cw,
				_ch
			)
		end
	end
	
	if _tgt <= 0 and _slt2 <= 0 then return end
	local target = cards[_tgt]
	local _cursor = 65
	
	if (_slt > 0) then
		local selected = cards[_slt]
	
		selected.draw(
			64-24-2,
		 _y - 12,
			_cw,
			_ch
		)
		_cursor = 66
		
		local selected_index = selected.typ
		local target_index = target.typ
		local combinded_card = get_combined_card(
			selected_index,
			target_index
		)
		--a = c_card_name[combinded_card]
		--[[
		if (_slt2 <= 0) then
			target.draw(
				64+2-12,
				--(_tgt-1) * (spaces) + _x + padding_x,
				--_y - 8,
				_y - 38,
				_cw,
				_ch
			)
		end
		]]
	end
	
		target.draw(
			_slt > 0 and 64 + 2 or 64-12,
		 _y - 12,
			_cw,
			_ch
		)
	
	if (_slt2 > 0) then
		local selected = cards[_slt2]
	
		selected.draw(
			64+2,
		 _y - 12,
			_cw,
			_ch
		)
		_cursor = 66
	else 
		--[[
		target.draw(
			(_tgt-1) * (spaces) + _x + padding_x,
			_y - 8,
			_cw,
			_ch
		)
		]]
		
		spr(
			_cursor,
			target.x + target.w/2 - 4, 
			target.y + sin(time() * 2)
		)
		pal()
	end
			
end


function draw_deck(cards)
	for i=1,#cards do
		spr(67, player.deck_pos_x, player.deck_pos_y-flr((i-1)/2))
	end
end


function draw_wind2(_wind)
	for w in all (_wind) do
		local wx,wy,ww,wh = w.x, w.y, w.w, w.h
		local ogy = wy
		if not w.transparent then
			rectfill(wx,wy,wx+ww-1,wy+wh-1,7)
			rectfill(wx+1,wy+1,wx+ww-2,wy+wh-2,0)
		end
		
		if not (w.sprite) then
			--wy -= #w.txt * 3
			--w.txt = split_text_array(w.txt,128,10)

			for i=1,#w.txt do
				local txt=w.txt[i]
				print(
					txt, 
					wx + (ww/2-1) - #txt * 2, 
					wy + 4,
					6
				)
				wy+= 6
			end	
		else 
			local sprite = w.sprite
			sspr(
				sprite.x,
				sprite.y,
				sprite.w,
				sprite.h,
				wx + (ww/2-1) - sprite.w/2,
				wy + (wh/2-1) - sprite.h/2
			)
		end
		
		
		if w.butt then
			oprint8("❎", wx+ww-15,ogy+wh-2+sin(time() * 2),6,0)
		end
		
	end
end

-->8
--game_objects

function create_game_object()
	local go = {}
	return go
end

function create_game()
	local g = create_game_object()
	g.state = create_selection_state()
	g.state.enter()
	g.draw = function()
		g.state.draw()
		check_fade(game.state)
	end
	
	g.handle_input = function()
		local state = g.state.handle_input()
		if state then
			g.state.exit()
			fadeout(g.state, 0.03)
			g.state = state
			g.state.enter()
		end
	end
	
	g.update = function()
		g.state.update()
	end
	
	return g
end

function create_sprite(_x,_y,_w,_h,_sx,_sy,_sw,_sh,_color)
	local sprite = create_game_object()
	
	sprite.x = _x
	sprite.y = _y
	sprite.w = _w
	sprite.h = _h
	sprite.sx = _sx
	sprite.sy = _sy
	sprite.sw = _sw
	sprite.sh = _sh
	sprite.color = _color or 7
	sprite.draw = function(x,y,w,h)
		sprite.x = x or sprite.x
		sprite.y = y or sprite.y
		sprite.w = w or sprite.w
		sprite.h = h or sprite.h
		
		pal(7,sprite.color)
		sspr(
				sprite.sx,
				sprite.sy,
				sprite.sw,
				sprite.sh,
				sprite.x,
				sprite.y,
				sprite.w,
				sprite.h
			)
		pal()
	end
	return sprite
end

function create_mob(_typ,_x,_y,_w,_h)
	local mob = create_game_object()
	mob.x = _x
	mob.y = _y
	mob.w = _w
	mob.h = _h
	mob.name = mob_name[_typ]
	mob.block = 0
	
	mob.hp_max = mob_hp[_typ]
	mob.hp = mob.hp_max 
	mob.attack = mob_attack[_typ]
	mob.sprites = {}
	mob.frames = -1
	for i=0,mob_spr_frames[_typ]-1 do
		local sx,sy,sw,sh,_color = 
			mob_spr_x[_typ],
			mob_spr_y[_typ],
			mob_spr_w[_typ],
			mob_spr_h[_typ],
			mob_color[_typ]
		add(mob.sprites,
			create_sprite(
				_x,_y,_w,_h,
				sx+i*sw,sy,sw,sh,_color
			)
	)
	end
	
	mob.update = function()
		mob.frames += 1
	end
	
	mob.draw = function()
		local current_index = flr(mob.frames/8) % #mob.sprites + 1
		mob.sprites[current_index].draw()
		--rect(mob.x, mob.y, mob.x + 10, mob.y + 10)
		
		rect(
			mob.x, 
			mob.y - 8, 
			mob.x + mob.w - 1, 
			mob.y - 1 -4,
			7
		)
		
		local health_percentage = mob.hp / mob.hp_max
		
		rectfill(
			mob.x + 1, 
			mob.y + 1 - 8, 
			mob.x + (mob.w - 2) * health_percentage, 
			mob.y - 2 - 4,
			7
		)
		
		--print(mob.hp, mob.x, mob.y, 8)
	end
	return mob
end


function create_card(_typ)
	local card = create_game_object()
	card.x = 0
	card.y = 0
	card.w = 0
	card.h = 0
	card.sox = 120
	card.soy = 120
	card.name = b_card_name[_typ]
	card.sprites = {}
	card.back = {}
	card.ani_percentage = 0
	card.ani_increments = 0.08
	card.frames = -1
	card.targeted = false
	card.typ = _typ
	
	local sx,sy,sw,sh =	
		b_card_spr_x[_typ],
		b_card_spr_y[_typ],
		b_card_spr_w[_typ],
		b_card_spr_h[_typ]
			
		add(card.sprites,
			create_sprite(
				card.x+card.w/4,
				card.y+card.h/8,
				card.w/2,
				card.h/2,
				sx,sy,sw,sh
			)
		)
	
		add(card.back, 
			create_sprite(
				card.x,card.y,card.w,card.h,
				64,0,12,16
			)
		)
	
	card.update = function()
		--card.frames += 1
	end
	
	card.draw = function(_x,_y,_w,_h)
		card.x = _x * card.ani_percentage + (1-card.ani_percentage) * (card.sox)
		card.y = _y * card.ani_percentage + (1-card.ani_percentage) * (card.soy)
		card.w = _w
		card.h = _h
		
		card.ani_percentage = min(card.ani_percentage + card.ani_increments, 1)
		--a = card.ani_percentage
		
		
		card.back[1].draw(card.x,card.y,card.w,card.h)
		local current_index = flr(card.frames/8) % #card.sprites + 1
		
		local current_spr = card.sprites[current_index]
		
		current_spr.draw(
			card.x + current_spr.sw / 2,
			card.y + current_spr.sh / 2,
			current_spr.sw,
			current_spr.sh
		)
		
		spr(67+_typ, card.x-2, card.y-2)
	end
	
	return card
end


function create_player()
	local p = create_game_object()
	p.hp = 50
	p.block = 0
	p.deck = {}
	p.hand = {}
	p.discard = {}
	p.deck_pos_x = 128-8
	p.deck_pos_y = 128-8
	p.discard_pos_x = 0
	p.discard_pos_y = 128-8

	
	p.add_card = function(card)
		add(p.deck, card)
	end
	
	p.draw_card = function()
		if #p.deck > 0 then
			local c = get_rnd(p.deck)
			add(p.hand,c)
			del(p.deck, c)
			c.ani_percentage = 0
			c.ani_increments = 0.08
			c.sox = p.deck_pos_x
			c.soy = p.deck_pos_y
			c.ox = c.x
			c.oy = c.y
			sfx(0)
		end
	end
	
	p.discard_card = function(index)
		local c = p.hand[index]
		add(p.discard, c)
		del(p.hand, c)
		c.ani_percentage = 0
		c.ani_increments = 0.08
		c.sox = c.x
		c.soy = c.y
		c.x = p.discard_pos_x
		c.y = p.discard_pos_y
		c.ox = c.x
		c.oy = c.y
		--sfx(0)
	end
	
	--[[
	p.target_card = function(index)
		return function()
			local c = p.hand[index]
			c.sox = c.x
			c.soy = c.y - 8
			c.targeted = true
		end
	end
	]]
	
	p.draw_cards = function(num)
		return function()
			for i=1,num do
				p.draw_card()
				yield()
			end
		end
	end
	
	return p
end

-->8
-- states

-- main menu
function create_main_menu_state()
	local s = {}
	s.wind = {}
	s.fadeperc = 1
	
	s.handle_input = function()
		if btnp(5) then
			return create_adventure_state()
		end
	end
	
	s.update = function()
	
	end
	
	s.draw = function()
		draw_wind(s.wind)
	end
	
	
	s.enter = function()
		s.fadeperc = 1
		add(s.wind, 
			add_wind(
				0,0,128,128, 
				{
					"jounery to nowhere", 
					"press ❎ to start "
				},
				true
			)
		)
	end
	
	s.exit = function()
	end
	
	return s
end

-- adventure state
function create_adventure_state()	
	local s = {}
	s.wind = {}
	s.fadeperc = 1
	s.time = 0
	s.frame = 0
	s.handle_input = function(_game_object, _input)
			if btnp(5) then
				if (s.current_dialogue < #s.dialogues) then
					if (s.button) then
						s.current_dialogue += 1
						s.time = 0
						s.button = false
					else 
						s.time = 999
					end
				else 
					if (s.button) then
						return create_selection_state()
					else 
						s.time = 999
					end	
				end
			end	
	end
	
	s.enter = function()
		s.current_dialogue = 1
		s.fadeperc = 1
		s.time = 0
		s.button = false
		s.dialogues = {}
		
		for i=1,#dialogue_opening do
			local dd= {}
			add(dd, dialogue_opening[i])
			add(s.dialogues, dd)
		end
		--a = s.dialogues
		
		local d = {}
		for i=1,#s.dialogues do
			add(d, split_text_array(s.dialogues[i], 128, 20))
		end 
		
		s.dialogues = d
		
	end
	
	s.update = function()
	
		s.dialogue = s.dialogues[s.current_dialogue]
		s.wind = {}
		local count = count_text_array(s.dialogue)
		if (s.time >= count) then
			s.button = true
		end
		
		add(
			s.wind, 
			add_wind(
				0,24,128,80, 
				get_sub_str_array(
					s.dialogue, 
					s.time
				),
				false,
				s.button
			))
			
	
			s.frame += 1
			if (s.frame % 3 == 0) then
					s.time += 1
			end
			
	end
	
	s.draw = function()
		draw_wind(s.wind)
	end
	
	s.exit = function()
	
	end
	return s
end	



-----------
--selection state

function create_selection_state()
	local s = {}
	s.wind = {}
	s.selections = {}
	s.selection = 1
	s.fadeperc = 1
	
	s.handle_input = function()
		for i=0,1 do
			if (btnp(i)) then
				s.selection = mid(s.selection + dir_x[i+1], 1,4)
			end
		end
		
		if btnp(5) then
			if s.selection == 1 then
				return create_card_selection_state()
			end
		end
	end
	
	s.update = function()
		
	end
	
	s.draw = function()
		draw_wind(s.wind)
		draw_cursor(s.selections,s.selection)
	end
	
	
	s.enter = function()
		s.fadeperc = 1
			add(s.wind, 
				add_wind(
					0,16,128,48, 
					{
						"choose your path"
					},
					false
				)
			)
		for i=0,3 do
			local pl = 15
			local padding = (128-64-pl*2) / 3
			local sprite_wind = add_sprite_wind(
					pl+i*(16+padding),
					96-8-4,16,16, 
					{
						x=16*i,
						y=0,
						w=16,
						h=16
					},
					true
				)
			add(s.wind,sprite_wind)
			add(s.selections,sprite_wind)
			
		end
	end
	
	s.exit = function()
	end
	
	return s
end


function create_battle_state()
	local s = {}
	s.wind = {}
	s.fadeperc = 1
	s.mobs = {}
	s.cards = {}
	s.target = 0
	s.selected = 0
	s.selected_2 = 0
	s.frames = 0
	s.interval = 5
	s.combinded = {}
	s.selected_mob = 0

	
	s.handle_input = function()
		
	end
	
	s.update = function()
		if (s.frames % s.interval == 0) then
			coresume(s.co)	
		end
		s.frames += 1
		for m in all(s.mobs) do
			m.update()
		end
		
		if (s.selected > 0 and s.target > 0) then
			
			local cards = player.hand
			local selected_index = cards[s.selected].typ
			local target_index = cards[s.target].typ
			local combinded_card = get_combined_card(
				selected_index,
				target_index
			)
			s.combinded = {}
			
			a = s.target
			
			local show_text = {
					c_card_name[combinded_card],
					"------------"
			}
			local sks = split_skills(c_card_effect[combinded_card])
			
			for i=1,#sks do
				add(show_text, sks[i])
			end
			--split_skills(c_card_effect[combinded_card])[]
			
			add(s.combinded,
				add_wind(
					64-72/2,42,72,36, 
					show_text,
					false
				)
			)
				
		end
	end
	
	s.draw = function()

		for m in all(s.mobs) do
			m.draw()
		end
		
		draw_wind2(s.combinded)
		
		draw_hand(
			player.hand, 
			16,
			128-36,
			96,
			32,
			24,
			32,
			s.target,
			s.selected,
			s.selected_2
		)
		
		
		draw_deck(
			player.deck
		)
		
		draw_wind(s.wind)
		
		if (s.selected_mob > 0) then
			local m = s.mobs[s.selected_mob]
			rect(m.x,m.y,m.x + m.w-1,m.y+m.h-1,11)
		end
		
		--print("hp: "..player.hp, 0,0,7)
		--print("block: "..player.block, 0,6,7)
		
		
		--a = costatus(s.co)
		
	end
	
	
	s.enter = function()
		s.co = create_sequence({
			player.draw_cards(6),
			function()
				s.target = 1
				local	targeted = player.hand[s.target]
				targeted.ani_percentage = 0
				targeted.ani_increments = 0.1
				targeted.sox = targeted.x
				targeted.soy = targeted.y
			end
		})
		
		
		local rand_mob = 1+flr(rnd(#mob_name))
		local rand_card =  1+flr(rnd(#b_card_name))
			 
		local slime = create_mob(
			rand_mob,64-16,10,32,32
		)	
		add(s.mobs, slime)
		
		--[[
		add(s.wind, 
			add_wind(
				32,82,64,10, 
				{
					""
				},
				false
			)
		)
		]]
	end
	
	s.exit = function()
	end
	
	return s
end


------------
--battle states




-->8
--tool


function do_fade(fadeperc)
	local dpal={
		0,1,1,2,1,13,6,4,4,9,3,13,1,13,14
	}
	
	local p,kmax,col,k=flr(mid(0,fadeperc,1)*100)
	for j=1,15 do
		col = j
		kmax=flr((p+j*1.46)/22)
		for k=1,kmax do
			col=dpal[col]
		end
		pal(j,col,1)
	end
end

function check_fade(s)
	if s.fadeperc>0 then
		s.fadeperc=max(s.fadeperc-0.04,0)
		do_fade(s.fadeperc)
	end
end


function fadeout(s,spd,_wait)
	if (spd==nil) spd=0.04
	if (_wait==nil) _wait=0
	repeat
		s.fadeperc=min(s.fadeperc+spd,1)
		do_fade(s.fadeperc)
		flip()
	until s.fadeperc == 1
	wait(_wait)	
end


function wait(_wait)
	repeat
		_wait-=1
		flip()
	until _wait < 0
end

function get_sub_str_array(
	arr, index
)
	local output = {}
	
		for i=1,#arr do
			if index >= #arr[i] then
				index-=#arr[i]
				add(output,arr[i])
			elseif (index > 0) then
					local curr = ""
					for j=1,index do
						curr = curr..sub(arr[i], j, j)
					end
					if #curr > 0 then
						add(output, curr)
					end
					index = 0
				end 
		end
		return output
end

function count_text_array(arr)
	local count = 0
	for i=1,#arr do
		count+=#arr[i]
	end
	return count
end

function oprint8(
	_t,_x,_y,_c,_c2
)
	for i=1,8 do
		print(
			_t,
			_x+dir_x[i],
			_y+dir_y[i],
			_c2
		)
	end
	print(_t,_x,_y,_c)
end

function explode(s,divider)
 local retval,lastpos={},1
 divider = divider or ","
 for i=1,#s do
  if sub(s,i,i)==divider then
   add(retval,sub(s, lastpos, i-1))
   i+=1
   lastpos=i
  end
 end
 add(retval,sub(s,lastpos,#s))
 return retval
end

function explodeval(_arr)
 return toval(explode(_arr))
end

function toval(_arr)
 local _retarr={}
 for _i in all(_arr) do
  add(_retarr,flr(tonum(_i)))
 end
 return _retarr
end

function get_rnd(arr)
 return arr[1+flr(rnd(#arr))]
end

function split_text_array(arr,w,padding)
	local output = {}	
	
	for i=1,#arr do
		local words = split_words(arr[i])
		local curr = ""
		local max_w = flr((w-padding * 2)/4)
		for i=1, #words do
			if #(curr..words[i]) > max_w then
				if (sub(curr, #curr, #curr) == " ") then
					curr = sub(curr, 0, #curr-1)
				end
				add(output, curr)
				curr = words[i]
			else 
				curr = curr..words[i]
			end
		end
		
		if (#curr > 0) then
			add(output, curr)
		end
		
	end
	--a = output[1]
	return output	
end

function split_words(str)
	local output = {}
	local current = ""
	for i=1,#str do
		local char = sub(str, i,i)
		if (char == " " or i==#str) then
			add(output, current..char)
			current = ""
		else
			current = current..char
		end
	end
	--a = output[1]
	return output
end

function create_sequence(arr) 
	return cocreate(
		function()
				for i=1,#arr do
					arr[i]()
					yield()
				end
		end
	)
end

function get_combined_card(c1,c2)
	for i=1,#c_card_name do
		if c_card_card_1[i] == c1 and c_card_card_2[i] == c2 then
			return i
		end
	end
	return -1
end


function split_skills(skills)
	local s = explode(skills,";")
	return s
end

function split_skills_param(skill)
	local s = explode(skill,":")
	return s[1], tonum(s[2])
end

--[[
function compute_skill(skill)
	local s,p = split_skills_param(skill)
	return 
end
]]

-->8
---battle states

function create_card_selection_state()
	local s = create_battle_state()
	s.handle_input = handle_select_card_input(s)
	return s
end

function handle_select_card_input(s)
	return function()
		if (costatus(s.co) != 'dead') then return end
		if (s.selected_2 > 0) then 
			
			if player.hand[s.selected_2].ani_percentage == 1 then
				s.selected_mob = 1
				s.handle_input = handle_select_mob_input(s)
			end
			
			return
	 end 		
		for i=0,1 do
			if (btnp(i)) then
				local new_target = mid(
					(
						s.target + dir_x[i+1] == s.selected or
						s.target + dir_x[i+1] == s.selected_2) and 
						s.target + dir_x[i+1] * 2 or 
						s.selected and s.target + dir_x[i+1], 
						1, 
						#player.hand
			)
				if (new_target != s.selected and
					new_target != s.selected_2 and
					new_target != s.target
				) then
						
						local targeted = player.hand[s.target]
						targeted.ani_percentage = 0
						targeted.ani_increments = 0.1
						targeted.sox = targeted.x
						targeted.soy = targeted.y
						
						s.target = new_target
						targeted = player.hand[s.target]
						targeted.ani_percentage = 0
						targeted.ani_increments = 0.1
						targeted.sox = targeted.x
						targeted.soy = targeted.y
				end
			end
		end
		
		if (btnp(5)) then
			if #player.hand > 1 then
				sfx(0)
				--[[
				if (s.selected > 0) then
					--[[
					player.hand[s.selected].ani_percentage = 0
					player.hand[s.selected].sox = player.hand[s.selected].x
					player.hand[s.selected].soy = player.hand[s.selected].y
					]]
					s.selected_2 = s.target
					player.hand[s.selected_2].ani_percentage = 0
					player.hand[s.selected_2].sox = player.hand[s.selected_2].x
					player.hand[s.selected_2].soy = player.hand[s.selected_2].y
					
					--[[
					local cards = player.hand
					local s1 = cards[s.selected].typ
					local s2 = cards[s.selected_2].typ
					compute_skills(s1,s2,s.mobs[1])
					]]
					if (#player.hand == 2) then
						s.target = 0
					end
					return
				end
		
				s.selected = s.target
				player.hand[s.selected].ani_percentage = 0
				player.hand[s.selected].sox = player.hand[s.selected].x
				player.hand[s.selected].soy = player.hand[s.selected].y
				s.target = mid(s.selected == #player.hand and s.selected - 1 or s.selected + 1, 1, #player.hand)
			end
		end
		
		if (btn(4)) then
	
			--player.hand[s.selected].ani_percentage = 0
			--player.hand[s.selected].sox = player.hand[s.selected].x
			--player.hand[s.selected].soy = player.hand[s.selected].y
			if s.selected > 0 then
				s.target = s.selected
				s.combinded = {}
			end
			s.selected = 0
			s.selected_2 = 0
			--s.target = 1
		end
	end
end

function handle_select_mob_input(s)
	 return function()
			if (btnp(5)) then
				local cards = player.hand
				local s1 = cards[s.selected].typ
				local s2 = cards[s.selected_2].typ
				s.interval = 20
				s.co = create_sequence({
					compute_skills(s1,s2,s.mobs[1]),
					function()
						local slt = s.selected
						local slt2 = s.selected_2
						local slt_mob = s.selected_mob
						s.selected = 0
						s.selected_2 = 0
						s.selected_mob = 0
						s.target = #player.hand > 0 and 1 or 0
						player.discard_card(slt)
						player.discard_card(slt2)
					
						--s.target = 1
						s.combinded = {}
						s.handle_input = handle_select_card_input(s)
					end
				})
			end
	end
end

__gfx__
00000777777000000000077777700000000007777770000000000777777000000055555555000000000000000000000000000000000000000000000000000000
00077000000770000007700000077000000770000007700000077777777770000577777777500000000000000000000000000000000000000000000000000000
00700000000007000070000770000700007000777700070000777707707777005766666666750000000000000000000000000000000000000000000000000000
07000000000000700700000770000070070007777770007007777000000777705766666666750000000000000000000000000000000000000000000000000000
07007700007700700700000770000070070077700777007007770000000077705766666666750000000000000000000000000000000000000000000000000000
70007570075700077000000770000007700077000077000777700000000007775766666666750000000000000000000000000000000000000000000000000000
70000757057000077000000770000007700070000077000777700000000007775766666666750000000000000000000000000000000000000000000000000000
70000075700000077000000770000007700000000777000777700770077007775766666666750000000000000000000000000000000000000000000000000000
70000007570000077000000770000007700000007770000777707770077707775766666666750000000000000000000000000000000000000000000000000000
70007750757700077000000770000007700000077700000777707770077707775766666666750000000000000000000000000000000000000000000000000000
70000770077000077000000770000007700000077000000777700000000007775766666666750000000000000000000000000000000000000000000000000000
07007070070700700700000000000070070000000000007007770000000077705766666666750000000000000000000000000000000000000000000000000000
07000000000000700700000770000070070000077000007007777070070777705766666666750000000000000000000000000000000000000000000000000000
00700000000007000070000770000700007000077000070000777070070777005766666666750000000000000000000000000000000000000000000000000000
00077000000770000007700000077000000770000007700000077777777770000577777777500000000000000000000000000000000000000000000000000000
00000777777000000000077777700000000007777776000000000777777000000055555555000000000000000000000000000000000000000000000000000000
000099999990044444500000cccccccccc7c08888880000000000000000000005777777777750000000000000000000000000000000000000000000000000000
766999999999444444450000ccccc7777c7c88999988000000000000000000005777777777750000000000000000000000000000000000000000000000000000
777669999990445554450000ccccc7777c7c88899998800000000000000000005777777777750000000000000000000000000000000000000000000000000000
777779999900445454450000ccccc7777c7c88888999880000000000000000005777777777750000000000000000000000000000000000000000000000000000
777559990000445444550000ccccc7777c7c88888889888000000000000000005777777777750000000000000000000000000000000000000000000000000000
777599900000044555500000ccccc7777c7c88888888888000000000000000005777777777750000000000000000000000000000000000000000000000000000
777699900009004450000000ccccc7777c7c08888888888800000000000000000577777777500000000000000000000000000000000000000000000000000000
777769990090000445000000c7777ccccc7c00888888888800000000000000000055555555000000000000000000000000000000000000000000000000000000
077776999000000044500000c7777ccccc7c00000088898800000000000000000000000000000000000000000000000000000000000000000000000000000000
007777699500000004450000c7777ccccc7c00000008889800000000000000000000000000000000000000000000000000000000000000000000000000000000
000777799500000000445000c7777ccccc7c00000008889800000000000000000000000000000000000000000000000000000000000000000000000000000000
0000077775000000000445000c777cccc7c000000008898800000000000000000000000000000000000000000000000000000000000000000000000000000000
00000077754000000000445000c77ccc7c0000000008888000000000000000000000000000000000000000000000000000000000000000000000000000000000
000005555540000000000445000c7cc7c00000000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000044400000000000440000cc7c000000008888800000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000400000000004400000cc0000008888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000000777777777777777700666600990000000008880000cccc00000000000000000000000000000000000000000000000000000000000000000000000000
7770000077555777775555770666666099900000008880000c7cc7c0000000000000000000000000000000000000000000000000000000000000000000000000
777700007775577777775577066666600999000008880000c77cc77c000000000000000000000000000000000000000000000000000000000000000000000000
777770007775577777555577066666600099909088888880ccc77ccc000000000000000000000000000000000000000000000000000000000000000000000000
777770007775577777557777066666600009999000088800ccc77ccc000000000000000000000000000000000000000000000000000000000000000000000000
777700000775577007555570066666600000990000888000c77cc77c000000000000000000000000000000000000000000000000000000000000000000000000
7770000000777700007777000566665000099090088800000c7cc7c0000000000000000000000000000000000000000000000000000000000000000000000000
77000000000770000007700000555500000000098880000000cccc00000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000007777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000077777700000000077777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000777777770000000777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000777777777000007770777707770000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077777777770000077777777777700007770777707770000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777777777777000777707777077770007770777707770000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777777777777700777707777077770007777777777770000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777077770777770777707777077770007777777777770000077777777770000000000000000000000000000000000000000000000000000000000000000000
77777077770777770777777777777770007777777777770007777777777777700000000000000000000000000000000000000000000000000000000000000000
77777077770777770777777777777770007777777777770077777077770777770000000000000000000000000000000000000000000000000000000000000000
77777777777777770077777777777700000777777777700077777077770777770000000000000000000000000000000000000000000000000000000000000000
07777777777777770077777777777700000077777777000077777077770777770000000000000000000000000000000000000000000000000000000000000000
00777777777777700007777777777000000007777770000077777777777777770000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000d4210b420094200645008400084000650009500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000086500b6500c0500e0500f050136500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002a550245500b5500b55003550045500e5500e5500955009550105500e5500f5500e5500c550125500e550135500b5500c550085500755009550175500c5501355005550075500b55011550055500c550
