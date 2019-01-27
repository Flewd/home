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

friend={}
friend.spr=33
friend.distance=32
friend.x=30
friend.y=30
friend.spritewidth=1
friend.pullclose=false

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

function _init()
 setplayeranim(idleanim)
 createspike(21,8,21,14,1)
 createspike(22,12,28,12,1)

end

function _update60()
 animateplayer()
 playerinput()
 friendfollow()
 updatespikes()
 is_player_danger()
 if(player.invincible==true) then
    player.damagetimer-=1
    if(player.damagetimer<=0) then
        player.invincible = false;
    end
 end
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

function can_move(p,dif)

    spritewidth=p.spritewidth*8
    halfspritewidth=spritewidth/2

    top=(p.y + dif.y)
    left=(p.x + dif.x)
    right=(p.x + dif.x + spritewidth)
    bot=(p.y + dif.y + spritewidth)

    localdif={}
    localdif.x=dif.x
    localdif.y=dif.y

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

function is_position_wall(x,y)
 return fget( mget(x,y), 1 )
end


function is_player_danger()
    for s in all(spikes) do
        if is_collide(player,s) then
            receivedamageplayer()
        end
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

function is_collide(objA,objB)

    A={}
    A.x1=objA.x --top left
    A.y1=objA.y --top left
    A.x2=objA.x + (objA.spritewidth*8) --bot right
    A.y2=objA.y + (objA.spritewidth*8) --bot right

    B={}
    B.x1=objB.x --top left
    B.y1=objB.y --top left
    B.x2=objB.x + (objB.spritewidth*8) --bot right
    B.y2=objB.y + (objB.spritewidth*8) --bot right

    if(A.x1 > B.x2 or A.x2 < B.x1 or
       A.y1 > B.y2 or A.y2 < B.y1) then 
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
     else
        tempdif = can_move(friend,dif)
        if(tempdif.x != 0 or tempdif.y != 0) then
            friendclipping = false
            timesincemove=0
        end
        friend.x+=dif.x
        friend.y+=dif.y
    end
  end

end

function drawrope()
 line( friend.x + 4, friend.y + 4, player.x + 8, player.y + 8, 10 )
end

function drawfriend()
 spr(friend.spr,friend.x,friend.y)
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

