pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
cam={}
cam.x=0
cam.y=0
cam.speed=1

player={}
player.speed=1
player.x=40
player.y=40
player.spritewidth=2
player.facing=1

player.invincible=false
player.damagetimer=0
player.invincabletime=90

spikes={}

crosshair={}
crosshair.x=0
crosshair.y=0
crosshair.spr=52
crosshair.timer=0
crosshair.showtime=90

shadow={}
shadow.x=0
shadow.y=0
shadow.spr=47
shadow.show=false

throwing=false
throwingfriend=false
throwingme=false
throwingxdistance=0
throwingx=0
throwingy=0
throwingup=true

jumpdistance=40
damagedistance=10

friendclipping=false
timesincemove=0
clippingtimer=120

friendcatspr=29
friendfamilyspr=13
friendgoldspr=33

friend={}
friend.spr=33
friend.dmg=0
friend.health=2
friend.distance=32
friend.x=30
friend.y=30
friend.spritewidth=1
friend.pullclose=false

friend.invincible=false
friend.damagetimer=0
friend.invincabletime=90
friend.dead=false

friendfire={}
friendfire.spr=37
friendfire.timer=0
friendfire.framelength=10

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
walkanim.frameduration=2

currentanim={}

sandcoverspr=96
damagesand=112

tiles={}
tileid=0
function _init()
 setplayeranim(idleanim)
 --spike area 1:
 
createspike (21,7,21,12,.6)
createspike (28,7,28,9,.6)
createspike (34,7,34,14,.6)
createspike (26,14,34,14,.6)
createspike (25,14,25,18,.6)
createspike (18,18,25,18,.6)

--spike area 2:

--


createsandcover(10,6)

 friend.spr=friendfamilyspr
end

function _update60()
 animateplayer()
 if(friend.dead==false) then
    playerinput()
    friendfollow()
    updatespikes()
 end
 is_player_danger()
 is_friend_danger()
 is_on_tile()
 if(player.invincible==true) then
    player.damagetimer-=1
    if(player.damagetimer<=0) then
        player.invincible = false;
    end
 end

  if(friend.invincible==true) then
    friend.damagetimer-=1
    if(friend.damagetimer<=0) then
        friend.invincible = false;
    end
 end

end

function createsandcover(_x,_y)
    cover={}
    cover.x=_x*8
    cover.y=_y*8
    cover.spr=sandcoverspr
    cover.spritewidth=1
    cover.id=tileid
    add(tiles,cover)
    tileid+=1
end

function createspike(_startx, _starty, _endx, _endy, _speed)

 spike={}

 if(_startx == _endx) then 
  spike.dir="down"
 end

 if(_starty == _endy) then 
  spike.dir="right"
 end

 spike.spritewidth=1
 spike.spr=51
 spike.x=_startx*8
 spike.y=_starty*8
 spike.startx=_startx*8
 spike.starty=_starty*8
 spike.endx=_endx*8
 spike.endy=_endy*8
 spike.speed=_speed
 
 add(spikes,spike)
end

function playerinput()
 iswalking=false
 dif={}
 dif.x=0
 dif.y=0

if throwing==false then

 if (btn(0)) then
  dif.x-=player.speed
  iswalking=true
  player.facing=-1
 end

 if (btn(1)) then
  dif.x+=player.speed
  iswalking=true
  player.facing=1
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
  dif = can_move(player,dif)
  player.x+=dif.x
  player.y+=dif.y
 end
end -- end throwing

xcamright = 75
if(player.facing > 0) then
 xcamright = 40
end

xcamleft = 40
if(player.facing < 0) then
 xcamleft = 75
end


if player.x - cam.x > xcamright then
    cam.x+=cam.speed
end

if player.x - cam.x < xcamleft then
    cam.x-=cam.speed
end

if player.y - cam.y > 75 then
    cam.y+=cam.speed
end

if player.y - cam.y < 20 then
    cam.y-=cam.speed
