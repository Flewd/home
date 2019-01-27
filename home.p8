pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

cam={}
cam.x=0
cam.y=0
cam.speed=2

player={}
player.speed=2
player.x=40
player.y=40

friend={}
friend.spr=33
friend.distance=32
friend.x=30
friend.y=30

idleanim={}
idleanim.start=1
idleanim.spr=idleanim.start
idleanim.last=1
idleanim.spritewidth=2
idleanim.tmr=0
idleanim.frameduration=10

walkanim={}
walkanim.start=3
walkanim.spr=walkanim.start
walkanim.last=5
walkanim.spritewidth=2
walkanim.tmr=0
walkanim.frameduration=1

currentanim={}

function _init()
 setplayeranim(idleanim)
end

function _update()
 animateplayer()
 playerinput()
 friendfollow()
end

function playerinput()
 iswalking=false
 dif={}
 dif.x=0
 dif.y=0

 if (btn(0)) then
  dif.x-=player.speed
  iswalking=true
 end

 if (btn(1)) then
  dif.x+=player.speed
  iswalking=true
 end

 if (btn(2)) then
  dif.y-=player.speed
  iswalking=true
 end

 if (btn(3)) then
  dif.y+=player.speed
  iswalking=true
 end

 if(iswalking==true) then
  currentanim=walkanim
 else
  currentanim=idleanim
 end

 if(dif.x!=0 or dif.y!=0) then
  if(can_move(player,dif)==true)then
    player.x+=dif.x
    player.y+=dif.y
  end
 end

-- if(dif.y!=0) then
 --   if(can_player_movey(player,dif)==true)then
 --   player.y+=dif.y
 -- end
 --end

if player.x - cam.x > 75 then
    cam.x+=cam.speed
end

if player.x - cam.x < 20 then
    cam.x-=cam.speed
end

end

function setplayeranim(anim)
 currentanim=anim
end

function animateplayer()
 currentanim.tmr+=1
 if(currentanim.tmr>=currentanim.frameduration) then
  currentanim.spr+=currentanim.spritewidth
  currentanim.tmr=0
 end
 if(currentanim.spr>currentanim.last) then
  currentanim.spr=currentanim.start
 end

end

function can_move(p,dif)

    spritewidth=currentanim.spritewidth*8
    halfspritewidth=spritewidth/2
    top=(p.y + dif.y)
    left=(p.x + dif.x)
    right=(p.x + dif.x + spritewidth)
    bot=(p.y + dif.y + spritewidth)

    if(is_position_wall(left/8, top/8)==true) then return false end
    if(is_position_wall((left + halfspritewidth)/8, top/8)==true) then return false end
    if(is_position_wall(left/8, bot/8)==true) then return false end
    if(is_position_wall((left + halfspritewidth)/8, bot/8)==true) then return false end
    if(is_position_wall(right/8, top/8)==true) then return false end
    if(is_position_wall(left/8, (top + halfspritewidth)/8)==true) then return false end
    if(is_position_wall(right/8, bot/8)==true) then return false end
    if(is_position_wall(right/8, (bot - halfspritewidth)/8)==true) then return false end
    
    return true
end

function can_player_movex(p, diff)
	if diff.x < 0 then
        x1=(p.x+diff.x)/8
        y1=p.y/8
        --x2=
        --y2=
		if is_position_wall(x1,y1) == true then return false end
	end

	if diff.x > 0 then
		-- +8 is for player width, /8 is for width of map tiles
        spritewidth=currentanim.spritewidth*8
        x1=(p.x + diff.x + spritewidth)/8
        y1=p.y/8
		if is_position_wall(x1,y1) == true then return false end
	end

	return true
end

function can_player_movey(p, diff )
	spritewidth=currentanim.spritewidth*8
    if diff.y < 0 then
        x1=p.x
        y1=(p.y + diff.y)/8
        x2=(p.x + spritewidth)/8
        y2=(p.y + diff.y)/8
        if is_position_wall(x1,y1) == true or is_position_wall(x2,y2) == true then return false end
	end

	if diff.y > 0 then
		-- +8 is for player width, /8 is for width of map tiles
        x1=p.x/8
        y1=(p.y + spritewidth)/8
        x2=(p.x + spritewidth)/8
        y2=(p.y + spritewidth)/8
		if is_position_wall(x1,y1) == true or is_position_wall(x2,y2) == true then return false end
	end
	return true
end

function is_position_wall(x,y)
 return fget( mget(x,y), 1 )
end

