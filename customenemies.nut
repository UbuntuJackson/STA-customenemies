//This file is for testing mod support.
//Mods will be loaded after all core game files are loaded.

//Uncomment this next line to activate this mod
//replaceSprite(sprTux, "mods/gfx/tux.png", 32, 32, 0, 0, 15, 19)

::sprJumpy <- newSprite("mods/gfx/Jumpy.png", 18, 22, 0, 0, 8, 8)
::sprUFO <- newSprite("mods/gfx/ufo.png", 32, 16, 0, 0, 16, 8)
::sprCychin <- newSprite("mods/gfx/cychin.png", 16, 16, 0, 0, 8, 8)
::sprAntiJumpy <-newSprite("mods/gfx/AntiJumpy.png", 18, 22, 0, 0, 8, 8)
::sprRedCoin <- newSprite("mods/gfx/redcoin.png", 16, 16, 0, 0, 8, 8)
::sprIceCrusher <- newSprite("mods/gfx/icecrusherrealv2.png", 32, 32, 0, 0, 16, 16)

/*::Enemy <- class extends PhysAct {
	health = 1
	hspeed = 0.0
	vspeed = 0.0
	active = false
	frozen = 0
	icebox = -1
	nocount = false //If enemy is exempt from completion tracking
    freezable = true

	function run() {
		base.run()
		//Collision with player
		if(active) {
			if(gvPlayer != 0) {
				if(hitTest(shape, gvPlayer.shape) && !frozen) { //8 for player radius
					if(gvPlayer.invincible > 0) hurtinvinc()
					else if(y > gvPlayer.y && vspeed < gvPlayer.vspeed && gvPlayer.canstomp) gethurt()
					else if(gvPlayer.rawin("anSlide")) {
						if(gvPlayer.anim == gvPlayer.anSlide) gethurt()
						else hurtplayer()
					}
					else hurtplayer()
				}
			}

			//Collision with fireball
			if(actor.rawin("Fireball")) foreach(i in actor["Fireball"]) {
				if(hitTest(shape, i.shape)) {
					hurtfire()
					deleteActor(i.id)
				}
			}
			if(actor.rawin("BadExplode")) foreach(i in actor["BadExplode"]) {
				if(hitTest(shape, i.shape)) {
					hurtfire()
					deleteActor(i.id)
				}
			}
			if(actor.rawin("FlameBreath")) foreach(i in actor["FlameBreath"]) {
				if(hitTest(shape, i.shape)) {
					hurtfire()
					deleteActor(i.id)
				}
			}
			if(actor.rawin("Iceball")) foreach(i in actor["Iceball"]) {
				if(hitTest(shape, i.shape)) {
					hurtice()
					deleteActor(i.id)
				}
			}
		}
		else {
			if(distance2(x, y, camx + (screenW() / 2), camy + (screenH() / 2)) <= 180) active = true
		}

		if(active && frozen > 0) {
			frozen--
			if(getFrames() % 15 == 0) {
				newActor(Glimmer, shape.x - (shape.w + 4) + randInt((shape.w * 2) + 8), shape.y - (shape.h + 4) + randInt((shape.h * 2) + 8))
				if(randInt(50) % 2 == 0) newActor(Glimmer, shape.x - (shape.w + 4) + randInt((shape.w * 2) + 8), shape.y - (shape.h + 4) + randInt((shape.h * 2) + 8))
			}

			//Shatter when slid into while frozen
			if(gvPlayer.rawin("anSlide")) {
				if(gvPlayer.anim == gvPlayer.anSlide) {
					shape.setPos(x - 2, y)
					if(hitTest(shape, gvPlayer.shape) && gvPlayer.hspeed >= 1) {
						frozen = 0
						gethurt()
						mapDeleteSolid(icebox)
					}
					shape.setPos(x + 2, y)
					if(hitTest(shape, gvPlayer.shape) && gvPlayer.hspeed <= -1) {
						frozen = 0
						gethurt()
						mapDeleteSolid(icebox)
					}
					shape.setPos(x, y)
				}
			}
		}
	}

	function gethurt() {} //Spiked enemies can just call hurtplayer() here

	function hurtplayer() { //Default player damage
		if(gvPlayer.blinking > 0) return
		if(gvPlayer.x < x) gvPlayer.hspeed = -1.0
		else gvPlayer.hspeed = 1.0
		gvPlayer.hurt = true
	}

	function hurtfire() {} //If the object is hit by a fireball
	function hurtice() {if(freezable == true) frozen = 600 }

	function hurtinvinc() {
		newActor(Poof, x, y)
		deleteActor(id)
		playSound(sndFlame, 0)
		if(!nocount) game.enemies--
	}

	function _typeof() { return "Enemy" }
}*/