end

    if (btn(4) and throwing==false) then
        throwingxdistance=jumpdistance
        crosshair.timer=crosshair.showtime
        crosshair.x=player.x + (throwingxdistance * player.facing)
        crosshair.y=player.y + ((player.spritewidth*8)/2)
        crosshair.spr=53
        if(can_throw(player) == true) then
            crosshair.spr=52
            throwing=true
            friend.pullclose=true
            throwingfriend=true
            throwingx=0
            throwingy=0
            throwingup=true
        end
    end

    if(btn(5)) then
        friend.pullclose=true
    end

    if(throwing==true and friend.pullclose==false) then
        execute_throwing(player.facing)
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

function execute_throwing(direction)

    if(throwingy >= 0) then
     shadow.show=false
    else
     shadow.show=true
    end

    if (throwingfriend) then
        if (throwingx < throwingxdistance) then
            friend.x+=2*direction
            shadow.x = friend.x
            throwingx+=2
        else 
            throwingfriend=false
        end

        if (throwingup == true) then
            friend.y-=1
            throwingy-=1
            if (throwingy<=-throwingxdistance/4) then
                throwingup=false
            end
        else 
            friend.y+=1
            throwingy+=1
            if(throwingy>=0) then
                throwingfriend=false
                throwingup=true
                throwingme=true
                throwingx=0
                shadow.y=player.y + ((player.spritewidth*8)/2)
            end
        end
    end


    if (throwingme) then
        if (throwingx < throwingxdistance) then
            player.x+=2*direction
            shadow.x = player.x
            throwingx+=2
        else 
            throwingme=false
        end

        if (throwingup == true) then
            player.y-=1
            throwingy-=1
            if (throwingy<=-throwingxdistance/4) then
                throwingup=false
            end
        else 
            player.y+=1
            throwingy+=1
            if(throwingy>=0) then
                --throwingup=true
                throwingfriend=false
                throwingme=false
                throwing=false
            end
        end
    end
end

function can_throw(p)
    iswall = is_position_wall( (p.x + (throwingxdistance * player.facing))/8, p.y/8 )
    if(iswall==true) then return false end
    return true
end

function can_move(p,_dif)

    spritewidth=p.spritewidth*8
    halfspritewidth=spritewidth/2

    localdif={}
    localdif.x=_dif.x
    localdif.y=_dif.y

    top=(p.y + localdif.y)
    left=(p.x + localdif.x)
    right=(p.x + localdif.x + spritewidth)
    bot=(p.y + localdif.y + spritewidth)

    --if(is_position_wall(left/8, top/8)==true) then end

    if(is_position_wall((left + halfspritewidth)/8, top/8)==true) then 
    localdif.y=0
    end

    --if(is_position_wall(left/8, bot/8)==true) then end

    if(is_position_wall((left + halfspritewidth)/8, bot/8)==true) then 
    localdif.y=0
    end

    --if(is_position_wall(right/8, top/8)==true) then end

    if(is_position_wall(left/8, (top + halfspritewidth)/8)==true) then 
    localdif.x=0 
    end

    --if(is_position_wall(right/8, bot/8)==true) then end

    if(is_position_wall(right/8, (bot - halfspritewidth)/8)==true) then 
    localdif.x=0
    end

    return localdif
end

function isfriendsand(p)

    spritewidth=p.spritewidth*8
    halfspritewidth=spritewidth/2

    top=(p.y)
    left=(p.x)
    right=(p.x + spritewidth)
    bot=(p.y + spritewidth)

        -- check for sand tiles
    if(is_position_sand((left + halfspritewidth)/8, top/8)==true) then 
     return true
    end

    if(is_position_sand((left + halfspritewidth)/8, bot/8)==true) then 
     return true
    end

    if(is_position_sand(left/8, (top + halfspritewidth)/8)==true) then 
     return true
    end

    if(is_position_sand(right/8, (bot - halfspritewidth)/8)==true) then 
     return true
    end

    return false
end

function is_position_wall(x,y)
 return fget( mget(x,y), 1 )
end

function is_position_sand(x,y)
 return fget( mget(x,y), 0 )
end


function is_player_danger()
    for s in all(spikes) do
        if is_collide(player,s) then
            receivedamageplayer()
        end
    end
end

function is_friend_danger()
    for s in all(spikes) do
        if is_collide(friend,s) then
            receivedamagefriend()
        end
    end
end

