#!mainFile "../main.opy"

#!include "heroes/bastion/configuration.opy"

rule "[bastion/tank.opy]: Detect tank mode":
    @Event eachPlayer
    @Hero bastion
    @Condition eventPlayer.current_configuration != Configuration.SENTRY
    @Condition eventPlayer.isUsingAbility1()

    eventPlayer.current_configuration = Configuration.TANK


rule "[bastion/tank.opy]: Initialize tank mode":
    @Event eachPlayer
    @Hero bastion
    @Condition eventPlayer.current_configuration == Configuration.TANK
    @Condition eventPlayer.current_configuration != Configuration.SENTRY

    eventPlayer.setMoveSpeed(percent(BASTION_TANK_CONFIG_MOVE_SPEED)) # move faster in tank mode
    setBaseDamage(eventPlayer, BASTION_TANK_CONFIG_DAMAGE/OW2_BASTION_TACTICAL_GRENADE_DAMAGE) # deal more damage in tank mode
    eventPlayer.setProjectileSpeed(percent(BASTION_TANK_CONFIG_PROJECTILE_SPEED/OW2_BASTION_TACTICAL_GRENADE_PROJECTILE_SPEED)) # increase grenade travel speed (to mimic tank shells)
    eventPlayer.setProjectileGravity(5)

    eventPlayer.disallowButton(Button.PRIMARY_FIRE) # Disallow firing machine gun
    eventPlayer.disallowButton(Button.SECONDARY_FIRE)
    eventPlayer.allowButton(Button.SECONDARY_FIRE)
    eventPlayer.setSecondaryFireEnabled(false)
    eventPlayer.setSecondaryFireEnabled(true)

    eventPlayer.clearStatusEffect(Status.ROOTED)
    eventPlayer.setKnockbackReceived(100)


def startTank():
    @Name "[bastion/tank.opy]: startTank()"

    #eventPlayer.setUltEnabled(false) # Prevent Bastion from getting ult charge during ultimate
    wait(BASTION_TANK_CONFIG_TRANSFORM_TIME-OW2_BASTION_ASSAULT_CONFIG_TRANSFORM_TIME)
    eventPlayer.cancelPrimaryAction() # interrupt ultimate animation right before it completes
    eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)
    eventPlayer.forceButtonPress(Button.ABILITY_1) # Go to turret mode
    eventPlayer.allowButton(Button.SECONDARY_FIRE) # fix a bug where they cant fire it.
    #eventPlayer.disallowButton(Button.ABILITY_1) # Disable reconfiguring out of turret mode


def endTank():
    @Name "[bastion/tank.opy]: endTank()"

    if eventPlayer.isUsingAbility1():
        eventPlayer.setAbilityCooldown(Button.ABILITY_1, 0)
        eventPlayer.forceButtonPress(Button.ABILITY_1) # Go to recon mode
    eventPlayer.allowButton(Button.ABILITY_1)
    eventPlayer.setUltEnabled(true)


rule "[bastion/tank.opy]: Activate tank mode":
    @Event eachPlayer
    @Hero bastion
    @Condition eventPlayer.current_configuration == Configuration.TANK
    @Condition eventPlayer.current_configuration != Configuration.SENTRY
    
    startTank()
    waitUntil(not eventPlayer.isUsingAbility1(), BASTION_TANK_CONFIG_DURATION)
    endTank()


rule "[bastion/tank.opy]: Fire tank shells":
    @Event eachPlayer
    @Hero bastion
    @Condition eventPlayer.current_configuration == Configuration.TANK
    @Condition eventPlayer.current_configuration != Configuration.SENTRY
    @Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
    
    do: 
        eventPlayer.allowButton(Button.SECONDARY_FIRE)
        eventPlayer.forceButtonPress(Button.SECONDARY_FIRE)
        eventPlayer.disallowButton(Button.SECONDARY_FIRE)
        wait()
        waitUntil(eventPlayer.getAbilityCooldown(Button.SECONDARY_FIRE) <= 0, Math.INFINITY)
    while RULE_CONDITION


rule "[bastion/tank.opy]: Reload tank shells":
    @Event eachPlayer
    @Hero bastion
    @Condition eventPlayer.current_configuration == Configuration.TANK
    @Condition eventPlayer.current_configuration != Configuration.SENTRY
    @Condition eventPlayer.isFiringSecondaryFire()

    eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, BASTION_TANK_CONFIG_SHELL_RELOAD_TIME) # modify cooldown for tank shell
    wait(BASTION_TANK_CONFIG_SHELL_RELOAD_TIME) # Wait tank shell reload time
    eventPlayer.setAbilityCooldown(Button.SECONDARY_FIRE, 0) # Set tank shell as available