::TNT <- class extends Actor {
	shape = null
	gothit = false
	hittime = 0.0
	frame = 0.0
	fireshape = null

	constructor(_x, _y, _arr = null) {
		base.constructor(_x, _y)

		shape = Rec(x, y, 10, 10, 0)
		tileSetSolid(x, y, 1)
		fireshape = Rec(x, y, 14, 12, 0)
	}

	function run() {
		if(gothit) {
			hittime += 2
			frame += 0.002 * hittime
			if(hittime >= 150) {
				tileSetSolid(x, y, 0)
				deleteActor(id)
				newActor(BadExplode, x, y)
			}
		}
		else {
			//Hit by player
			if(gvPlayer) if(hitTest(shape, gvPlayer.shape)) {
				gothit = true
				stopSound(2)
				playSoundChannel(sndFizz, 0, 2)
			}
		}

		if(actor.rawin("Fireball")) foreach(i in actor["Fireball"]) if(hitTest(fireshape, i.shape)) {
			tileSetSolid(x, y, 0)
			deleteActor(id)
			newActor(BadExplode, x, y)
			deleteActor(i.id)
		}

        if(actor.rawin("IceCrusher")) foreach(i in actor["IceCrusher"]) if(hitTest(fireshape, i.shape)) {
			tileSetSolid(x, y, 0)
			deleteActor(id)
			newActor(BadExplode, x, y)
			deleteActor(i.id)
		}

		if(gothit) {
			if(hittime > 120) drawSpriteExZ(2, sprTNT, frame, x - 8 - camx + ((randInt(8) - 4) / 4) - ((2.0 / 150.0) * hittime), y - 8 - camy + ((randInt(8) - 4) / 4) - ((2.0 / 150.0) * hittime), 0, 0, 1.0 + ((0.25 / 150.0) * hittime), 1.0 + ((0.25 / 150.0) * hittime), 1)
			else drawSpriteZ(2, sprTNT, frame, x - 8 - camx + ((randInt(8) - 4) / 4), y - 8 - camy + ((randInt(8) - 4) / 4))
		}
		else drawSpriteZ(2, sprTNT, frame, x - 8 - camx, y - 8 - camy)
	}

	function _typeof() { return "TNT" }
}

::WoodBlock <- class extends Actor {
	shape = 0
	slideshape = 0
	coins = 0
	v = 0.0
	vspeed = 0
    fireshape = null

	constructor(_x, _y, _arr = null) {
		base.constructor(_x, _y)
		tileSetSolid(x, y, 1)

		shape = Rec(x, y + 2, 8, 8, 0)
		slideshape = Rec(x, y - 1, 16, 8, 0)
        fireshape = Rec(x, y, 14, 16, 0)
		if(_arr != null && _arr != "") coins = _arr.tointeger()
		game.maxcoins += coins
	}

	function run() {
		if(gvPlayer) {
			if(v == 0) {
				vspeed = 0
				if(coins <= 1) {
					if(gvPlayer.vspeed < 0) if(hitTest(shape, gvPlayer.shape)) {
						gvPlayer.vspeed = 0
						deleteActor(id)
						newActor(WoodChunks, x, y)
						playSoundChannel(sndBump, 0, 2)
						tileSetSolid(x, y, 0)
						if(coins > 0) newActor(CoinEffect, x, y - 16)
					}

					if(gvPlayer.rawin("anSlide")) if(abs(gvPlayer.hspeed) >= 3.5 && gvPlayer.anim == gvPlayer.anSlide) if(hitTest(slideshape, gvPlayer.shape)) {
						gvPlayer.vspeed = 0
						deleteActor(id)
						newActor(WoodChunks, x, y)
						playSoundChannel(sndBump, 0, 2)
						tileSetSolid(x, y, 0)
						if(coins > 0) newActor(CoinEffect, x, y - 16)
					}

                    if(actor.rawin("IceCrusher")) foreach(i in actor["IceCrusher"]) if(hitTest(fireshape, i.shape)) {
                        gvPlayer.vspeed = -2
						deleteActor(id)
						newActor(WoodChunks, x, y)
						playSoundChannel(sndBump, 0, 2)
						tileSetSolid(x, y, 0)
						if(coins > 0) newActor(CoinEffect, x, y - 16)
		            }

                    
				}
				else {
					if(gvPlayer.vspeed < 0) if(hitTest(shape, gvPlayer.shape)) {
						vspeed = -2
						coins--
						newActor(CoinEffect, x, y - 16)
						playSoundChannel(sndBump, 0, 2)
					}

					if(gvPlayer.rawin("anSlide")) if((abs(gvPlayer.hspeed) >= 3.5 || (game.weapon == 4 && gvPlayer.vspeed >= 2)) && gvPlayer.anim == gvPlayer.anSlide) if(hitTest(slideshape, gvPlayer.shape)) {
						vspeed = -2
						coins--
						newActor(CoinEffect, x, y - 16)
						playSoundChannel(sndBump, 0, 2)
					}
				}
			}
		}

		if(v == -8) vspeed = 1
		v += vspeed

		drawSpriteZ(2, sprWoodBox, 0, x - 8 - camx, y - 8 - camy + v)
	}

	function _typeof() { return "WoodBlock" }
}

