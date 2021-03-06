// ==========================================================
// T7ScriptSuite
//
// Component: player
// Purpose: shared player code for all gamemodes
//
// Initial author: DidUknowiPwn
// Started: May 14, 2017
// ==========================================================

#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\flagsys_shared;
#using scripts\shared\player_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

// T7 Script Suite - Include everything
#insert scripts\m_shared\utility.gsh;
T7_SCRIPT_SUITE_INCLUDES
#insert scripts\m_shared\lui.gsh;
#insert scripts\m_shared\bits.gsh;

#namespace m_player;

/@
"Author: DidUknowiPwn"
"Name: m_player::lock( [stance] )"
"Summary: Player is locked from all movement mechanics."
"Module: Player"
"OptionalArg: [stance] : force a stance and lock the player to that one "
"Example: player m_player::lock( "crouch" );"
@/
function lock( stance = self GetStance() )
{
	// override player velocity to "completely" lock
	self SetVelocity( (0,0,0) );
	self SetStance( stance );
	// stances -- broken in MP, ZM works
	self AllowedStances( stance );
	if ( SessionModeIsMultiplayerGame() )
		self thread loop_stance( stance );
	// movements
	self AllowJump( false );
	self AllowMelee( false );
	self AllowSprint( false );
	self SetMoveSpeedScale( 0 );
	// weapons -- player weapons must be handled before locking them
	self DisableWeaponCycling();
	self DisableOffhandWeapons();
}

/@
"Author: DidUknowiPwn"
"Name: m_player::release()"
"Summary: Player is released from all stopping mechanics."
"Module: Player"
"Example: player m_player::release();"
@/
function release()
{
	// stances
	if ( SessionModeIsMultiplayerGame() )
		self notify( "release_player" );
	self AllowCrouch( true );
	self AllowProne( true );
	self AllowStand( true );
	// movements
	self AllowJump( true );
	self AllowMelee( true );
	self AllowSprint( true );
	self SetMoveSpeedScale( 1 );
	// weapons
	self EnableWeaponCycling();
	self EnableOffhandWeapons();
}

function loop_stance( stance )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "entering_last_stand" ); // rejack
	self endon( "release_player" );

	while( true )
	{
		self SetStance( stance );
		WAIT_SERVER_FRAME;
	}
}