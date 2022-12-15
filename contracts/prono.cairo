// Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import (assert_not_zero, assert_not_equal, assert_le)
from starkware.starknet.common.syscalls import (
    get_caller_address,
    get_block_timestamp,
)

struct Match {
    home_team: felt,
    away_team: felt,
    date: felt,
    is_score_set: felt, // boolean
    score_ht: felt,
    score_at: felt,
}

struct Bet {
    score_ht: felt,
    score_at: felt,
}

@constructor
func constructor{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
}(owner_address: felt) {
    alloc_locals;

    // we set the owner of the sc
    owner.write(value=owner_address);
    
    tempvar m = Match(
        home_team=0, // ""
        away_team=0, // "" 
        date=0, 
        is_score_set=FALSE, 
        score_ht=0, 
        score_at=0
    );

    // 8eme
    //m.date = 1670079600; // 2022-12-03 15:00:00Z
    matches.write(0, m);
    //m.date = 1670094000; // 2022-12-03 19:00:00Z
    matches.write(1, m);
    //m.date = 1670166000; // 2022-12-04 15:00:00Z
    matches.write(2, m);
    //m.date = 1670180400; // 2022-12-04 19:00:00Z
    matches.write(3, m);
    //m.date = 1670252400; // 2022-12-05 15:00:00Z
    matches.write(4, m);
    //m.date = 1670266800; // 2022-12-05 19:00:00Z
    matches.write(5, m);
    //m.date = 1670338800; // 2022-12-06 19:00:00Z
    matches.write(6, m);
    //m.date = 1670353200; // 2022-12-06 19:00:00Z
    matches.write(7, m);

    // quarts
    //m.date = 1670598000; // 2022-12-09 15:00:00Z
    matches.write(8, m);
    //m.date = 1670612400; // 2022-12-09 19:00:00Z
    matches.write(9, m);
    //m.date = 1670684400; // 2022-12-10 15:00:00Z
    matches.write(10, m);
    //m.date = 1670698800; // 2022-12-10 19:00:00Z
    matches.write(11, m);

    // demis
    //m.date = 1670958000; // 2022-12-13 19:00:00Z
    matches.write(12, m);
    //m.date = 1671044400; // 2022-12-14 19:00:00Z
    matches.write(13, m);

    // 3eme place
    //m.date = 1671289200; // 2022-12-17 15:00:00Z
    matches.write(14, m);

    // final
    //m.date = 1671375600; // 2022-12-18 15:00:00Z
    matches.write(15, m);
    
    return ();
}

// EXTERNALS

// only owner
@external 
func set_match_teams_by_id{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    id: felt, home_team: felt, away_team: felt
) {
    assert_le(id, 15);
    assert_only_owner();

    let (match) = matches.read(id=id);
    let m = Match(
        home_team=home_team, // ""
        away_team=away_team, // "" 
        date=match.date, 
        is_score_set=match.is_score_set, 
        score_ht=match.score_ht, 
        score_at=match.score_at, 
    );
    matches.write(id, m);

    return ();
}

// only owner
@external
func set_match_date_by_id{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    id: felt, date: felt
) {
    assert_le(id, 15);
    assert_only_owner();

    let (match) = matches.read(id=id);
    let m = Match(
        home_team=match.home_team, // ""
        away_team=match.away_team, // "" 
        date=date, 
        is_score_set=match.is_score_set, 
        score_ht=match.score_ht, 
        score_at=match.score_at, 
    );
    matches.write(id, m);

    return ();
}

// only owner
@external 
func set_match_result_by_id{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    id: felt, score_ht: felt, score_at: felt
) {
    assert_le(id, 15);
    assert_only_owner();

    let (match) = matches.read(id=id);
    let m = Match(
        home_team=match.home_team, // ""
        away_team=match.away_team, // "" 
        date=match.date, 
        is_score_set=TRUE, 
        score_ht=score_ht, 
        score_at=score_at, 
    );
    matches.write(id, m);

    return ();
}

// only owner
@external 
func set_match_data_by_id{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    id: felt, date: felt, home_team: felt, away_team: felt, score_ht: felt, score_at: felt
) {
    assert_le(id, 15);
    assert_only_owner();

    let (match) = matches.read(id=id);
    let m = Match(
        home_team=home_team, // ""
        away_team=away_team, // "" 
        date=date, 
        is_score_set=TRUE, 
        score_ht=score_ht, 
        score_at=score_at, 
    );
    matches.write(id, m);

    return ();
}

@external
func set_match_bet_by_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    id: felt, home_team: felt, away_team: felt
) {
    assert_le(id, 15);

    let (match) = matches.read(id=id);
    let (block_timestamp) = get_block_timestamp();
    assert_le(block_timestamp, match.date); // cannot bet on already started match

    let (caller) = get_caller_address();
    
    let bet = Bet(
        score_ht=home_team,
        score_at=away_team
    );

    bets.write(address=caller, match_id=id, value=bet);

    return ();
}



// VIEWS

@view
func get_match_oponents_by_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    id: felt
) -> (home_team: felt, away_team: felt) {
    assert_le(id, 15);
    let (m) = matches.read(id);
    return (m.home_team, m.away_team);
}

@view
func get_match_date_by_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    id: felt
) -> (date: felt) {
    assert_le(id, 15);
    let (m) = matches.read(id);
    return (date=m.date);
}

@view
func get_match_data_by_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    id: felt
) -> (date: felt, home_team: felt, away_team: felt, score_ht: felt, score_at: felt) {
    assert_le(id, 15);
    let (m) = matches.read(id);
    return (date=m.date, home_team=m.home_team, away_team=m.away_team, score_ht=m.score_ht, score_at=m.score_at);
}

// INTERNALS

func assert_only_owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    let (local caller) = get_caller_address();
    let (local owner_stor) = owner.read();

    with_attr error_message("assert_only_owner failed:\n  caller: {caller}\n  owner: {owner}") {
        assert owner_stor = caller;
    }
    return ();
}

// STORAGES

@storage_var
func owner() -> (owner_address: felt) {
}

@storage_var
func matches(id: felt) -> (match: Match) {
}

@storage_var
func bets(address: felt, match_id: felt) -> (bet: Bet) {
}

@storage_var
func users(idx: felt) -> (address: felt) {
}

@storage_var
func users_len() -> (len: felt) {
}