::IceCrusher <- class extends Enemy {
	timer = 30
	counting = false
    rising = false
    xstart = 0.0
    ystart = 0.0
    crushing = false
    solidx = []

	constructor(_x, _y, _arr = null) {
		base.constructor(_x, _y)
        xstart = _x
        ystart = _y
        shape = Rec(x, y, 14, 14, 0)
        //solidx = [tileSetSolid(x, y-8, 39)]
	}

	function run() {
		base.run()
        //solidx[0].y = y
		if(gvPlayer) if(abs(y - gvPlayer.y) < 150 && y < gvPlayer.y && abs(x - gvPlayer.x) < 16 && !counting) {
			counting = true
			playSound(sndIcicle, 0)
		}

		if(counting && timer > 0) timer--
		if(timer <= 0 && placeFree(x, y + vspeed)) {
			if(inWater(x, y) && vspeed < 1.0){
                vspeed += 0.05
            }
			else{
                crushing = true
                vspeed += 0.1
            }
		}
		if(inWater(x, y) && vspeed > 0.5) vspeed = 0.1
		y += vspeed
		shape.setPos(x, y)

        if(rising == false){
            if(!placeFree(x, y + vspeed)) {
                vspeed = 0
                rising = true
                timer = 30
                crushing = false
            }
        }

        if(rising){
            if(y > ystart){
                vspeed = -0.5
                counting = false
            }
            else{
                rising = false
                //timer = 30
            }
        }
        else if(crushing == false){
            vspeed = 0
        }

        /*if(actor.rawin("IceCrusher")) foreach(i in actor["IceCrusher"]) if(hitTest(WoodBlock.fireshape, i.shape)) {
			tileSetSolid(x, y, 0)
			deleteActor(id)
			newActor(BadExplode, x, y)
			deleteActor(i.id)
		}*/

		drawSprite(sprIceCrusher, 0, x + (timer % 2) - camx, y - camy)

        shape.setPos(x, y)
        setDrawColor(0xff0000ff)
        if(debug) shape.draw()
	}
    
	function hurtfire() {
		deleteActor(id)
		newActor(Poof, x, y)
	}

    function _typeof() {return "IceCrusher"}
}

::Jumpy <- class extends Enemy {
	frame = 0.0
	flip = false
	squish = false
	squishTime = 0.0
	smart = false

	constructor(_x, _y, _arr = null) {
		base.constructor(_x.tofloat(), _y.tofloat())
		shape = Rec(x, y, 6, 6, 0)

		vspeed = -3
	}

	function run() {
		base.run()

		if(active) {
			if(gvPlayer != 0 && hspeed == 0) {
				if(x > gvPlayer.x) hspeed = -0.0
				else hspeed = 0.0
			}

			if(!placeFree(x, y + 1)) vspeed = -3.35
			if(!placeFree(x + 0, y - 2) && !placeFree(x + 2, y)) hspeed = 0
			if(!placeFree(x - 0, y - 2) && !placeFree(x - 2, y)) hspeed = 0
            vspeed += 0.085
			

			if(gvPlayer != 0) if(gvPlayer.x > x) flip = 0
			else flip = 1

			if(!frozen) {
				if(placeFree(x + hspeed, y)) x += hspeed
				if(placeFree(x, y + vspeed)) y += vspeed
				else vspeed /= 2
			}

			shape.setPos(x, y)

			//Draw
			drawSpriteEx(sprJumpy, getFrames() / 8, floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)

			if(frozen) {
				//Create ice block
				if(gvPlayer != 0) if(icebox == -1 && !hitTest(shape, gvPlayer.shape)) {
					icebox = mapNewSolid(shape)
				}

				//Draw
				drawSpriteEx(sprJumpy, 0, floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)

				if(frozen <= 120) {
				if(floor(frozen / 4) % 2 == 0) drawSprite(sprIceTrapSmall, 0, x - camx - 1 + ((floor(frozen / 4) % 4 == 0).tointeger() * 2), y - camy - 1)
					else drawSprite(sprIceTrapSmall, 0, x - camx, y - camy - 1)
				}
				else drawSprite(sprIceTrapSmall, 0, x - camx, y - camy - 1)
			}
			else {
				//Delete ice block
				if(icebox != -1) {
					mapDeleteSolid(icebox)
					newActor(IceChunks, x, y)
					icebox = -1
					if(gvPlayer != 0) if(x > gvPlayer.x) flip = true
					else flip = false
				}
			}
		}

		if(x < 0) hspeed = 0.0
		if(x > gvMap.w) hspeed = -0.0
	}

	function gethurt() {
	    gvPlayer.hurt = true
	}

	function hurtfire() {
		newActor(Flame, x, y - 1)
		deleteActor(id)
		playSound(sndFlame, 0)
		if(!nocount) game.enemies--
	}
}