function is_on_tile()

    for t in all(tiles) do

        if is_collide(player,t) then
            if(t.spr == sandcoverspr) then
                t.spr = damagesand
            end
        end

        if is_collide(friend,t) then
            --working
            if(t.spr == sandcoverspr) then
                t.spr = damagesand
                friend.damagetimer = friend.invincabletime
            elseif(t.spr == damagesand) then
                receivedamagefriend()
            end
        end
    end

end

function receivedamagefriend()
    if(friend.invincible==false) then
        --shadow.y=friend.y + ((friend.spritewidth*8)/2)
        friend.invincible=true
        friend.damagetimer=friend.invincabletime
        friend.dmg+=1
    end
end

function receivedamageplayer()

    if(player.invincible==false) then
        shadow.y=player.y + ((player.spritewidth*8)/2)
        player.invincible=true
        player.damagetimer=player.invincabletime

        player.facing*=-1   --flip current facing direction
        throwingxdistance=damagedistance
        throwing=true
        throwingup=true
        throwingme=true
        throwingx=0
        throwingy=0
    end
end

function is_collide(obja,objb)

    a={}
    a.x1=obja.x --top left
    a.y1=obja.y --top left
    a.x2=obja.x + (obja.spritewidth*8) --bot right
    a.y2=obja.y + (obja.spritewidth*8) --bot right

    b={}
    b.x1=objb.x --top left
    b.y1=objb.y --top left
    b.x2=objb.x + (objb.spritewidth*8) --bot right
    b.y2=objb.y + (objb.spritewidth*8) --bot right

    if(a.x1 > b.x2 or a.x2 < b.x1 or
       a.y1 > b.y2 or a.y2 < b.y1) then 
        return false
    end

    return true

end

function drawplayer()
 spr(currentanim.spr,player.x,player.y)
 spr(currentanim.spr+1,player.x+8,player.y)
 spr(currentanim.spr+16,player.x,player.y+8)
 spr(currentanim.spr+17,player.x+8,player.y+8)
end

function friendfollow()
    timesincemove+=1
    
    if(timesincemove>clippingtimer) then
        friendclipping=true
    end

    xdir=player.x - friend.x
    ydir=player.y - friend.y

    dif.x=0
    dif.y=0

    if(friend.pullclose==true) then
        pulledclosed=false
        if(abs(xdir) > 8) then
            dif.x=(xdir/20)
            pulledclosed=true
        end
        if(abs(ydir) > 8) then
            dif.y=(ydir/20)
            pulledclosed=true
        end
        if pulledclosed==false then
            friend.pullclose=false
            shadow.y=friend.y + ((friend.spritewidth*8)/2)
        end

    else
        
        if(abs(xdir) > friend.distance) then
            dif.x=(xdir/60)
        end
        if(abs(ydir) > friend.distance) then
            dif.y=(ydir/60)
        end
    end

    if(dif.x!=0 or dif.y!=0) then
     if(friendclipping == false) then
        dif = can_move(friend,dif)
        if(dif.x!=0 or dif.y!=0) then
            timesincemove=0
        end
        friend.x+=dif.x
        friend.y+=dif.y
        if(isfriendsand(friend)) then 
            receivedamagefriend()
        end
     else
        tempdif = can_move(friend,dif)
        if(tempdif.x != 0 or tempdif.y != 0) then
            friendclipping = false
            timesincemove=0
        end
        friend.x+=dif.x
        friend.y+=dif.y
        if(isfriendsand(friend)) then 
            receivedamagefriend()
        end
        
    end
  end

end

function drawrope()
 line( friend.x + 4, friend.y + 4, player.x + 8, player.y + 8, 10 )
end

function drawfriend()
 if friend.dmg > friend.health then
    drawfriendfire(friend.x,friend.y)
 else
    spr(friend.spr+friend.dmg,friend.x,friend.y)
 end
end

function drawfriendfire(x,y)
 friend.dead=true
 friendfire.timer+=1
 if(friendfire.timer > friendfire.framelength) then
    friendfire.timer=0
    if(friendfire.spr == 38) then friendfire.spr = 37 
    elseif(friendfire.spr == 37) then friendfire.spr = 38 end
 end
  spr(friendfire.spr,x,y)
end

function drawcrosshair()
 if(crosshair.timer > 0) then
  spr(crosshair.spr,crosshair.x,crosshair.y)
  crosshair.timer-=1
 end
