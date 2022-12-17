// Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import (assert_not_zero, assert_not_equal, assert_le)
from starkware.cairo.common.math_cmp import is_nn
from starkware.cairo.common.alloc import alloc
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

struct FromFrontBet {
    match_id: felt,
    score_ht: felt,
    score_at: felt,
}

struct Bet {
    has_been_bet: felt,
    score_ht: felt,
    score_at: felt,
}

struct Points {
    match_id: felt,
    points: felt,
}

struct Score {
    address: felt,
    points: felt,
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
    b: FromFrontBet
) {
    let (caller) = get_caller_address();
    _set_bet_by_id(caller, b);

    return ();
}

func _set_bet_by_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt, b: FromFrontBet
) {
    alloc_locals;
    assert_le(b.match_id, 15);

    let (match) = matches.read(id=b.match_id);
    let (local block_timestamp) = get_block_timestamp();
    //with_attr error_message("set_match_bet_by_id failed:\ncannot bet on already started match") {
    //    assert_le(block_timestamp, match.date);
    //}
    
    let bet = Bet(
        has_been_bet=TRUE,
        score_ht=b.score_ht,
        score_at=b.score_at
    );

    bets.write(address=address, match_id=b.match_id, value=bet);
    let has_user_already_bet = _has_user_already_bet(address, 0);
    if(has_user_already_bet == FALSE) {
        let (id) = users_len.read();
        users.write(id, address);
        users_len.write(id+1);
        return ();
    } else {
        return ();
    }
}

@external
func set_match_bets{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    bets_len: felt, bets: FromFrontBet*
) {
    let (caller) = get_caller_address();

    _set_bet__rec(caller, bets_len, bets);
    return ();
}

func _set_bet__rec{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address, bets_len: felt, bets: FromFrontBet*
) {
    if(bets_len == 0) { 
        return ();
    } else {
        let bet = bets[0];
        _set_bet_by_id(address, bet);
        return _set_bet__rec(address, bets_len-1, &bets[1]);
    }
}

// VIEWS

// ---------------------------------------------------------------------------------------------------------------
// MATCHES
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
func get_matches_data{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() 
    -> (matches_len: felt, matches: Match*) {
    alloc_locals;

    let (matches: Match*) = alloc();
    _add_match_to_array__rec(matches, 0);
    return (16, matches);
}

func _add_match_to_array__rec{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(matches_arr: Match*, match_index: felt) -> Match* {
    alloc_locals;

    if(match_index == 16){
        return matches_arr;
    } else {
        let (local match) = matches.read(match_index);
        assert matches_arr[match_index] = match;
        return _add_match_to_array__rec(matches_arr, match_index + 1);
    }
}

@view
func get_users_len{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (len: felt) {
    let len = users_len.read();
    return len;
}

// ---------------------------------------------------------------------------------------------------------------
// BETS
@view
func get_user_bet_by_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt, id: felt) -> (bet: Bet) {
    let user_bet = bets.read(user_address, id);
    return user_bet;
}

@view
func get_user_bets{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt) -> (bets_len: felt, bets: Bet*) {
    alloc_locals;

    let (bets: Bet*) = alloc();

    let has_user_already_bet = _has_user_already_bet(user_address, 0);
    if(has_user_already_bet == FALSE) {
        return (0, bets);
    } else {
        _add_bet_to_array__rec(user_address, bets, 0);
        return (16, bets);
    }
}

func _add_bet_to_array__rec{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt, bets_arr: Bet*, match_index: felt) -> Bet* {
    alloc_locals;

    if(match_index == 16){
        return bets_arr;
    } else {
        let (local bet) = bets.read(user_address, match_index);
        assert bets_arr[match_index] = bet;
        return _add_bet_to_array__rec(user_address, bets_arr, match_index + 1);
    }
}

// ---------------------------------------------------------------------------------------------------------------
// POINTS
@view
func get_user_points_by_id{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt, id: felt) -> (points: felt) {
    alloc_locals;
    let (local user_bet) = bets.read(user_address, id);
    let (local match) = matches.read(id);

    if(match.is_score_set == FALSE) {
        return (points=0);
    } else {
        let points = _compute_points(match, user_bet);
        return (points=points);
    }
}

@view
func get_user_points{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt) -> (points: felt) {
    let points = _get_user_points__rec(user_address, 0);
    return (points=points);
}

func _get_user_points__rec{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt, id: felt) -> felt {
    alloc_locals;

    if(id == 16) {
        return 0;
    } else {
        let (local user_bet) = bets.read(user_address, id);
        let (local match) = matches.read(id);
        
        let points = _compute_points(match, user_bet);
        let next_points = _get_user_points__rec(user_address, id+1);

        return points + next_points;   
    }
}

@view
func get_user_points_for_each_bet{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt) 
    -> (points_len: felt, points: Points*) {
    alloc_locals;

    let (points: Points*) = alloc();
    _add_points_to_array__rec(user_address, points, 0);
    return (16, points);
}

func _add_points_to_array__rec{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(user_address: felt, points_arr: Points*, match_index: felt) -> Points* {
    alloc_locals;

    if(match_index == 16){
        return points_arr;
    } else {
        let (local match) = matches.read(match_index);
        let (local user_bet) = bets.read(user_address, match_index);
        let points = _compute_points(match, user_bet);
        
        assert points_arr[match_index] = Points(match_id=match_index, points=points);
        return _add_points_to_array__rec(user_address, points_arr, match_index + 1);
    }
}

func _compute_points{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(m: Match, b: Bet) -> felt {
    if(b.has_been_bet == 0) {
        return 0;
    }

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

// ---------------------------------------------------------------------------------------------------------------
// SCOREBOARD
@view
func get_scoreboard{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (scores_len: felt, scores: Score*) {
    alloc_locals;
    let (scores: Score*) = alloc();

    let (len) = users_len.read();
    if(len == 0) {
        return (0, scores);
    }

    _add_score_to_array(scores, 0);
    return (len, scores);
}

func _add_score_to_array{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(scores: Score*, user_index: felt) -> Score* {
    alloc_locals;

    let (len) = users_len.read();
    if(user_index == len){
        return scores;
    } else {
        let (local user) = users.read(user_index);
        let (points) = get_user_points(user);
        assert scores[user_index] = Score(address=user, points=points);
        return _add_score_to_array(scores, user_index + 1);
    }
}

// INTERNALS

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