::UFO <- class extends Enemy {
	frame = 0.0
	flip = false
	squish = false
	squishTime = 0.0
	smart = false
	moving = false
    timer = 240
    dive = false
    dive_timer = 100

	constructor(_x, _y, _arr = null) {
		base.constructor(_x.tofloat(), _y.tofloat())
		shape = Rec(x, y, 12, 6, 0)

		smart = _arr
	}

	function run() {
		base.run()

        
        if(active) {
            if(!moving) if(gvPlayer != 0) if(x > gvPlayer.x) {
                flip = true
                moving = true
            }

            if(!squish) {
                if(gvPlayer != 0){
                    //if(placeFree(x, y + 1)) vspeed += 0
                    //if(placeFree(x, y + vspeed)) y += vspeed
                    //else vspeed /= 2

                    //if(y > gvMap.h + 8) deleteActor(id)

                    if(!frozen) {
                        if(gvPlayer != 0){
                            //if(y < 100) dive = false
                            if(dive == true){
                                vspeed = vspeed - 0.05
                                y = y + vspeed
                                if(y <= gvPlayer.y - 75) dive = false
                                if(x != gvPlayer.x) {
                                    x = x + ((gvPlayer.x - x) / 4.5)
                                }
                            }
                            else{
                                if(y != gvPlayer.y - 75) y = y + ((gvPlayer.y - y - 75) / 40)
                                if(x != gvPlayer.x) {
                                    x = x + ((gvPlayer.x - x) / 40)
                                }
                            }
                        }
                        if (timer == 0) {
                            timer = 240
                            vspeed
                            newActor(UfoPearl, x, y, null)
                        }
                        if(dive_timer <= 0){
                            dive = true
                            dive_timer = 500
                            vspeed = 3
                        }
                        if(timer > 0) timer--
                        if(dive_timer > 0) dive_timer--

                        


                        //if(x > gvPlayer.x) x = x + (gvPlayer.x - x) / 50
                        //x = x + (gvPlayer.x - x) / 100
                        //(gvPlayer.x - x) / 2

                        /*if(flip) {
                            if(placeFree(x - 0.5, y)) x -= 0.5
                            else if(placeFree(x - 1.1, y - 0.5)) {
                                x -= 0.5
                                y -= 0.25
                            } else if(placeFree(x - 1.1, y - 1.0)) {
                                x -= 0.5
                                y -= 0.5
                            } else flip = false
                            /*
                            There's a simpler way to do this in theory,
                            but it doesn't work in practice.
                            It should be this:

                            else if(placeFree(x - 1.0, y - 1.0)) {
                                x -= 1.0
                                y -= 1.0
                            }

                            But for whatever reason, this prevents any
                            movement over a slope that looks like \_.
                            Instead, they just turn around when they reach
                            the bottom of a slope facing right.

                            This weird trick of checking twice ahead works,
                            though. Credit to Admiral Spraker for giving me
                            the idea. Another fine example of (/d/d/d).
                            */

                        /*	if(smart) if(placeFree(x - 6, y + 12)) flip = false

                            if(x <= 0) flip = false
                        }
                        else {
                            if(placeFree(x + 1, y)) x += 0.5
                            else if(placeFree(x + 1.1, y - 0.5)) {
                                x += 0.5
                                y -= 0.25
                            } else if(placeFree(x + 1.1, y - 1.0)) {
                                x += 0.5
                                y -= 0.5
                            } else flip = true

                            if(smart) if(placeFree(x + 6, y + 12)) flip = true

                            if(x >= gvMap.w) flip = true
                        }*/
                    }
                }
                if(frozen) {
                    //Create ice block
                    if(gvPlayer != 0) if(icebox == -1 && !hitTest(shape, gvPlayer.shape)) {
                        icebox = mapNewSolid(shape)
                    }

                    //Draw
                    if(smart) drawSpriteEx(sprGradcap, 0, floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)
                    else drawSpriteEx(sprDeathcap, 0, floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)

                    if(frozen <= 120) {
                    if(floor(frozen / 4) % 2 == 0) drawSprite(sprIceTrapSmall, 0, x - camx - 1 + ((floor(frozen / 4) % 4 == 0).tointeger() * 2), y - camy - 1)
                        else drawSprite(sprIceTrapSmall, 0, x - camx, y - camy - 1)
                    }
                    else drawSprite(sprIceTrapSmall, 0, x - camx, y - camy - 1)
                }
                else {
                    //Delete ice block
                    if(icebox != -1) {
                        mapDeleteSolid(icebox)
                        newActor(IceChunks, x, y)
                        icebox = -1
                        if(gvPlayer != 0) if(x > gvPlayer.x) flip = true
                        else flip = false
                    }

                    //Draw
                    if(smart) drawSpriteEx(sprGradcap, wrap(getFrames() / 12, 0, 3), floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)
                    else drawSpriteEx(sprUFO, wrap(getFrames() / 12, 0, 8), floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)
                }
            }
            else {
                squishTime += 0.025
                if(squishTime >= 1) deleteActor(id)
                if(smart) drawSpriteEx(sprDeathcap, floor(4.8 + squishTime), floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)
                else drawSpriteEx(sprDeathcap, floor(4.8 + squishTime), floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)
            }

            shape.setPos(x, y)
            setDrawColor(0xff0000ff)
            if(debug) shape.draw()
        }
	}

	function hurtplayer() {
		if(squish) return
		base.hurtplayer()
	}

	function gethurt() {
		//if(squish) return
		if(!nocount) game.enemies--

		/*if(gvPlayer.rawin("anSlide")) {
			if(gvPlayer.anim == gvPlayer.anSlide) {
				local c = newActor(DeadNME, x, y)
				actor[c].sprite = sprDeathcap
				actor[c].vspeed = -abs(gvPlayer.hspeed * 1.1)
				actor[c].hspeed = (gvPlayer.hspeed / 16)
				actor[c].spin = (gvPlayer.hspeed * 6)
				actor[c].angle = 180
				deleteActor(id)
				playSound(sndKick, 0)
			}
			else if(getcon("jump", "hold")) gvPlayer.vspeed = -5
			else {
				gvPlayer.vspeed = -2
				playSound(sndSquish, 0)
			}
			if(gvPlayer.anim == gvPlayer.anJumpT || gvPlayer.anim == gvPlayer.anFall) {
				gvPlayer.anim = gvPlayer.anJumpU
				gvPlayer.frame = gvPlayer.anJumpU[0]
			}
		}
		else if(keyDown(config.key.jump)) gvPlayer.vspeed = -5
		else gvPlayer.vspeed = -2
		if(gvPlayer.anim == gvPlayer.anJumpT || gvPlayer.anim == gvPlayer.anFall) {
			gvPlayer.anim = gvPlayer.anJumpU
			gvPlayer.frame = gvPlayer.anJumpU[0]
		}*/

		//squish = true
	}

	function hurtfire() {
		newActor(Flame, x, y - 1)
		deleteActor(id)
		playSound(sndFlame, 0)
		if(!nocount) game.enemies--
		if(randInt(20) == 0) {
			local a = actor[newActor(MuffinBlue, x, y)]
			a.vspeed = -2
		}
	}

	function _typeof() { return "UFO" }
}