end

function drawshadow()
    if(shadow.show == true) then 
     spr(shadow.spr,shadow.x,shadow.y)
    end
end

function updatespikes()
    for s in all(spikes) do
        if(s.dir=="right") then
            s.x += s.speed
            if(s.x >= s.endx) then
                s.dir="left"
            end
        end

        if(s.dir=="left") then
            s.x -= s.speed
            if(s.x <= s.startx) then
                s.dir="right"
            end
        end

        if(s.dir=="up") then
            s.y -= s.speed
            if(s.y <= s.starty) then
                s.dir="down"
            end
        end

        if(s.dir=="down") then
            s.y += s.speed
            if(s.y >= s.endy) then
                s.dir="up"
            end
        end        
    end
end

function drawspikes()
    for s in all(spikes) do
        spr(s.spr,s.x,s.y)
    end
end

function drawtiles()
    for t in all(tiles) do
        spr(t.spr,t.x,t.y)
    end
end

function drawyoulose()
    rectfill( player.x-16, player.y-16-30, player.x+64, player.y-16, 1 )
    print("goodbye friend :(",player.x-8, player.y-32, 8)
end

function _draw()
 cls()
 camera(cam.x, cam.y)
 map(0, 0, 0, 0, 128, 32)
 drawshadow()
 drawspikes()
 drawtiles()
 drawrope()
 drawfriend()
 drawplayer()
 drawcrosshair()

 if friend.dead then drawyoulose() end

end