function _draw()
 cls()
 camera(cam.x, cam.y)
 map(0, 0, 0, 0, 64, 32)
 drawshadow()
 drawspikes()
 drawrope()
 drawfriend()
 drawplayer()
 drawcrosshair()

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
00000000000000000000000000006000000bb0000008800000000000000000777777000000000077777700000000007777770000000000777777000000000000
00000000000011110000111100068600000bb0000008800000000000000000007000000000000000700000000000000070000000000000007000000000000000
00000000110b0001110b00010065856000bbbb000088880000000000000007007007000000000000700000000000070070070000000007007007000000000000
00000000001000010010000106888886bbb00bbb8880088800000000000007707077000000000000700000000000077070770000000007707077000000000000
00000000000811110008111100658560bbb00bbb8880088800000000000000777770000000000077777000000000007777700000000000777770000000000000
0000000000011110000111100006860000bbbb000088880000000000000000007000000000000770707700000000000070000000000000007000000000000000
00000000001000010010100000006000000bb0000008800000000000000000770770000000000707070700000000007707700000000000070770000000000000
00000000110000001100000000000000000bb0000008800000000000000000700070000000000077077000000000000000700000000000770000000000000000
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
969999963bbbbbbb33bbbbbbbbbbb4444bbbbbbb3bbbbb33777777773bbbbbbb11111111111116113bbbbbb4444444443bbbbbb4000000000000000000000000
99699969b3b3bbbb333bbbb3bbbbb4444bbbbbbbb3bbb33355555555b3b3bbbb1111111111111611b3b3bbb4b3b3bbb4b3b3bbb4000000000000000000000000
99969699bb3bb3b33833bbbbbbbbb4404bbbbbbbbbbb333377777777bb3bb3b31166666666666611bb3bb3b4bb3bb3b4bb3bb3b4000000000000000000000000
99996999bbbbbb3b33333bbbbbbbb4444bbbbbbbbbb3333357555755bbbbbb3b1161111111111111bbbbbb34bbbbbb34bbbbbb34000000000000000000000000
99669699b3bbbbbb33333b3bbbbbb4444bbbbbbb3b33383357555755b3bbbbbb1161111111111111b3bbbbb4b3bbbbb4b3bbbbb4000000000000000000000000
99699969bb3bb3bb383333b3bbbbb4444bbbbbbbbb33333377777777bb3bb3bb1161111111111111bb3bb3b4bb3bb3b4bb3bb3b4000000000000000000000000
66699966bbb33bbb333333bbbbbbb4444bbbbbbbbb33333355555555bbb33bbb1161116666111111bbb33bb4bbb33bb4bbb33bb4000000000000000000000000
69999996bbbbbbbb33833bbbbbb3b4444b3bbbbbbbb3383377777777bbbbbbbb6661116116666666bbbbbbb4bbbbbbb444444444000000000000000000000000
99999699bbb4bbbb3333bbbbbbbb344443bbbbbb3b3b3333777777773bbbbbbb66611161166666664bbbbbbb7575575700000000000000000000000000000000
99969999b4bb4b4b4bbbbbbbbbbbbbbbbbbbbbbbb3bbbbb475555555b3b3bbbb116111666611111143b3bbbb5575575700000000000000000000000000000000
699999994bbbbbbb4bb3b3bbbbbbbbbbbbbbbbbbbbbbb3b475777777bb3bb3b311611111111111114b3bb3b37777775700000000000000000000000000000000
99999699bb4b4bbb4bbb3bbbbbb3b3bbbbbbbbbbbbbbbb3475755755bbbbbb3b11611111111111114bbbbb3b5575575700000000000000000000000000000000
99999999bbbbbb4b4bbbbbbbbbbb3bbbbbb3bbbbbbbbbbb475755755b3bbbbbb116666666666661143bbbbbb5575575700000000000000000000000000000000
699699994bbbbbbb4bbbbbbbbbbbbbbb3b3bbbbbbbbbbbb475777777bb3bb3bb11111111111116114b3bb3bb7777775700000000000000000000000000000000
99999996bbb4bb4b4bb3b3bbbbbbbbbbb3bbbbbbb3b3bbb475755755bbb33bbb11111111111116114bb33bbb5555555700000000000000000000000000000000
99699999b4bbbbb444444444444444444444444444444444757557574444444411111111111116114bbbbbbb7777777700000000000000000000000000000000
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
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020202020201010101010101010101000002020202010101010101010101010000020202020002000000020200000001000202020200020000020000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
4141414141414141414141414141414141414141417a43444542434445424344454243444542434445424344454243444542434445424344454243444542434445404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000
4141414141414141414141414141414141414141417a53545552535455525354555253545552535455525354555253545552535455525354555253545552535455404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000
4168696869686968696869686968696869414141417a63646562636465626364656263646562636465626364656263646562636465626364656263646562636465404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000
4178797879787978797879787978797879414141417a73747572737475727374757273747572737475727374757273747572737475727374757273747572737475404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000
4168696869686968696869686968696869414141417a43444542434445424344454243444542434445424344454243444542434445424344454243444542434445404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000
4178797879787978797879787978797879414141417a53545552535455525354555253545552535455525354555253545552535455525354555253545552535455404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000
4168696869686968696869686968696869414141417a63646562636465626364656263646562636465626364656263646562636465626364656263646562636465404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000
4178797879787978797879787978797879414141417773747572737475727374757273747572737475727374757273747572737475727374757273747572737475404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000
41686968696869686968696869686968696869686951616161616161615161615161616161616161516161516161615161616161616a4344454243444542434445404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000
41787978797879787978797879787978797879787951616161616161615161615161717171717171517161516161615161616161616a5354555253545552535455404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000
4168696869686968696869686968696869686968695171717171717171517161516171716666666666666651666666516666666666666364656263646562636465404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000
41787978797879787978797879787978797879787951717171717171717666667b7171716666666651666666516666666666666666667374757273747572737475404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000
41414141414141414141414141414141414141414151666666666666665171717171716161616161517171715171716161615161616a4344454243444542434445404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000
41414141414141414141414141414141414141414151616161616161615161616161616161616161516161715171716161615161616a5354555253545552535455404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000
41414141414141414141414141414141414141414151616161616161615161616161616161616161516666666666666666665161616a6364656263646562636465404040404040404040404040404040404040404040404040000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000404040404040464748495050505042434445424344454243444542434445424344454243446b66666666667b61616a737475727374757273747500000000000000000000000000000000000000000000000000000000000000000000000000000000003a000000000000000000000000000000000000000000
00000000000000004040404040565758595050606052535455525354555253545552535455525354555253546a61617171716161616a434445424344450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000393a000000000000000000
000000000000000040404040404e4f4c4d5050606061636465626364656263646562636465626364656263646a61617171716161616a5354555253545500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000405e5f5c5d5050606061737475727374757273747572737475727374757273746a61617171716161616a6364656263646500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000404647484950606060707046477070707070704e4f00000000424344454243446b61616171717161616a7374757273747500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000040565758595060606070705657484970704c4d5e5f00004040525354555253546a6161616171717161616161616161616100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000004048494e4f5060606048497070585970705c5d707000000040626364656263646a6161616171717161616161616161616161000000000000000000000000000000000000000000000000000000000000000000003900000000000000000000000000000000000000000000000000000000000000
0000000000000000000000004058595e5f506060605859704a4b7070704849707000000040727374757273746c61616161717171716161616161616100000000000000000000000000000000000000000000000000003a0000000000000000000000000000000039000000000000000000000000000000000000000000000000
000000000000000000000000404c4d4a4b50606060704c4d5a5b704e4f585970700000004000000000000000006161616161617171616161616161610000000000000000000000000000000000000000000000000000000000000000000000003900000000000000000000000000000000000000000000000000000000000000
000000000000000000000000405c5d5a5b50606060705c5d7070705e5f464770704040004000000000000000406161616161617171004040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000070707070506060504e4f707046477070565770704000404000000000000000000000004061404000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000400000000000
0000000000000000000000000070707070505050505e5f707056577070707070704040404040000000000000000000400000000000004040404040000000000000000000000000000000000000000000000000390000000000000000000000000000000000000000000000000000000000000000000000004040400000000000
0000000000000000000000000046474849505050507070707070707070707070700000404040000000000000000040000000000000004040404040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000056575859505050507070707070707070707070700000404000000000000040404040404040404040404040404040000000000000000000000000000000000000000000000000390000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000006667686940006000000040404000404040000000000000000000000040404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000393a000000000000003900000000000000000000000000000000000000000000
0000000000000000000000000076777879404060404040404040000000000000000000000000004000404040404040404040404040404040400000000000000000404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000046474849464748494647484946474849000000000000000000000000000000000000000000000000000000000000000000000000404000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