::UfoPearl <- class extends PhysAct {
	hspeed = 0
	vspeed = 0
	timer = 1200
	shape = null

	constructor(_x, _y, _arr = null) {
		base.constructor(_x, _y)

		if(gvPlayer == 0) {
			deleteActor(id)
			return
		}

        if(gvPlayer != 0)
            local aim = pointAngle(x, y, gvPlayer.x, gvPlayer.y)
            hspeed = lendirX(3, aim)
            vspeed = lendirY(3, aim)

		shape = Rec(x, y, 4, 4, 0)
	}

	function run() {
		x += hspeed
		y += vspeed
		shape.setPos(x, y)
		timer--

		if(timer == 0 || !placeFree(x, y)) deleteActor(id)

		if(gvPlayer != 0) if(hitTest(shape, gvPlayer.shape)) gvPlayer.hurt = true

		drawSprite(sprIceball, 0, x - camx, y - camy)
	}
}

::RotDeathcap <- class extends Enemy {
	frame = 0.0
	flip = false
	squish = false
	squishTime = 0.0
	smart = false
	moving = false
    angle = 0
    r = 40
    
	constructor(_x, _y, _arr = null) {
		base.constructor(_x.tofloat(), _y.tofloat())
		shape = Rec(x, y, 4, 6, 0)

		smart = _arr
	}

	function run() {
		base.run()

		if(active) {
			if(!moving) if(gvPlayer != 0) if(x > gvPlayer.x) {
				flip = true
				moving = true
			}

			if(!squish) {
                
                x = xstart + r * sin(angle)
                y = ystart + r * cos(angle)
                angle += 0.02
				/*if(placeFree(x, y + 1)) vspeed += 0.1
				if(placeFree(x, y + vspeed)) y += vspeed
				else vspeed /= 2

				if(y > gvMap.h + 8) deleteActor(id)

				if(!frozen) {
					if(flip) {
						if(placeFree(x - 0.5, y)) x -= 0.5
						else if(placeFree(x - 1.1, y - 0.5)) {
							x -= 0.5
							y -= 0.25
						} else if(placeFree(x - 1.1, y - 1.0)) {
							x -= 0.5
							y -= 0.5
						} else flip = false
						
						if(smart) if(placeFree(x - 6, y + 12)) flip = false

						if(x <= 0) flip = false
					}
					else {
						if(placeFree(x + 1, y)) x += 0.5
						else if(placeFree(x + 1.1, y - 0.5)) {
							x += 0.5
							y -= sin(x)
						} else if(placeFree(x + 1.1, y - 1.0)) {
							x += 0.5
							y -= sin(x)
						} else flip = true

						if(smart) if(placeFree(x + 6, y + 12)) flip = true
                        
						if(x >= gvMap.w) flip = true
					}
				}*/

				if(frozen) {
					//Create ice block
					if(gvPlayer != 0) if(icebox == -1 && !hitTest(shape, gvPlayer.shape)) {
						icebox = mapNewSolid(shape)
					}

					//Draw
					if(smart) drawSpriteEx(sprGradcap, 0, floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)
					else drawSpriteEx(sprDeathcap, 0, floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)

					if(frozen <= 120) {
					if(floor(frozen / 4) % 2 == 0) drawSprite(sprIceTrapSmall, 0, x - camx - 1 + ((floor(frozen / 4) % 4 == 0).tointeger() * 2), y - camy - 1)
						else drawSprite(sprIceTrapSmall, 0, x - camx, y - camy - 1)
					}
					else drawSprite(sprIceTrapSmall, 0, x - camx, y - camy - 1)
				}
				else {
					//Delete ice block
					if(icebox != -1) {
						mapDeleteSolid(icebox)
						newActor(IceChunks, x, y)
						icebox = -1
						if(gvPlayer != 0) if(x > gvPlayer.x) flip = true
						else flip = false
					}

					//Draw
					if(smart) drawSpriteEx(sprGradcap, wrap(getFrames() / 12, 0, 3), floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)
					else drawSpriteEx(sprDeathcap, wrap(getFrames() / 12, 0, 3), floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)
				}
			}
			else {
				squishTime += 0.025
				if(squishTime >= 1) deleteActor(id)
				if(smart) drawSpriteEx(sprDeathcap, floor(4.8 + squishTime), floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)
				else drawSpriteEx(sprDeathcap, floor(4.8 + squishTime), floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)
			}

			shape.setPos(x, y)
			setDrawColor(0xff0000ff)
			if(debug) shape.draw()
		}
	}

	function hurtplayer() {
		if(squish) return
		base.hurtplayer()
	}

	function gethurt() {
		if(squish) return
		if(!nocount) game.enemies--

		if(gvPlayer.rawin("anSlide")) {
			if(gvPlayer.anim == gvPlayer.anSlide) {
				local c = newActor(DeadNME, x, y)
				actor[c].sprite = sprDeathcap
				actor[c].vspeed = -abs(gvPlayer.hspeed * 1.1)
				actor[c].hspeed = (gvPlayer.hspeed / 16)
				actor[c].spin = (gvPlayer.hspeed * 6)
				actor[c].angle = 180
				deleteActor(id)
				playSound(sndKick, 0)
			}
			else if(getcon("jump", "hold")) gvPlayer.vspeed = -5
			else {
				gvPlayer.vspeed = -2
				playSound(sndSquish, 0)
			}
			if(gvPlayer.anim == gvPlayer.anJumpT || gvPlayer.anim == gvPlayer.anFall) {
				gvPlayer.anim = gvPlayer.anJumpU
				gvPlayer.frame = gvPlayer.anJumpU[0]
			}
		}
		else if(keyDown(config.key.jump)) gvPlayer.vspeed = -5
		else gvPlayer.vspeed = -2
		if(gvPlayer.anim == gvPlayer.anJumpT || gvPlayer.anim == gvPlayer.anFall) {
			gvPlayer.anim = gvPlayer.anJumpU
			gvPlayer.frame = gvPlayer.anJumpU[0]
		}

		squish = true
	}

	function hurtfire() {
		newActor(Flame, x, y - 1)
		deleteActor(id)
		playSound(sndFlame, 0)
		if(!nocount) game.enemies--
		if(randInt(20) == 0) {
			local a = actor[newActor(MuffinBlue, x, y)]
			a.vspeed = -2
		}
	}

	function _typeof() { return "Deathcap" }
}