__gfx__
00000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc222222222222222222222222
00000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc277777722777777227777772
00000000cc777777777777cccc775777777757cccc775777777757cccc777777777777cccc777777777777cccc777557775577cc277777722777777227777772
00000000cc777557775577cccc777577777577cccc777577777577cccc777557775577cccc777557775577cccc775775757757cc277b7b722779797227787872
00000000cc775775757757cccc777757775777cccc777757775777cccc775775757757cccc775775757757cccc777777777777cc277777722777777227777772
00000000cc777997779977cccc777997779977cccc777997779977cccc777997779977cccc777997779977cccc777997779977cc278778722788887227788772
00000000cc777997779977cccc777997779977cccc777997779977cccc777997779977cccc777997779977cccc779779797797cc277887722777777227877872
00000000cc777997779977cccc777997779977cccc777997779977cccc777997779977cccc777997779977cccc777777777777cc222222222222222222222222
00000000cc777777777777cccc777777777777cccc777777777777cccc77c777777777cccc7777777777c7cccc777777777777cc00f00f0000f00f0000f00f00
00000000cc777777777777cccc777777777777cccc777777777777cccc77c777887777cccc7777778877c7cccc777888888777cc00ffff0000ffff0000ffff00
00000000cc777777777777cccc777777777777cccc777777777777cccc777777887777cccc777777887777cccc777788887777cc0fbfbff00f9f9ff00f8f8ff0
00000000cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc00ffff0000ffff0000ffff00
0000000000000cc00cc000000000cc000cc0000000000cc000cc000000000cc00cc0000000000cc00cc0000000000cc00cc00000000ff000000ff000000ff000
0000000000000cc00cc00000000cc000cc000000000000cc000cc00000000cc00cc0000000000cc00cc0000000000cc00cc0000000ffff0000ffff0000ffff00
0000000000000cc00cc0000000cc000cc00000000000000cc000cc0000000cc00cc0000000000cc00cc0000000000cc00cc000000fffff0f0fffff0f0fffff0f
0000000000000cc00cc000000cc000cc0000000000000000cc000cc000000cc00cc0000000000cc00cc0000000000cc00cc000000fbfbfff0f9f9fff0f8f8fff
0000000044000000440000004400000000000000000000000000a000000000777777000000000077777700000000007777770000000000777777000000000000
00000000440000004400000044000000000000000000a000000aaa00000000777777000000000077777700000000007777770000000000777777000000000000
0000000044000000440000004400000000000000000aaa0000aaaaa0000077777777770000007777777777000000777777777700000077777777770000000000
00000000440aaa0044000a00440000000000000000aaaaa000aa9aa0000077755755770000007775575577000000777877787700000077787778770000000000
000000000b4aaaa00940aaa008400aaa000000000aaaaaa00aa989aa000077755755770000007775575577000000777887887700000077788788770000000000
00000000004aaa40004aaa4a00400a4a00000000aa9999aaaa99899a000077777777770000007777777777000000777777777700000077777777770000555500
0000000000444440004444400044444a00000000a998899aa998889a000077775577770000007777557777000000777577577700000077757757770005555550
0000000000444440004444400044444a00000000a988889aa988888a000007757757700000000775775770000000077555577000000007755557700000555500
00000000000000000000000000006000000330000008800000000000000000777777000000000077777700000000007777770000000000777777000000000000
00000000000011110000111100068600000330000008800000000000000000007000000000000000700000000000000070000000000000007000000000000000
00000000110b0001110b000100658560003333000088880000000000000007007007000000000000700000000000070070070000000007007007000000000000
00000000001000010010000106888886333003338880088800000000000007707077000000000000700000000000077070770000000007707077000000000000
00000000000811110008111100658560333003338880088800000000000000777770000000000077777000000000007777700000000000777770000000000000
00000000000111100001111000068600003333000088880000000000000000007000000000000770707700000000000070000000000000007000000000000000
00000000001000010010100000006000000330000008800000000000000000770770000000000707070700000000007707700000000000070770000000000000
00000000110000001100000000000000000330000008800000000000000000700070000000000077077000000000000000700000000000770000000000000000
00000000444554444444444444433333333344444444444499999999999999999999999969999999999999999999999999999999999699999999999999999999
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
5999999975755757bbbbbbbbb333333333333bbbbbbbbbbb99999996bbbb99999999969999999969969999bbb999999999999999999999999969999999999999
9995995975777757bbbbbbbbb333333333333bbbbbbbbbbb9999999bbb99999999999999969999999999996b6999999999999999999999999999999999699999
9599999575755757bbbbbbbbbbbbb4444bbbbbbbbbbbbbbb99969999999999699699996999999999999999999999999999999999999999999999999999999999
969999963bbbbbbb33bbbbbbbbbbb4444bbbbbbb3bbbbb33777777773bbbbbbb11111111111116113bbbbbb4444444443bbbbbb4444444444444444400000000
99699969b3b3bbbb333bbbb3bbbbb4444bbbbbbbb3bbb33355555555b3b3bbbb1111111111111611b3b3bbb4b3b3bbb4b3b3bbb443b3bbbbb3b3bbb400000000
99969699bb3bb3b33833bbbbbbbbb4404bbbbbbbbbbb333377777777bb3bb3b31166666666666611bb3bb3b4bb3bb3b4bb3bb3b44b3bb3bbbb3bb3b400000000
99996999bbbbbb3b33333bbbbbbbb4444bbbbbbbbbb3333357555755bbbbbb3b1161111111111111bbbbbb34bbbbbb34bbbbbb344bbbbb3bbbbbbb3400000000
99669699b3bbbbbb33333b3bbbbbb4444bbbbbbb3b33383357555755b3bbbbbb1161111111111111b3bbbbb4b3bbbbb4b3bbbbb443bbbbbbb3bbbbb400000000
99699969bb3bb3bb383333b3bbbbb4444bbbbbbbbb33333377777777bb3bb3bb1161111111111111bb3bb3b4bb3bb3b4bb3bb3b44b3bb3bbbb3bb3b400000000
66699966bbb33bbb333333bbbbbbb4444bbbbbbbbb33333355555555bbb33bbb1161116666111111bbb33bb4bbb33bb4bbb33bb44bb33bbbbbb33bb400000000
69999996bbbbbbbb33833bbbbbb3b4444b3bbbbbbbb3383377777777bbbbbbbb6661116116666666bbbbbbb4bbbbbbb4444444444bbbbbbbbbbbbbb400000000
99999699bbb4bbbb3333bbbbbbbb344443bbbbbb3b3b3333777777773bbbbbbb66611161166666664bbbbbbb7575575744444444999996990000000000000000
99969999b4bb4b4b4bbbbbbbbbbbbbbbbbbbbbbbb3bbbbb475555555b3b3bbbb116111666611111143b3bbbb55755757b3b3bbbb999699990000000000000000
699999994bbbbbbb4bb3b3bbbbbbbbbbbbbbbbbbbbbbb3b475777777bb3bb3b311611111111111114b3bb3b377777757bb3bb3bb699999990000000000000000
99999699bb4b4bbb4bbb3bbbbbb3b3bbbbbbbbbbbbbbbb3475755755bbbbbb3b11611111111111114bbbbb3b55755757bbbbbb3b999996990000000000000000
99999999bbbbbb4b4bbbbbbbbbbb3bbbbbb3bbbbbbbbbbb475755755b3bbbbbb116666666666661143bbbbbb55755757b3bbbbbb999999990000000000000000
699699994bbbbbbb4bbbbbbbbbbbbbbb3b3bbbbbbbbbbbb475777777bb3bb3bb11111111111116114b3bb3bb77777757bb3bb3bb699699990000000000000000
99999996bbb4bb4b4bb3b3bbbbbbbbbbb3bbbbbbb3b3bbb475755755bbb33bbb11111111111116114bb33bbb55555557bbb33bbb999999960000000000000000
99699999b4bbbbb444444444444444444444444444444444757557574444444411111111111116114bbbbbbb77777777bbbbbbbb996999990000000000000000
00000000000000000000a735455525354555253545552535455525354555253545253545a62434445424344454243444e6c73444542434445424344454243444
542434445424344454243444542434445407070707c5d50765750705050505050505050505050505050505050505050505050505050505050707070707070707
00000000000000000000a736465626364656263646562636465626364656263646763646a62535455525354555253545a6253545552535455525354555253545
5525354555253545552535455525354555070707070707070707070505050505050505050505050507e4f4070505050505050505050707070707e4f407070707
07000000000000000000273747572737475727374757273747572737475727374777374757763646562636465626364656263646562636465626364656263646
562636465626364656263646562636465607070707070707a4b4070505050505050505050505050707e5f5070707070707070707070707070707e5f507070707
00000000000000000000000000000000000000040404040400000404040400000000000000273747572737475727374757273747572737475727374757273747
5727374757273747572737475727374757070707a4b40707a5b50705050505050505050505050707070707070707070707070707070707070707070707070707
07000000000000000000000000000000000000040404040000000000040400000000000000243444542434445424344454243444542434445424344454243444
5424344454243444542434445424344454070707a5b5070707070705050505050505050505070707849407070764740707070707070707070707070707070707
00000000000000000000000000000000000000000400000000000000040000000000000000253545552535455525354555253545552535455525354555253545
552535455525354555253545552535455507070707070707c4d40705050505050505050505070707859507070765750784940707647407070707070707070707
07000000000000000000000000000000000000000400000000000000000000000000000000263646562636465626364656263646562636465626364656263646
562636465626364656263646562636465607070707070707c5d50705050505050505050505070707070707070707070785950707657507070707070707070707
07000000000000000000000000000000000000000000000000000000000000000000000000273747572737475727374757273747572737475727374757273747
57273747572737475727374757273747570707070707070707070705050505050505050505070707070784940707070707070707070707070707070707070707
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000707070707070707c4d4070707070707050505050505050505070764740785950707070707070707070707070707070707070707
07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000070707070707070707c5d50707070707070505050505050505050707657507070707076474070707070707e4f40707070707070707
07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000707070707070707070707070707c4d4070707070505050505050707070707070707076575070707070707e5f50707070707070707
07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000707070707070707070707070707c5d507a4b4070505050505050707070707070707070707070707070707070707070707e4f40707
07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000707070707070707849407a4b407070707a5b5070705050505050707070784940707070707076474070707070707070707e5f50707
07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000707070707070707859507a5b507070707070707070505050505070707078595647407070707657507070764740707070707070707
07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000070707070707070707070707070707849407070707070505050505050707070707657507070707070707070765750707070707070707
07000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000007070707070707070707070707070785950707070707050505050505070707e4f40707070707e4f407070707070707070707e4f40707
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000007070707070707070707070707070707070707c4d407050505050505070707e5f50707070707e5f507070707070707070707e5f50707
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000007070707070707070707070707070707070707c5d5070505050505050507070707070707070707070707070707070707070707070707
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000070707070707070707078494070707070707070707070505050505050507070707071414141414141414141414141414141414141414
14000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000070707070707070707078595070707070707070707070505050505050505050707071414141414141414141414141414141414141414
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000070707070707070707070707070707070784940707070505050505050505050507071414141414141414141414141414141414141414
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000070707070707070707070707070707070785950707050505050505050505050507071414141414869686968696869686968696869614
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000007070707070707070707070707e4f4070707070707050505050505050505050505051414141414879787978797879787978797879714
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000007070707070707070707070707e5f5070707070707050505050505050505050505050586968696869686968696869686968696869614
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000070707e4f407070707070707070707070707070707070505050505050505050505050587978797879787978797879787978797879714
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000070707e5f507070707070707070707070707070707070705050505050505050505050586968696869686968696869686968696869614
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000070707070707070707070707070707070707a4b407070707070705050505050505050587978797879787978797879787978797879714
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000070707070707070707070707070707070707a5b507070707070707070707070707070714141414869686968696869686968696869614
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000070707070707070707070707070707070707070707070707070707070707070707070714141414879787978797879787978797879714
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000707070707070707070707070707070707070707a4b407070707e4f4070707a4b4070714141414869686968696869686968696869614
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000707070707070707070707070707070707070707a5b507070707e5f5070707a5b5070714141414141414141414141414141414141414
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000070707070707070707070707070707070707070707070707070707070707070707070714141414141414141414141414141414141414
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020201010101010101010101000002020202010101010101010101010000020202020002000002020202020001000202020200020000020000020000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4141414141414141414141414141414141414141417a434445424344454243444542434445424344454243444542434445424344454243444542434445424344454243444542434445427070707070707070707070707070704e4f70707070707070707070707070707070707070707070417070707070707070707070000000
4141414141414141414141414141414141414141417a535455525354555253545552535455525354555253545552535455525354555253545552535455525354555253545552535455525354557046477070707070707070705e5f70707070464770704849707070707070707070707070707070707070707070707000000000
4168696869686968696869686968696869414141417a63646562636465626364656263646562636465626364656263646562636465626364656263646562636465626364656263646562636470705657704c4d7070704647704a4b70484970565770705859704647707070707070707070707070707070707070707000000000
4178797879787978797879787978797879414141417a73747572737475727374757273747572737475727374757273747572737475727374757273747572737475727374757273747572737070707070705c5d7070705657705a5b70585970707070707070705657707070704849707070707070707070707070707000000000
4168696869686968696869686968696869414141417a434445424344454243444542434445424344454243444542434445424344454243444542434445424344454243446a6161615050616161707070707070707070707070707070707070704c4d464770704849707070705859704e4f707070707070704e4f707000000000
4178797879787978797879787978797879414141417a535455525354555253545552535455525354555253545552535455525354555253545552535455525354555253546a5061615061616150505050505050505050505050505050707070705c5d56577070585970704e4f7070705e5f707070707070705e5f707000000000
4168696869686968696869686968696869414141417a636465626364656263646562636465626364656263646562636465626364656263646562636465626364656263646a616171717171715050505050505050505050505050505050505050707070707070707070705e5f7070704e4f704849707070707070700000000000
417879787978797879787978797879787941414141517c7c7c7c7c7c517c7c7c7c7c517c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c7c6e73747572737475727374757273746c6171717171717150505050505050505050505050505050505050505050505050505050505070707070705e5f705859707070707070700000000000
4168696869686968696869686968696869686968695161616161616151616161616151616161616161616161616161616161616161617a434445434445424344454243446a7171717171717150505050505050505050505050505050505050505050505050505050505070707070464770707070707070707070700000000000
4178797879787978797879787978797879787978795161616161616151616161616151616161616161616161616161616161616161617a535455535455525354555253546a7171716161615050505050505050505050505050505050505050505050505050505050505050707070565770707070707070707070707000000000
4168696869686968696869686968696869686968695161616161616161616161616151616161616161616161616161616161616161617a636461636465626364656263646a7171615061617070704e4f707070707070505050505050505050505050505050505050505050707070707070707070707070707070700000000000
41787978797879787978797879787978797879787951616161616161616161616161516161616161616161616161616161616161616172737477737475727374757273746c717150506d437070705e5f70704a4b707070705050505050505050505050505050505050505070704c4d7070707046477070707070707000000000
4141414141414141414141414141414141414141415161616161616161616161616151616161616161616161616161616161616161616d434445424344454243444543446a717150617a53547d70707070705a5b707070707050505050505050505050505050505050505070705c5d70704e4f56577070707070007000000000
4141414141414141414141414141414141414141616161616161616161616161616151616161616161616161616161616161616161617a535455525354555253545553546a507150617a63647d7070707070707070707070707050505050505050505050505050505050507070464770705e5f70707070707070000000000000
414141414141414141414141414141414141416161616161617666666666666666667b616161616161616161616161616161616161617a636465626364656263646763646a61717161727374757070704849704647704e4f70707050505050505050505050505050505050707056577070707070707070707070000000000000
000000000000004040406d4344454243446a61616161616161516161616161616161616161616161616161616161616161616161616172737475727374757273746773746c617150617a4344457070705859705657705e5f70707050505050505050505050505050505050707070707070704647707070707070000000000000
000000000000000040407a5354555253546a61616161616161516161616161616161616161616161616161616161616161616161616a43444542434445424344454243446a676171717a535455707070707070707070707070707070707070705050505050505050505050707070707070705657707070707070707070707070
000000000000000040407a6364656263646a61616161616161516161616161616161616161616161616161616161616161616161616a53545552535455525354555253546a505071717a637d7d70484970707070707070707070704647707070707070707050505050505070704c4d7070707070707070707070707070707070
000000000000000000007273747572737475666666666666667b6161616161616161616161616161616161616161616161616161616a63646562636465626364656263646a676171507273747570585970707048497070464770705657707070704e4f707050505050505050705c5d7070707070707070707070707070707070
000000000000000000006d4344454243446a61616161616161616161616161616161616161616161616161616161616161616161616a73747572737475727374757273746c676171717a43444570704647707058597070565770707070704849705e5f7070705050505050507070707070704849707070707070707070707070
000000000000000000007a5354555253546a616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161675050617d535455707056577070707070707070707070707058597070707070705050505050507070707070705859707070707070707070707070
000000000000000000007a6364656263646a676161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161617171617a63647d70707070707046477070704c4d707070707070704c4d70707070505050505070707046477070707070704e4f70707070707070
0000000000000000000072737475727374756761616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161617171716172737d7570704849707056577070705c5d70704a4b7070705c5d70707070505050505070707056577070707070705e5f70707070707070
000000000000000000006d4344454243446a676161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161617a4344457070585970707070707070464770705a5b70707070707070705050505050507070707070707070707070707070707070707070
000000000000000000007a5354555253546a676761616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161617a53545570707070707070707070705657707070707070707070707050505050505050704a4b4849704647707070707070707070707070
000000000000000000007a6364656263646a676761616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161617a63647d46477070707070484970707070707070707070707050505050505050505070705a5b5859705657707070707070505050707070
000000000000000000007273747572737475676767676767616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161617a737475565770707070705859707070707050505050505050505050505050505050707070707070707070707070505050505050707070
000000000000000000006d4344454243444542434445424344454243446b616161616161616161616161616161616161616161616161616161616161616161616161616161616161617a4344454243444570707070707070704a4b50505050505050505050505050505050505050505070707070505050505050505050707070
000000000000000000007a5354555253545552535455525354555253546a616161616161616161616161616161616161616161616161616161616161616161616161616161616161617a5354555253545570704a4b707070705a5b50505050505050505050505050505050505050505050505050505050505050505050707070
000000000000000000007a6364656263646562636465626364656263646a616161616161616161616161616161616161616161616161616161616161616161616161616161616161617a6364656263646570705a5b70707070707050505050505050505050505050505050505050505050505050505050505050505070707070
0000000000000000000072737475727374757273747572737475727374756161616161616161616161616161616161616161616161616161616161616767676161616167676767676772737475727374757070707070707070707050505050505050505050505050505050505050505050505050505050505050707070707070
000000000000000000006d434445424344454243444542434445424344454243444243446b6161616161616161616161616161616161616161616161616161616161616161616161617a67676767676767707070704c4d7046477050505050505050505050505050505050505050505050505050505050505050707070707070