function drawplayer()
 spr(currentanim.spr,player.x,player.y)
 spr(currentanim.spr+1,player.x+8,player.y)
 spr(currentanim.spr+16,player.x,player.y+8)
 spr(currentanim.spr+17,player.x+8,player.y+8)
end

function friendfollow()
-- 20 - 10
    xdir=player.x - friend.x
    ydir=player.y - friend.y

    if(abs(xdir) > friend.distance) then
        friend.x+=(xdir/40)
    end

    if(abs(ydir) > friend.distance) then
        friend.y+=(ydir/40)
    end

end

function drawrope()
 line( friend.x + 4, friend.y + 4, player.x + 8, player.y + 8, 10 )
end

function drawfriend()
 spr(friend.spr,friend.x,friend.y)
end

function _draw()
 cls()
 camera(cam.x, cam.y)
 map(0, 0, 0, 0, 32, 16)
 drawrope()
 drawfriend()
 drawplayer()
 
--	print(player.x,20,30)
--	print(player.y,40,30)

end

__gfx__
00000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000
00000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000
00000000cc777777777777cccc775777777757cccc775777777757cccc777777777777cccc777777777777cc0000000000000000000000000000000000000000
00000000cc777557775577cccc777577777577cccc777577777577cccc777557775577cccc777557775577cc0000000000000000000000000000000000000000
00000000cc775775757757cccc777757775777cccc777757775777cccc775775757757cccc775775757757cc0000000000000000000000000000000000000000
00000000cc777997779977cccc777997779977cccc777997779977cccc777997779977cccc777997779977cc0000000000000000000000000000000000000000
00000000cc777997779977cccc777997779977cccc777997779977cccc777997779977cccc777997779977cc0000000000000000000000000000000000000000
00000000cc777997779977cccc777997779977cccc777997779977cccc777997779977cccc777997779977cc0000000000000000000000000000000000000000
00000000cc777777777777cccc777777777777cccc777777777777cccc77c777777777cccc7777777777c7cc0000000000000000000000000000000000000000
00000000cc777777777777cccc777777777777cccc777777777777cccc77c777887777cccc7777778877c7cc0000000000000000000000000000000000000000
00000000cc777777777777cccc777777777777cccc777777777777cccc777777887777cccc777777887777cc0000000000000000000000000000000000000000
00000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc0000000000000000000000000000000000000000
0000000000000cc00cc000000000cc000cc0000000000cc000cc000000000cc00cc0000000000cc00cc000000000000000000000000000000000000000000000
0000000000000cc00cc00000000cc000cc000000000000cc000cc00000000cc00cc0000000000cc00cc000000000000000000000000000000000000000000000
0000000000000cc00cc0000000cc000cc00000000000000cc000cc0000000cc00cc0000000000cc00cc000000000000000000000000000000000000000000000
0000000000000cc00cc000000cc000cc0000000000000000cc000cc000000cc00cc0000000000cc00cc000000000000000000000000000000000000000000000
000000002222222200f00f004400000044000000000000000000a000000000777777000000000077777700000000007777770000000000777777000000000000
000000002777777200ffff0044000000440000000000a000000aaa00000000777777000000000077777700000000007777770000000000777777000000000000
00000000277777720f4f4ff04400000044000000000aaa0000aaaaa0000077777777770000007777777777000000777777777700000077777777770000000000
00000000277c7c7200ffff00440aaa0044000a0000aaaaa000aa9aa0000077755755770000007775575577000000777877787700000077787778770000000000
0000000027777772000ff000064aaaa0064aaaa00aaaaaa00aa989aa000077755755770000007775575577000000777887887700000077788788770000000000
000000002787787200ffff00004aaa40004aaa4aaa9999aaaa99899a000077777777770000007777777777000000777777777700000077777777770000555500
00000000277887720fffff0f0044444000444440a998899aa998889a000077775577770000007777557777000000777577577700000077757757770005555550
00000000222222220f4f4fff0044444000444440a988889aa988888a000007757757700000000775775770000000077555577000000007755557700000555500
00000000000000000000000000006000000000000000000000000000000000777777000000000077777700000000007777770000000000777777000000000000
00000000000011110000111100068600000000000000000000000000000000007000000000000000700000000000000070000000000000007000000000000000
00000000110b0001110b000100658560000000000000000000000000000007007007000000000000700000000000070070070000000007007007000000000000
00000000001000010010000106888886000000000000000000000000000007707077000000000000700000000000077070770000000007707077000000000000
00000000000811110008111100658560000000000000000000000000000000777770000000000077777000000000007777700000000000777770000000000000
00000000000111100001111000068600000000000000000000000000000000007000000000000770707700000000000070000000000000007000000000000000
00000000001000010010100000006000000000000000000000000000000000770770000000000707070700000000007707700000000000070770000000000000
00000000110000001100000000000000000000000000000000000000000000700070000000000077077000000000000000700000000000770000000000000000
0000000044455444bbbbbbbbbbb333333333bbbbbbbbbbbb99999999999999999999999969999999999999999999999999999999999699999999999999999999
0000000044455444bbbbbbbbbbb333333333bbbbbbbbbbbb99969999699999999999999999969999969999999999969999999999999999999999669999996999
0000000055555555b3bb3bbbbbb333333333bbbbbbbbbbbb99999999999996999969999999999999999999999999999999999999999999999999999999999999
0000000044444444b3b3bbbb33333383333333bbbbbbbbbb99999699969999999999999996999999999999999999999999999777779699999999999999999999
0000000044444444bb3bbb3333333333333333bbbb3b3bbb99969999999999999999999be9999999999999969999999969997557557999999999999111119999
0000000055555555bbbbbb3333333333333333bbbbb3bbbb9999999999999999969999bbbb999699996699999999999999997777777999999999999b11119999
0000000044455444bbbbbb333383333333383333bbbbbbbb969999999999999999999b8b6b899999999999999999999999997775777999699991119999916969
0000000044455444bbbbbb333333338333333333bbbbbbbb969999996999699999999b88b88969999999999e9996999999999777779999999969111999919999
9995999975755757bbbbbb333333333333333333bbbbbbbb9999e996bb99999999999ebbbbb99999999699bbb999996999999777779999999999999811119999
9599595975755757b3b3bb333333333333333333bbbbbbbb9999bb9bbe99999999699b6888b99999999bb98b8969999999999797979999999999999111199999
5999999975777757bb3bbb333333333383333333bbbb3b3b99996b9b6b999996999999bb6b9969999996b9bbbbbe999999999999999999999999111919919999
9959599975755757bbbbbbbb3383333333333333bbbbb3bb96999bbbbb9996969999999be99999999999bb88899b999999999999999999996991119999999999
9999995975755757bbbbbbbbb333333333333bbbbbbbbbbb9999999beb96999699699999999999999999998b8999999999699999999996999999999999996999
5999999975777757bbbbbbbbb333333333333bbbbbbbbbbb99999996bbbb99999999969999999969969999bbb999999999999999999999999969999999999999
9995995975755757bbbbbbbbb333333333333bbbbbbbbbbb9999999bbb99999999999999969999999999996b6999999999999999999999999999999999699999
9599999575755757bbbbbbbbbbbbb4444bbbbbbbbbbbbbbb99969999999999699699996999999999999999999999999999999999999999999999999999999999
969999963bbbbbbb33bbbbbbbbbbb4444bbbbbbb3bbbbb3300000000000000000000000000000000000000000000000000000000000000000000000000000000
99699969b3b3bbbb333bbbb3bbbbb4444bbbbbbbb3bbb33300000000000000000000000000000000000000000000000000000000000000000000000000000000
99969699bb3bb3b33833bbbbbbbbb4404bbbbbbbbbbb333300000000000000000000000000000000000000000000000000000000000000000000000000000000
99996999bbbbbb3b33333bbbbbbbb4444bbbbbbbbbb3333300000000000000000000000000000000000000000000000000000000000000000000000000000000
99669699b3bbbbbb33333b3bbbbbb4444bbbbbbb3b33383300000000000000000000000000000000000000000000000000000000000000000000000000000000
99699969bb3bb3bb383333b3bbbbb4444bbbbbbbbb33333300000000000000000000000000000000000000000000000000000000000000000000000000000000
66699966bbb33bbb333333bbbbbbb4444bbbbbbbbb33333300000000000000000000000000000000000000000000000000000000000000000000000000000000
69999996bbbbbbbb33833bbbbbb3b4444b3bbbbbbbb3383300000000000000000000000000000000000000000000000000000000000000000000000000000000
99999699bbb4bbbb3333bbbbbbbb344443bbbbbb3b3b333300000000000000000000000000000000000000000000000000000000000000000000000000000000
99969999b4bb4b4b4bbbbbbbbbbbbbbbbbbbbbbbb3bbbbb400000000000000000000000000000000000000000000000000000000000000000000000000000000
699999994bbbbbbb4bb3b3bbbbbbbbbbbbbbbbbbbbbbb3b400000000000000000000000000000000000000000000000000000000000000000000000000000000
99999699bb4b4bbb4bbb3bbbbbb3b3bbbbbbbbbbbbbbbb3400000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999bbbbbb4b4bbbbbbbbbbb3bbbbbb3bbbbbbbbbbb400000000000000000000000000000000000000000000000000000000000000000000000000000000
699699994bbbbbbb4bbbbbbbbbbbbbbb3b3bbbbbbbbbbbb400000000000000000000000000000000000000000000000000000000000000000000000000000000
99999996bbb4bb4b4bb3b3bbbbbbbbbbb3bbbbbbb3b3bbb400000000000000000000000000000000000000000000000000000000000000000000000000000000
99699999b4bbbbb44bbb3bbbbbbbbbbbbbbbbbbbbb3bbbb400000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000657585956575859565758595657585950400000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000667686966676869666768696667686960404040400000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000677787976777879767778797677787970000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000600000000000000000000000000040404040400000404040400000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000040404040000000004040400000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000400000000000700040000000000070000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000400000000000007000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000707000000000007070707000000000007000000000000000707000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020001000100010001000100000000020200000000000000000000000000020202020000000000000000000001000200000200000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4141414141414141414141414141414141414141414243444542434445424344454243444542434445424344454040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414141414141414141414141414141415253545552535455525354555253545552535455525354554040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4140404040404040404040404040000000004141416163646562636465626364656263646562636465626364654040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4140340000000000000000000000000000004141416173747572737475727374757273747572737475727374754040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4140404000000000000000000000000000004141414243444542434445424344454243444542434445424344454040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100000000000000000000000000000000004141415253545552535455525354555253545552535455525354554040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100000000000000000000000040400000004141416163646562636465626364656263646562636465626364654040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100000000000000000000000000000000004141416173747572737475727374757273747572737475727374754040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100004040000000000000000000000000004141416161616161616161616151616161616161616161616161610040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100000000000000000000000000000000000040406161616161616161616151616171717171717171716161610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100000000000000000000000000000000000040407171717171717171717151616171717171717171716161610000000000404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100000000000000000000000000000000000040407171717171717171717151717171716161616161717161610000000000404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4100004040000000000000000000000000004141417171717171717171717133717171616161616161717171610040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414141414141414141414141414141416161616161616161616151616161616161616161616171610000004040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414141414141414141414141414141416161616161616161616151616161616161616161616161610000404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000004040404040404647484950505050424344454243444542434445424344454243444542434445000040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000
000000000000000040404040405657585950506060525354555253545552535455525354555253545552535455000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000393a000000000000000000
000000000000000040404040404e4f4c4d505060606163646562636465626364656263646562636465626364650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000405e5f5c5d505060606173747572737475727374757273747572737475727374750000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000404647484950606060707046472f2f707070704e4f0000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000040565758595060606070705657484970704c4d5e5f0000404000000000000000000040404000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000004048494e4f5060606048497070585970705c5d70700000004000000000000000000000004040400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003900000000000000000000000000000000000000000000000000000000000000
0000000000000000000000004058595e5f506060605859704a4b7070704849707000000040000000000000000000000040400040400000000000000000000000000000000000000000000000000000000000000000003a0000000000000000000000000000000039000000000000000000000000000000000000000000000000
000000000000000000000000404c4d4a4b50606060704c4d5a5b704e4f585970700000004000000000000000000000000040000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000003900000000000000000000000000000000000000000000000000000000000000
000000000000000000000000405c5d5a5b50606060705c5d7070705e5f464770704040004000000000000000404040404040404000004040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000070707070506060504e4f707046477070565770704000404000000000000000000000004040404000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000
0000000000000000000000000070707070505050505e5f707056577070707070704040404040000000000000000000400000000000004040404040000000000000000000000000000000000000000000000000390000000000000000000000000000000000000000000000000000000000000000000000004040400000000000
0000000000000000000000000046474849505050507070707070707070707070700000404040000000000000000040000000000000004040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000056575859505050507070707070707070707070700000404000000000000040404040404040404040404040404040000000000000000000000000000000000000000000000000390000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000006667686940006000000040404000404040000000000000000000000040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000393a000000000000003900000000000000000000000000000000000000000000
0000000000000000000000000076777879404060404040404040000000000000000000000000004000404040404040404040404040404040400000000000000000404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000046474849464748494647484946474849000000000000000000000000000000000000000000000000000000000000000000000000404000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