::Cychin <- class extends Enemy {
	sf = 0.0

	constructor(_x, _y, _arr = null) {
		base.constructor(_x, _y)
		shape = Rec(x, y, 8, 8, 0)
		sf = randInt(8)
        freezable = false
	}

	function run() {
		base.run()

		drawSprite(sprCychin, sf + (getFrames() / 16), x - camx, y - camy)

		if(gvPlayer != 0) if(hitTest(shape, gvPlayer.shape)) {
			if(x > gvPlayer.x) {
				if(gvPlayer.placeFree(gvPlayer.x - 1, gvPlayer.y)) gvPlayer.x--
				gvPlayer.hspeed -= 0.1
			}

			if(x < gvPlayer.x) {
				if(gvPlayer.placeFree(gvPlayer.x + 1, gvPlayer.y)) gvPlayer.x++
				gvPlayer.hspeed += 0.1
			}

			if(y > gvPlayer.y) {
				if(gvPlayer.placeFree(gvPlayer.x, gvPlayer.y - 1)) gvPlayer.y--
				gvPlayer.vspeed -= 0.1
			}

			if(y < gvPlayer.y) {
				if(gvPlayer.placeFree(gvPlayer.x, gvPlayer.y + 1)) gvPlayer.y++
				gvPlayer.vspeed += 0.1
			}
		}

		if(frozen) {
			//Create ice block
			if(gvPlayer != 0) if(icebox == -1 && !hitTest(shape, gvPlayer.shape)) {
				icebox = mapNewSolid(shape)
			}

			if(frozen <= 120) {
				if(floor(frozen / 4) % 2 == 0) drawSprite(sprIceTrapSmall, 0, x - camx - 1 + ((floor(frozen / 4) % 4 == 0).tointeger() * 2), y - camy - 1)
				else drawSprite(sprIceTrapSmall, 0, x - camx, y - camy - 1)
			}
			else drawSprite(sprIceTrapSmall, 0, x - camx, y - camy - 1)
		}
		else {
			if(icebox != -1) {
				mapDeleteSolid(icebox)
				newActor(IceChunks, x, y)
				icebox = -1
			}
		}
	}

	function gethurt() { hurtplayer() }

	function hurtfire() {}
}

