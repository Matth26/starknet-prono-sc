// Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import (assert_not_zero, assert_not_equal, assert_le)
from starkware.cairo.common.math_cmp import is_nn
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
    has_been_bet: felt,
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
    _assert_only_owner();

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
    _assert_only_owner();

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
    _assert_only_owner();

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
    _assert_only_owner();

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
    alloc_locals;
    assert_le(id, 15);

    let (match) = matches.read(id=id);
    let (local block_timestamp) = get_block_timestamp();
    //with_attr error_message("set_match_bet_by_id failed:\ncannot bet on already started match") {
    //    assert_le(block_timestamp, match.date);
    //}

    let (local caller) = get_caller_address();
    
    let bet = Bet(
        has_been_bet=TRUE,
        score_ht=home_team,
        score_at=away_team
    );

    bets.write(address=caller, match_id=id, value=bet);
    let has_user_already_bet = _has_user_already_bet(caller, 0);
    if(has_user_already_bet == FALSE) {
        let (id) = users_len.read();
        users.write(id, caller);
        users_len.write(id+1);
        return ();
    } else {
        return ();
    }
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
) -> (date: felt, home_team: felt, away_team: felt, is_score_set: felt, score_ht: felt, score_at: felt) {
    assert_le(id, 15);
    let (m) = matches.read(id);
    return (date=m.date, home_team=m.home_team, away_team=m.away_team, is_score_set=m.is_score_set, score_ht=m.score_ht, score_at=m.score_at);
}

@view
func get_users_len{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (len: felt) {
    let len = users_len.read();
    return len;
}

@view
func get_user_bet_by_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt, id: felt) -> (bet: Bet) {
    let user_bet = bets.read(user_address, id);
    return user_bet;
}

@view
func get_user_points_by_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt, id: felt) -> (points: felt) {
    alloc_locals;
    let (local user_bet) = bets.read(user_address, id);
    let (local match) = matches.read(id);

    if(match.is_score_set == FALSE) {
        return (points=0);
    } else {
        if(user_bet.has_been_bet == TRUE) {
            let points = _compute_points(match, user_bet);
            return (points=points);
        }
        return (points=0);
    }
}

@view
func get_user_points{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt) -> (points: felt) {
    let points = _get_user_points(user_address, 0);
    return (points=points);
}

// INTERNALS
func _get_user_points{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt, id: felt) -> felt {
    alloc_locals;

    if(id == 16) {
        return 0;
    } else {
        let (local user_bet) = bets.read(user_address, id);
        let (local match) = matches.read(id);
        if(user_bet.has_been_bet == TRUE) {
            let points = _compute_points(match, user_bet);
            let next_points = _get_user_points(user_address, id+1);

            return points + next_points;
        } else {
            return _get_user_points(user_address, id+1);
        }
    }
}


func _assert_only_owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;

    let (local caller) = get_caller_address();
    let (local owner_stor) = owner.read();

    with_attr error_message("_assert_only_owner failed:\n  caller: {caller}\n  owner: {owner}") {
        assert owner_stor = caller;
    }
    return ();
}

func _has_user_already_bet{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt, current_id: felt) -> felt {
    let (len) = users_len.read();
    if(current_id == len) {
        return FALSE;
    }

    let (address) = users.read(current_id);
    if(address == user_address) {
        return TRUE;
    }

    return _has_user_already_bet(user_address, current_id+1);
}

func _compute_points{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(m: Match, b: Bet) -> felt {
    if(b.score_ht == m.score_ht) {
        if(b.score_at == m.score_at) {
            return 3;
        }
    }

    let diff_match = m.score_ht - m.score_at;
    let diff_bet = b.score_ht - b.score_at;
    if(diff_match == diff_bet) {
        return 2;
    }

    let winner = m.score_ht - m.score_at;
    let prono_winner = b.score_ht - b.score_at;
    let is_winner_not_negative = is_nn(winner);
    let is_prono_winner_not_negative = is_nn(prono_winner);
    
    if(is_winner_not_negative == 1) {
        if(is_prono_winner_not_negative == 1) {
            return 1;
        } else {
            return 0;
        }
    } else {
        if(is_prono_winner_not_negative == 1) {
            return 0;
        } else {
            return 1;
        }
    }
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