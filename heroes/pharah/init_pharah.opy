#!mainFile "../main.opy"

#!include "heroes/pharah/hover_jets.opy"
#!include "heroes/pharah/rocket_launcher.opy"
#!include "heroes/pharah/concussive.opy"
#!include "heroes/pharah/barrage.opy"

rule "[pharah/init.opy]: Detect switch to Pharah":
    @Event eachPlayer
    @Hero pharah

    eventPlayer.call_init = true


rule "[pharah/init.opy]: Initialize Pharah":
    @Event eachPlayer
    @Hero pharah
    @Condition eventPlayer.call_init

    newHero(PHARAH_HEALTH, 0, 0)
    setUltCost(PHARAH_ULT_COST)
    removePassiveHealing()
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)

    initHoverJets()

    eventPlayer.call_init = false


rule "[pharah/init.opy]: Clean up Pharah":
    @Event eachPlayer
    @Condition eventPlayer.getCurrentHero() == Hero.PHARAH
    
    waitUntil(eventPlayer.getCurrentHero() != Hero.PHARAH, Math.INFINITY)
    hideFuelGui()