::Leaf <- class extends Enemy {
	sf = 0.0
    vai = 0
    hspeed = 3
    vspeed = 3

	constructor(_x, _y, _arr = null) {
		base.constructor(_x, _y)
		shape = Rec(x, y, 8, 8, 0)
		sf = randInt(8)
        vai = 1
        hspeed = 3
        vspeed = 3
	}

	function run() {
		base.run()

		drawSprite(sprOuchin, sf + (getFrames() / 16), x - camx, y - camy)
        
        if(vai == 1){
            vspeed = vspeed - 0.25
            hspeed = hspeed + 0.3
            if(vspeed <= 0){
                vai = 2
            }
        }
        else if(vai == 2){
            hspeed = hspeed - 0.3
            vspeed = vspeed - 0.02
            if(hspeed <= 0){
                vai = 3
                hspeed = 0
            }
        }    
        else if(vai == 3)
            vspeed = vspeed + 1
            hspeed = hspeed - 0.1
            if(vspeed >= 3){
                vai = 4
            }
            
        else if(vai == 4){
            vspeed = vspeed - 0.25
            hspeed = hspeed - 0.3
            if(vspeed <= 0){
                vai = 5
            }
        }
        else if(vai == 5){
            hspeed = hspeed + 0.3
            vspeed = vspeed - 0.02
            if(hspeed >= 0){
                vai = 6
                hspeed = 0
            }
        }
        else if(vai == 6){
            vspeed = vspeed + 0.4
            hspeed = hspeed + 0.1
            if(vspeed >= 3){
                vai = 1
            }
        }

        x += hspeed
        y += vspeed

		if(gvPlayer != 0) if(hitTest(shape, gvPlayer.shape)) {
			if(x > gvPlayer.x) {
				if(gvPlayer.placeFree(gvPlayer.x - 1, gvPlayer.y)) gvPlayer.x--
				gvPlayer.hspeed -= 0.1
			}

			if(x < gvPlayer.x) {
				if(gvPlayer.placeFree(gvPlayer.x + 1, gvPlayer.y)) gvPlayer.x++
				gvPlayer.hspeed += 0.1
			}

			if(y > gvPlayer.y) {
				if(gvPlayer.placeFree(gvPlayer.x, gvPlayer.y - 1)) gvPlayer.y--
				gvPlayer.vspeed -= 0.1
			}

			if(y < gvPlayer.y) {
				if(gvPlayer.placeFree(gvPlayer.x, gvPlayer.y + 1)) gvPlayer.y++
				gvPlayer.vspeed += 0.1
			}
		}

		if(frozen) {
			//Create ice block
			if(gvPlayer != 0) if(icebox == -1 && !hitTest(shape, gvPlayer.shape)) {
				icebox = mapNewSolid(shape)
			}

			if(frozen <= 120) {
				if(floor(frozen / 4) % 2 == 0) drawSprite(sprIceTrapSmall, 0, x - camx - 1 + ((floor(frozen / 4) % 4 == 0).tointeger() * 2), y - camy - 1)
				else drawSprite(sprIceTrapSmall, 0, x - camx, y - camy - 1)
			}
			else drawSprite(sprIceTrapSmall, 0, x - camx, y - camy - 1)

            shape.setPos(x, y)
			setDrawColor(0xff0000ff)
			if(debug) shape.draw()
		}
		else {
			if(icebox != -1) {
				mapDeleteSolid(icebox)
				newActor(IceChunks, x, y)
				icebox = -1
			}
		}
	}

	function gethurt() { hurtplayer() }

	function hurtfire() {}
}

::AntiJumpy <- class extends Enemy {
	frame = 0.0
	flip = false
	squish = false
	squishTime = 0.0
	smart = false

	constructor(_x, _y, _arr = null) {
		base.constructor(_x.tofloat(), _y.tofloat())
		shape = Rec(x, y, 6, 6, 0)

		vspeed = 3
	}

	function run() {
		base.run()

		if(active) {
			if(gvPlayer != 0 && hspeed == 0) {
				if(x > gvPlayer.x) hspeed = -0.0
				else hspeed = 0.0
			}

			if(!placeFree(x, y - 1)) vspeed = 2.5
			if(!placeFree(x + 0, y - 2) && !placeFree(x + 2, y)) hspeed = 0
			if(!placeFree(x - 0, y - 2) && !placeFree(x - 2, y)) hspeed = 0
            vspeed -= 0.05
			

			if(gvPlayer != 0) if(gvPlayer.x > x) flip = 0
			else flip = 1

			if(!frozen) {
				if(placeFree(x + hspeed, y)) x += hspeed
				if(placeFree(x, y + vspeed)) y += vspeed
				else vspeed /= 2
			}

			shape.setPos(x, y)

			//Draw
			drawSpriteEx(sprAntiJumpy, getFrames() / 8, floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)

			if(frozen) {
				//Create ice block
				if(gvPlayer != 0) if(icebox == -1 && !hitTest(shape, gvPlayer.shape)) {
					icebox = mapNewSolid(shape)
				}

				//Draw
				drawSpriteEx(sprAntiJumpy, 0, floor(x - camx), floor(y - camy), 0, flip.tointeger(), 1, 1, 1)

				if(frozen <= 120) {
				if(floor(frozen / 4) % 2 == 0) drawSprite(sprIceTrapSmall, 0, x - camx - 1 + ((floor(frozen / 4) % 4 == 0).tointeger() * 2), y - camy - 1)
					else drawSprite(sprIceTrapSmall, 0, x - camx, y - camy - 1)
				}
				else drawSprite(sprIceTrapSmall, 0, x - camx, y - camy - 1)
			}
			else {
				//Delete ice block
				if(icebox != -1) {
					mapDeleteSolid(icebox)
					newActor(IceChunks, x, y)
					icebox = -1
					if(gvPlayer != 0) if(x > gvPlayer.x) flip = true
					else flip = false
				}
			}
		}

		if(x < 0) hspeed = 0.0
		if(x > gvMap.w) hspeed = -0.0
	}

	function gethurt() {
	    gvPlayer.hurt = true
	}

	function hurtfire() {
		newActor(Flame, x, y - 1)
		deleteActor(id)
		playSound(sndFlame, 0)
		if(!nocount) game.enemies--
	}
}

::RedCoin <- class extends Actor{
	frame = 0.0

	constructor(_x, _y, _arr = null)
	{
		base.constructor(_x, _y)
		frame = randFloat(4)
		game.maxredcoins++
	}

	function run()
	{
		frame += 0.1
		drawSprite(sprRedCoin, frame, x - camx, y - camy)
		if(gvPlayer != 0) if(distance2(x, y, gvPlayer.x, gvPlayer.y + 2) <= 14) {
			deleteActor(id)
			newActor(RedCoinEffect, x, y)
		}
	}

	function _typeof() { return "RedCoin" }
}

::RedCoinEffect <- class extends Actor {
	vspeed = -4.0

	constructor(_x, _y, _arr = null) {
		base.constructor(_x, _y)
		playSound(sndCoin, 0)
		game.levelredcoins++
	}

	function run() {
		vspeed += 0.3
		y += vspeed
		drawSprite(sprRedCoin, getFrames() / 2, x - camx, y - camy)
		if(vspeed >= 2) {
			deleteActor(id)
			newActor(Spark, x, y)
		}
	}
}

::CustomFunc <- function(){
    if(game.maxredcoins > 0) drawSprite(sprRedCoin, 0, 16, screenH() - 40)
    if(game.maxredcoins > 0) drawText(font2, 24, screenH() - 46, game.levelredcoins.tostring() + "/" + game.maxredcoins.tostring())
    //drawText(font2, 24, screenH() - 60, vai.tostring())
    //else drawText(font2, 24, screenH() - 23, game.redcoins.tostring())
}